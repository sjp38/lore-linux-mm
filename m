Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 385A56B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 20:44:38 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id jt11so6537751pbb.13
        for <linux-mm@kvack.org>; Mon, 19 May 2014 17:44:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rd13si21703306pac.216.2014.05.19.17.44.36
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 17:44:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
 <537479E7.90806@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
 <87wqdik4n5.fsf@rustcorp.com.au>
 <53797511.1050409@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1405191531150.1317@eggly.anvils>
 <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Content-Transfer-Encoding: 7bit
Message-Id: <20140520004429.E660AE009B@blue.fi.intel.com>
Date: Tue, 20 May 2014 03:44:29 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, Rusty Russell <rusty@rustcorp.com.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

Andrew Morton wrote:
> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
> > the order of the fault-around size in bytes, and fault_around_pages()
> > use 1UL << (fault_around_order - PAGE_SHIFT)
> 
> Yes.  And shame on me for missing it (this time!) at review.
> 
> There's still time to fix this.  Patches, please.

Here it is. Made at 3.30 AM, build tested only.

I'll sign it off tomorrow after testing.

diff --git a/mm/memory.c b/mm/memory.c
index 037b812a9531..9d6941c9a9e4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3402,62 +3402,62 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-#define FAULT_AROUND_ORDER 4
+#define FAULT_AROUND_BYTES 65536
 
 #ifdef CONFIG_DEBUG_FS
-static unsigned int fault_around_order = FAULT_AROUND_ORDER;
+static unsigned int fault_around_bytes = FAULT_AROUND_BYTES;
 
-static int fault_around_order_get(void *data, u64 *val)
+static int fault_around_bytes_get(void *data, u64 *val)
 {
-	*val = fault_around_order;
+	*val = fault_around_bytes;
 	return 0;
 }
 
-static int fault_around_order_set(void *data, u64 val)
+static int fault_around_bytes_set(void *data, u64 val)
 {
-	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
-	if (1UL << val > PTRS_PER_PTE)
+	BUILD_BUG_ON(FAULT_AROUND_BYTES / PAGE_SIZE > PTRS_PER_PTE);
+	if (val / PAGE_SIZE > PTRS_PER_PTE)
 		return -EINVAL;
-	fault_around_order = val;
+	fault_around_bytes = val;
 	return 0;
 }
-DEFINE_SIMPLE_ATTRIBUTE(fault_around_order_fops,
-		fault_around_order_get, fault_around_order_set, "%llu\n");
+DEFINE_SIMPLE_ATTRIBUTE(fault_around_bytes_fops,
+		fault_around_bytes_get, fault_around_bytes_set, "%llu\n");
 
 static int __init fault_around_debugfs(void)
 {
 	void *ret;
 
-	ret = debugfs_create_file("fault_around_order",	0644, NULL, NULL,
-			&fault_around_order_fops);
+	ret = debugfs_create_file("fault_around_bytes", 0644, NULL, NULL,
+			&fault_around_bytes_fops);
 	if (!ret)
-		pr_warn("Failed to create fault_around_order in debugfs");
+		pr_warn("Failed to create fault_around_bytes in debugfs");
 	return 0;
 }
 late_initcall(fault_around_debugfs);
 
 static inline unsigned long fault_around_pages(void)
 {
-	return 1UL << fault_around_order;
+	return fault_around_bytes / PAGE_SIZE;
 }
 
 static inline unsigned long fault_around_mask(void)
 {
-	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
+	return ~(round_down(fault_around_bytes, PAGE_SIZE) - 1);
 }
 #else
 static inline unsigned long fault_around_pages(void)
 {
 	unsigned long nr_pages;
 
-	nr_pages = 1UL << FAULT_AROUND_ORDER;
+	nr_pages = FAULT_AROUND_BYTES / PAGE_SIZE;
 	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
 	return nr_pages;
 }
 
 static inline unsigned long fault_around_mask(void)
 {
-	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
+	return ~(round_down(FAULT_AROUND_BYTES, PAGE_SIZE) - 1);
 }
 #endif
 
@@ -3515,7 +3515,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages) {
+	if (vma->vm_ops->map_pages && fault_around_pages() > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 		do_fault_around(vma, address, pte, pgoff, flags);
 		if (!pte_same(*pte, orig_pte))
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
