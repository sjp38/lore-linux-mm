Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4A1E86B0038
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 01:45:37 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 15:42:46 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C8AE92BB004F
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 15:45:32 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r625UZuV34865220
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 15:30:35 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r625jWkU001944
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 15:45:32 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 4/4] powerpc/kvm: Use 256K chunk to track both RMA and hash page table allocation.
Date: Tue,  2 Jul 2013 11:15:18 +0530
Message-Id: <1372743918-12293-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, agraf@suse.de, m.szyprowski@samsung.com, mina86@mina86.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Both RMA and hash page table request will be a multiple of 256K. We can use
a chunk size of 256K to track the free/used 256K chunk in the bitmap. This
should help to reduce the bitmap size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/kvm/book3s_64_mmu_hv.c |  3 +++
 arch/powerpc/kvm/book3s_hv_cma.c    | 35 ++++++++++++++++++++++++-----------
 arch/powerpc/kvm/book3s_hv_cma.h    |  5 +++++
 3 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 354f4bb..7eb5dda 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -37,6 +37,8 @@
 #include <asm/ppc-opcode.h>
 #include <asm/cputable.h>
 
+#include "book3s_hv_cma.h"
+
 /* POWER7 has 10-bit LPIDs, PPC970 has 6-bit LPIDs */
 #define MAX_LPID_970	63
 
@@ -71,6 +73,7 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
 
 	/* Next try to allocate from the preallocated pool */
 	if (!hpt) {
+		VM_BUG_ON(order < KVM_CMA_CHUNK_ORDER);
 		page = kvm_alloc_hpt(1 << (order - PAGE_SHIFT));
 		if (page) {
 			hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));
diff --git a/arch/powerpc/kvm/book3s_hv_cma.c b/arch/powerpc/kvm/book3s_hv_cma.c
index e04b269..d9d3d85 100644
--- a/arch/powerpc/kvm/book3s_hv_cma.c
+++ b/arch/powerpc/kvm/book3s_hv_cma.c
@@ -24,6 +24,8 @@
 #include <linux/sizes.h>
 #include <linux/slab.h>
 
+#include "book3s_hv_cma.h"
+
 struct kvm_cma {
 	unsigned long	base_pfn;
 	unsigned long	count;
@@ -96,6 +98,7 @@ struct page *kvm_alloc_cma(unsigned long nr_pages, unsigned long align_pages)
 	int ret;
 	struct page *page = NULL;
 	struct kvm_cma *cma = &kvm_cma_area;
+	unsigned long chunk_count, nr_chunk;
 	unsigned long mask, pfn, pageno, start = 0;
 
 
@@ -107,21 +110,27 @@ struct page *kvm_alloc_cma(unsigned long nr_pages, unsigned long align_pages)
 
 	if (!nr_pages)
 		return NULL;
-
+	/*
+	 * align mask with chunk size. The bit tracks pages in chunk size
+	 */
 	VM_BUG_ON(!is_power_of_2(align_pages));
-	mask = align_pages - 1;
+	mask = (align_pages >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT)) - 1;
+	BUILD_BUG_ON(PAGE_SHIFT > KVM_CMA_CHUNK_ORDER);
+
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
@@ -150,9 +159,9 @@ struct page *kvm_alloc_cma(unsigned long nr_pages, unsigned long align_pages)
 bool kvm_release_cma(struct page *pages, unsigned long nr_pages)
 {
 	unsigned long pfn;
+	unsigned long nr_chunk;
 	struct kvm_cma *cma = &kvm_cma_area;
 
-
 	if (!cma || !pages)
 		return false;
 
@@ -164,9 +173,12 @@ bool kvm_release_cma(struct page *pages, unsigned long nr_pages)
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
 
@@ -204,13 +216,14 @@ static int __init kvm_cma_activate_area(unsigned long base_pfn,
 static int __init kvm_cma_init_reserved_areas(void)
 {
 	int bitmap_size, ret;
+	unsigned long chunk_count;
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
diff --git a/arch/powerpc/kvm/book3s_hv_cma.h b/arch/powerpc/kvm/book3s_hv_cma.h
index 788bc3b..655144f 100644
--- a/arch/powerpc/kvm/book3s_hv_cma.h
+++ b/arch/powerpc/kvm/book3s_hv_cma.h
@@ -14,6 +14,11 @@
 
 #ifndef __POWERPC_KVM_CMA_ALLOC_H__
 #define __POWERPC_KVM_CMA_ALLOC_H__
+/*
+ * Both RMA and Hash page allocation will be multiple of 256K.
+ */
+#define KVM_CMA_CHUNK_ORDER	18
+
 extern struct page *kvm_alloc_cma(unsigned long nr_pages,
 				  unsigned long align_pages);
 extern bool kvm_release_cma(struct page *pages, unsigned long nr_pages);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
