Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6456B6B0008
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 18:25:56 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id o10so8894044iod.21
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 15:25:56 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r197si2227583ior.186.2018.02.23.15.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 15:25:53 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v1 1/1] xen, mm: Allow deferred page initialization for xen pv domains
Date: Fri, 23 Feb 2018 18:25:38 -0500
Message-Id: <20180223232538.4314-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180223232538.4314-1-pasha.tatashin@oracle.com>
References: <20180223232538.4314-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, jgross@suse.com, akataria@vmware.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, boris.ostrovsky@oracle.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, luto@kernel.org, labbott@redhat.com, kirill.shutemov@linux.intel.com, bp@suse.de, minipli@googlemail.com, jinb.park7@gmail.com, dan.j.williams@intel.com, bhe@redhat.com, zhang.jia@linux.alibaba.com, mgorman@techsingularity.net, hannes@cmpxchg.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

Juergen Gross noticed that commit
f7f99100d8d ("mm: stop zeroing memory during allocation in vmemmap")
broke XEN PV domains when deferred struct page initialization is enabled.

This is because the xen's PagePinned() flag is getting erased from struct
pages when they are initialized later in boot.

Juergen fixed this problem by disabling deferred pages on xen pv domains.
However, it is desirable to have this feature available, as it reduces boot
time. This fix re-enables the feature for pv-dmains, and fixes the problem
the following way:

The fix is to delay setting PagePinned flag until struct pages for all
allocated memory are initialized (until free_all_bootmem()).

A new hypervisor op pv_init_ops.after_bootmem() is called to let xen know
that boot allocator is done, and hence struct pages for all the allocated
memory are now initialized. If deferred page initialization is enabled, the
rest of struct pages are going to be initialized later in boot once
page_alloc_init_late() is called.

xen_after_bootmem() is xen's implementation of pv_init_ops.after_bootmem(),
we walk page table and mark every page as pinned.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/x86/include/asm/paravirt.h       |  9 +++++++++
 arch/x86/include/asm/paravirt_types.h |  3 +++
 arch/x86/kernel/paravirt.c            |  1 +
 arch/x86/mm/init_32.c                 |  1 +
 arch/x86/mm/init_64.c                 |  1 +
 arch/x86/xen/mmu_pv.c                 | 38 ++++++++++++++++++++++++-----------
 mm/page_alloc.c                       |  4 ----
 7 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 9be2bf13825b..737e596a9836 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -820,6 +820,11 @@ static inline notrace unsigned long arch_local_irq_save(void)
 
 extern void default_banner(void);
 
+static inline void paravirt_after_bootmem(void)
+{
+	pv_init_ops.after_bootmem();
+}
+
 #else  /* __ASSEMBLY__ */
 
 #define _PVSITE(ptype, clobbers, ops, word, algn)	\
@@ -964,6 +969,10 @@ static inline void paravirt_arch_dup_mmap(struct mm_struct *oldmm,
 static inline void paravirt_arch_exit_mmap(struct mm_struct *mm)
 {
 }
+
+static inline void paravirt_after_bootmem(void)
+{
+}
 #endif /* __ASSEMBLY__ */
 #endif /* !CONFIG_PARAVIRT */
 #endif /* _ASM_X86_PARAVIRT_H */
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 180bc0bff0fb..da78a3610168 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -86,6 +86,9 @@ struct pv_init_ops {
 	 */
 	unsigned (*patch)(u8 type, u16 clobber, void *insnbuf,
 			  unsigned long addr, unsigned len);
+
+	/* called right after we finish boot allocator */
+	void (*after_bootmem)(void);
 } __no_randomize_layout;
 
 
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index 99dc79e76bdc..7b5f931e2e3a 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -315,6 +315,7 @@ struct pv_info pv_info = {
 
 struct pv_init_ops pv_init_ops = {
 	.patch = native_patch,
+	.after_bootmem = paravirt_nop,
 };
 
 struct pv_time_ops pv_time_ops = {
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 79cb066f40c0..6096d0d9ecbc 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -763,6 +763,7 @@ void __init mem_init(void)
 	free_all_bootmem();
 
 	after_bootmem = 1;
+	paravirt_after_bootmem();
 
 	mem_init_print_info(NULL);
 	printk(KERN_INFO "virtual kernel memory layout:\n"
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 332f6e25977a..70b7b5093d07 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1189,6 +1189,7 @@ void __init mem_init(void)
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
 	after_bootmem = 1;
+	paravirt_after_bootmem();
 
 	/*
 	 * Must be done after boot memory is put on freelist, because here we
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index d20763472920..603589809334 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -116,6 +116,8 @@ DEFINE_PER_CPU(unsigned long, xen_current_cr3);	 /* actual vcpu cr3 */
 
 static phys_addr_t xen_pt_base, xen_pt_size __initdata;
 
+static DEFINE_STATIC_KEY_FALSE(xen_struct_pages_ready);
+
 /*
  * Just beyond the highest usermode address.  STACK_TOP_MAX has a
  * redzone above it, so round it up to a PGD boundary.
@@ -155,11 +157,18 @@ void make_lowmem_page_readwrite(void *vaddr)
 }
 
 
+/*
+ * During early boot all pages are pinned, but we do not have struct pages,
+ * so return true until struct pages are ready.
+ */
 static bool xen_page_pinned(void *ptr)
 {
-	struct page *page = virt_to_page(ptr);
+	if (static_branch_likely(&xen_struct_pages_ready)) {
+		struct page *page = virt_to_page(ptr);
 
-	return PagePinned(page);
+		return PagePinned(page);
+	}
+	return true;
 }
 
 static void xen_extend_mmu_update(const struct mmu_update *update)
@@ -836,11 +845,6 @@ void xen_mm_pin_all(void)
 	spin_unlock(&pgd_lock);
 }
 
-/*
- * The init_mm pagetable is really pinned as soon as its created, but
- * that's before we have page structures to store the bits.  So do all
- * the book-keeping now.
- */
 static int __init xen_mark_pinned(struct mm_struct *mm, struct page *page,
 				  enum pt_level level)
 {
@@ -848,8 +852,18 @@ static int __init xen_mark_pinned(struct mm_struct *mm, struct page *page,
 	return 0;
 }
 
-static void __init xen_mark_init_mm_pinned(void)
+/*
+ * The init_mm pagetable is really pinned as soon as its created, but
+ * that's before we have page structures to store the bits.  So do all
+ * the book-keeping now once struct pages for allocated pages are
+ * initialized. This happens only after free_all_bootmem() is called.
+ */
+static void __init xen_after_bootmem(void)
 {
+	static_branch_enable(&xen_struct_pages_ready);
+#ifdef CONFIG_X86_64
+	SetPagePinned(virt_to_page(level3_user_vsyscall));
+#endif
 	xen_pgd_walk(&init_mm, xen_mark_pinned, FIXADDR_TOP);
 }
 
@@ -1623,14 +1637,15 @@ static inline void __set_pfn_prot(unsigned long pfn, pgprot_t prot)
 static inline void xen_alloc_ptpage(struct mm_struct *mm, unsigned long pfn,
 				    unsigned level)
 {
-	bool pinned = PagePinned(virt_to_page(mm->pgd));
+	bool pinned = xen_page_pinned(mm->pgd);
 
 	trace_xen_mmu_alloc_ptpage(mm, pfn, level, pinned);
 
 	if (pinned) {
 		struct page *page = pfn_to_page(pfn);
 
-		SetPagePinned(page);
+		if (static_branch_likely(&xen_struct_pages_ready))
+			SetPagePinned(page);
 
 		if (!PageHighMem(page)) {
 			xen_mc_batch();
@@ -2364,9 +2379,8 @@ static void __init xen_post_allocator_init(void)
 
 #ifdef CONFIG_X86_64
 	pv_mmu_ops.write_cr3 = &xen_write_cr3;
-	SetPagePinned(virt_to_page(level3_user_vsyscall));
 #endif
-	xen_mark_init_mm_pinned();
+	pv_init_ops.after_bootmem = &xen_after_bootmem;
 }
 
 static void xen_leave_lazy_mmu(void)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2836bc9e0999..6f9d34bdd071 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -46,7 +46,6 @@
 #include <linux/stop_machine.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
-#include <xen/xen.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
@@ -317,9 +316,6 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	/* Always populate low zones for address-constrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
-	/* Xen PV domains need page structures early */
-	if (xen_pv_domain())
-		return true;
 	(*nr_initialised)++;
 	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
