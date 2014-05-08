Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B24E6B00DA
	for <linux-mm@kvack.org>; Thu,  8 May 2014 05:28:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so2602424pab.0
        for <linux-mm@kvack.org>; Thu, 08 May 2014 02:28:33 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id wt1si221570pbc.333.2014.05.08.02.28.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 02:28:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Thu, 8 May 2014 14:58:25 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 18365E004B
	for <linux-mm@kvack.org>; Thu,  8 May 2014 14:58:51 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s489SSB634340882
	for <linux-mm@kvack.org>; Thu, 8 May 2014 14:58:29 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s489SJ3k027904
	for <linux-mm@kvack.org>; Thu, 8 May 2014 14:58:20 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH V4 1/2] mm: move FAULT_AROUND_ORDER to arch/
Date: Thu,  8 May 2014 14:58:15 +0530
Message-Id: <1399541296-18810-2-git-send-email-maddy@linux.vnet.ibm.com>
In-Reply-To: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>

Kirill A. Shutemov with 8c6e50b029 commit introduced
vm_ops->map_pages() for mapping easy accessible pages around
fault address in hope to reduce number of minor page faults.

This patch creates infrastructure to modify the FAULT_AROUND_ORDER
value using mm/Kconfig. This will enable architecture maintainers
to decide on suitable FAULT_AROUND_ORDER value based on
performance data for that architecture. Patch also defaults
FAULT_AROUND_ORDER Kconfig element to 4.

Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
---
 mm/Kconfig  |    8 ++++++++
 mm/memory.c |   25 ++++++-------------------
 2 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index ebe5880..c7fc4f1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -176,6 +176,14 @@ config MOVABLE_NODE
 config HAVE_BOOTMEM_INFO_NODE
 	def_bool n
 
+#
+# Fault around order is a control knob to decide the fault around pages.
+# Default value is set to 4 , but the arch can override it as desired.
+#
+config FAULT_AROUND_ORDER
+	int
+	default	4
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
diff --git a/mm/memory.c b/mm/memory.c
index 037b812..e3931ef 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3402,11 +3402,9 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-#define FAULT_AROUND_ORDER 4
+unsigned int fault_around_order __read_mostly = CONFIG_FAULT_AROUND_ORDER;
 
 #ifdef CONFIG_DEBUG_FS
-static unsigned int fault_around_order = FAULT_AROUND_ORDER;
-
 static int fault_around_order_get(void *data, u64 *val)
 {
 	*val = fault_around_order;
@@ -3415,7 +3413,6 @@ static int fault_around_order_get(void *data, u64 *val)
 
 static int fault_around_order_set(void *data, u64 val)
 {
-	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
 	if (1UL << val > PTRS_PER_PTE)
 		return -EINVAL;
 	fault_around_order = val;
@@ -3435,31 +3432,21 @@ static int __init fault_around_debugfs(void)
 	return 0;
 }
 late_initcall(fault_around_debugfs);
+#endif
 
 static inline unsigned long fault_around_pages(void)
 {
-	return 1UL << fault_around_order;
-}
-
-static inline unsigned long fault_around_mask(void)
-{
-	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
-}
-#else
-static inline unsigned long fault_around_pages(void)
-{
 	unsigned long nr_pages;
 
-	nr_pages = 1UL << FAULT_AROUND_ORDER;
-	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
+	nr_pages = 1UL << fault_around_order;
+	VM_BUG_ON(nr_pages > PTRS_PER_PTE);
 	return nr_pages;
 }
 
 static inline unsigned long fault_around_mask(void)
 {
-	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
+	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
 }
-#endif
 
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
@@ -3515,7 +3502,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages) {
+	if ((vma->vm_ops->map_pages) && fault_around_order) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 		do_fault_around(vma, address, pte, pgoff, flags);
 		if (!pte_same(*pte, orig_pte))
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
