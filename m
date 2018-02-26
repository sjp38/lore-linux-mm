Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8ECD6B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:01:31 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q4so15072430ioh.4
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:01:31 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y91si5581888ita.37.2018.02.26.08.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 08:01:28 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v2 1/1] xen, mm: Allow deferred page initialization for xen pv domains
Date: Mon, 26 Feb 2018 11:01:12 -0500
Message-Id: <20180226160112.24724-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180226160112.24724-1-pasha.tatashin@oracle.com>
References: <20180226160112.24724-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, jgross@suse.com, akataria@vmware.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, boris.ostrovsky@oracle.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, luto@kernel.org, labbott@redhat.com, kirill.shutemov@linux.intel.com, bp@suse.de, minipli@googlemail.com, jinb.park7@gmail.com, dan.j.williams@intel.com, bhe@redhat.com, zhang.jia@linux.alibaba.com, mgorman@techsingularity.net, hannes@cmpxchg.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

Juergen Gross noticed that commit
f7f99100d8d ("mm: stop zeroing memory during allocation in vmemmap")
broke XEN PV domains when deferred struct page initialization is enabled.

This is because the xen's PagePinned() flag is getting erased from struct
pages when they are initialized later in boot.

Juergen fixed this problem by disabling deferred pages on xen pv domains.
It is desirable, however, to have this feature available as it reduces boot
time. This fix re-enables the feature for pv-dmains, and fixes the problem
the following way:

The fix is to delay setting PagePinned flag until struct pages for all
allocated memory are initialized, i.e. until after free_all_bootmem().

A new x86_init.hyper op init_after_bootmem() is called to let xen know
that boot allocator is done, and hence struct pages for all the allocated
memory are now initialized. If deferred page initialization is enabled, the
rest of struct pages are going to be initialized later in boot once
page_alloc_init_late() is called.

xen_after_bootmem() walks page table's pages and marks them pinned.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/x86/include/asm/x86_init.h |  2 ++
 arch/x86/kernel/x86_init.c      |  1 +
 arch/x86/mm/init_32.c           |  1 +
 arch/x86/mm/init_64.c           |  1 +
 arch/x86/xen/mmu_pv.c           | 38 ++++++++++++++++++++++++++------------
 mm/page_alloc.c                 |  4 ----
 6 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/x86_init.h b/arch/x86/include/asm/x86_init.h
index 5ffa116ddb08..c06046e2d3ff 100644
--- a/arch/x86/include/asm/x86_init.h
+++ b/arch/x86/include/asm/x86_init.h
@@ -122,12 +122,14 @@ struct x86_init_pci {
  * @guest_late_init:		guest late init
  * @x2apic_available:		X2APIC detection
  * @init_mem_mapping:		setup early mappings during init_mem_mapping()
+ * @init_after_bootmem:		guest init after boot allocator is finished
  */
 struct x86_hyper_init {
 	void (*init_platform)(void);
 	void (*guest_late_init)(void);
 	bool (*x2apic_available)(void);
 	void (*init_mem_mapping)(void);
+	void (*init_after_bootmem)(void);
 };
 
 /**
diff --git a/arch/x86/kernel/x86_init.c b/arch/x86/kernel/x86_init.c
index aab817eb05cf..3215bffbf4d1 100644
--- a/arch/x86/kernel/x86_init.c
+++ b/arch/x86/kernel/x86_init.c
@@ -91,6 +91,7 @@ struct x86_init_ops x86_init __initdata = {
 		.guest_late_init	= x86_init_noop,
 		.x2apic_available	= bool_x86_init_noop,
 		.init_mem_mapping	= x86_init_noop,
+		.init_after_bootmem	= x86_init_noop,
 	},
 
 	.acpi = {
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 79cb066f40c0..0b750c845078 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -763,6 +763,7 @@ void __init mem_init(void)
 	free_all_bootmem();
 
 	after_bootmem = 1;
+	x86_init.hyper.init_after_bootmem();
 
 	mem_init_print_info(NULL);
 	printk(KERN_INFO "virtual kernel memory layout:\n"
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 332f6e25977a..8d60443dd900 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1189,6 +1189,7 @@ void __init mem_init(void)
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
 	after_bootmem = 1;
+	x86_init.hyper.init_after_bootmem();
 
 	/*
 	 * Must be done after boot memory is put on freelist, because here we
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index d20763472920..486c0a34d00b 100644
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
+ * During early boot all page table pages are pinned, but we do not have struct
+ * pages, so return true until struct pages are ready.
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
@@ -2364,9 +2379,7 @@ static void __init xen_post_allocator_init(void)
 
 #ifdef CONFIG_X86_64
 	pv_mmu_ops.write_cr3 = &xen_write_cr3;
-	SetPagePinned(virt_to_page(level3_user_vsyscall));
 #endif
-	xen_mark_init_mm_pinned();
 }
 
 static void xen_leave_lazy_mmu(void)
@@ -2450,6 +2463,7 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 void __init xen_init_mmu_ops(void)
 {
 	x86_init.paging.pagetable_init = xen_pagetable_init;
+	x86_init.hyper.init_after_bootmem = xen_after_bootmem;
 
 	pv_mmu_ops = xen_mmu_ops;
 
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
