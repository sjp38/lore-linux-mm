Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E974A6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:13:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rr13so5606431pbb.14
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 02:13:45 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id vv4si10038731pbc.236.2014.04.28.02.13.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 02:13:44 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 19:01:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 335482BB0060
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:01:52 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3S91bLY10617320
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:01:37 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3S91pxe026928
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:01:51 +1000
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH V3 1/2] mm: move FAULT_AROUND_ORDER to arch/
Date: Mon, 28 Apr 2014 14:31:29 +0530
Message-Id: <1398675690-16186-2-git-send-email-maddy@linux.vnet.ibm.com>
In-Reply-To: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com>
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com>
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
 mm/memory.c |   11 ++++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

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
index d0f0bef..457436d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3382,11 +3382,9 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-#define FAULT_AROUND_ORDER 4
+unsigned int fault_around_order = CONFIG_FAULT_AROUND_ORDER;
 
 #ifdef CONFIG_DEBUG_FS
-static unsigned int fault_around_order = FAULT_AROUND_ORDER;
-
 static int fault_around_order_get(void *data, u64 *val)
 {
 	*val = fault_around_order;
@@ -3395,7 +3393,6 @@ static int fault_around_order_get(void *data, u64 *val)
 
 static int fault_around_order_set(void *data, u64 val)
 {
-	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
 	if (1UL << val > PTRS_PER_PTE)
 		return -EINVAL;
 	fault_around_order = val;
@@ -3430,14 +3427,14 @@ static inline unsigned long fault_around_pages(void)
 {
 	unsigned long nr_pages;
 
-	nr_pages = 1UL << FAULT_AROUND_ORDER;
+	nr_pages = 1UL << fault_around_order;
 	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
 	return nr_pages;
 }
 
 static inline unsigned long fault_around_mask(void)
 {
-	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
+	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
 }
 #endif
 
@@ -3495,7 +3492,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages) {
+	if ((vma->vm_ops->map_pages) && (fault_around_order)) {
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
