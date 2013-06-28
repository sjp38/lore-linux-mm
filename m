Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 574276B0036
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:11:17 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 14:36:07 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A73B7394004F
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:41:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S9B96e26869960
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:41:09 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S9BBQs000741
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 19:11:12 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 4/4] powerpc/kvm: Use 256K chunk to track both RMA and hash page table allocation.
Date: Fri, 28 Jun 2013 14:41:02 +0530
Message-Id: <1372410662-3748-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Both RMA and hash page table request will be a multiple of 256K. We can use
a chunk size of 256K to track the free/used 256K chunk in the bitmap. This
should help to reduce the bitmap size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/kvm/book3s_hv_cma.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_cma.c b/arch/powerpc/kvm/book3s_hv_cma.c
index fdd0b88..018613a 100644
--- a/arch/powerpc/kvm/book3s_hv_cma.c
+++ b/arch/powerpc/kvm/book3s_hv_cma.c
@@ -23,6 +23,10 @@
 #include <linux/mutex.h>
 #include <linux/sizes.h>
 #include <linux/slab.h>
+/*
+ * Both RMA and Hash page allocation will be multiple of 256K.
+ */
+#define KVM_CMA_CHUNK_ORDER	18
 
 struct kvm_cma {
 	unsigned long	base_pfn;
@@ -94,6 +98,7 @@ err:
 struct page *kvm_alloc_cma(int nr_pages, unsigned long align_pages)
 {
 	int ret;
+	int chunk_count, nr_chunk;
 	struct page *page = NULL;
 	struct kvm_cma *cma = &kvm_cma_area;
 	unsigned long mask, pfn, pageno, start = 0;
@@ -107,20 +112,26 @@ struct page *kvm_alloc_cma(int nr_pages, unsigned long align_pages)
 
 	if (!nr_pages)
 		return NULL;
+	/*
+	 * aling mask with chunk size. The bit tracks pages in chunk size
+	 */
+	mask = (align_pages >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT)) - 1;
+	BUILD_BUG_ON(PAGE_SHIFT > KVM_CMA_CHUNK_ORDER);
 
-	mask = align_pages - 1;
+	chunk_count = cma->count >>  (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
+	nr_chunk = nr_pages >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
 
 	mutex_lock(&kvm_cma_mutex);
 	for (;;) {
-		pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count,
-						    start, nr_pages, mask);
-		if (pageno >= cma->count)
+		pageno = bitmap_find_next_zero_area(cma->bitmap, chunk_count,
+						    start, nr_chunk, mask);
+		if (pageno >= chunk_count)
 			break;
 
-		pfn = cma->base_pfn + pageno;
+		pfn = cma->base_pfn + (pageno << (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT));
 		ret = alloc_contig_range(pfn, pfn + nr_pages, MIGRATE_CMA);
 		if (ret == 0) {
-			bitmap_set(cma->bitmap, pageno, nr_pages);
+			bitmap_set(cma->bitmap, pageno, nr_chunk);
 			page = pfn_to_page(pfn);
 			memset(pfn_to_kaddr(pfn), 0, nr_pages << PAGE_SHIFT);
 			break;
@@ -148,6 +159,7 @@ struct page *kvm_alloc_cma(int nr_pages, unsigned long align_pages)
  */
 bool kvm_release_cma(struct page *pages, int nr_pages)
 {
+	int nr_chunk;
 	unsigned long pfn;
 	struct kvm_cma *cma = &kvm_cma_area;
 
@@ -163,9 +175,12 @@ bool kvm_release_cma(struct page *pages, int nr_pages)
 		return false;
 
 	VM_BUG_ON(pfn + nr_pages > cma->base_pfn + cma->count);
+	nr_chunk = nr_pages >>  (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
 
 	mutex_lock(&kvm_cma_mutex);
-	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, nr_pages);
+	bitmap_clear(cma->bitmap,
+		     (pfn - cma->base_pfn) >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT),
+		     nr_chunk);
 	free_contig_range(pfn, nr_pages);
 	mutex_unlock(&kvm_cma_mutex);
 
@@ -196,14 +211,14 @@ static int __init kvm_cma_activate_area(unsigned long base_pfn,
 
 static int __init kvm_cma_init_reserved_areas(void)
 {
-	int bitmap_size, ret;
+	int bitmap_size, ret, chunk_count;
 	struct kvm_cma *cma = &kvm_cma_area;
 
 	pr_debug("%s()\n", __func__);
 	if (!cma->count)
 		return 0;
-
-	bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
+	chunk_count = cma->count >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
+	bitmap_size = BITS_TO_LONGS(chunk_count) * sizeof(long);
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 	if (!cma->bitmap)
 		return -ENOMEM;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
