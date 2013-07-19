Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A21926B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 16:40:05 -0400 (EDT)
Subject: [PATCH] mm: vmstats: track TLB flush stats on UP too
From: Dave Hansen <dave@sr71.net>
Date: Fri, 19 Jul 2013 13:40:04 -0700
Message-Id: <20130719204004.B28D1C10@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>


Andrew, this fixes up the TLB flush vmstats for UP.  It's on top
of the previous patch, but I'm happy to combine them and send a
replacement if you'd prefer.

This also removes the NR_TLB_LOCAL_FLUSH_ONE_KERNEL counter.  We
do not have a good API on UP to separate out the kernel from the
non-kernel flushes.  It's probably not an important distinction
anyway.

Compile and boot tested on 64-bit SMP and UP.  Compile tested
for x86_32 SMP.

--

The previous patch doing vmstats for TLB flushes effectively
missed UP since arch/x86/mm/tlb.c is only compiled for SMP.

UP systems do not do remote TLB flushes, so compile those
counters out on UP.

arch/x86/kernel/cpu/mtrr/generic.c calls __flush_tlb() directly.
This is probably an optimization since both the mtrr code and
__flush_tlb() write cr4.  It would probably be safe to make that
a flush_tlb_all() (and then get these statistics), but the mtrr
code is ancient and I'm hesitant to touch it other than to just
stick in the counters.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/arch/x86/include/asm/tlbflush.h    |   38 +++++++++++++++---
 linux.git-davehans/arch/x86/kernel/cpu/mtrr/generic.c |    2 
 linux.git-davehans/arch/x86/mm/tlb.c                  |    4 -
 linux.git-davehans/include/linux/vm_event_item.h      |    3 -
 linux.git-davehans/mm/vmstat.c                        |    3 -
 5 files changed, 39 insertions(+), 11 deletions(-)

diff -puN include/linux/vm_event_item.h~compile-useless-stats-out-on-up include/linux/vm_event_item.h
--- linux.git/include/linux/vm_event_item.h~compile-useless-stats-out-on-up	2013-07-19 08:21:37.408237538 -0700
+++ linux.git-davehans/include/linux/vm_event_item.h	2013-07-19 09:13:16.903143205 -0700
@@ -70,11 +70,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
+#ifdef CONFIG_SMP
 		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
 		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
+#endif
 		NR_TLB_LOCAL_FLUSH_ALL,
 		NR_TLB_LOCAL_FLUSH_ONE,
-		NR_TLB_LOCAL_FLUSH_ONE_KERNEL,
 		NR_VM_EVENT_ITEMS
 };
 
diff -puN mm/vmstat.c~compile-useless-stats-out-on-up mm/vmstat.c
--- linux.git/mm/vmstat.c~compile-useless-stats-out-on-up	2013-07-19 08:21:37.410237627 -0700
+++ linux.git-davehans/mm/vmstat.c	2013-07-19 09:13:29.388694341 -0700
@@ -817,11 +817,12 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+#ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
 	"nr_tlb_remote_flush_received",
+#endif
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
-	"nr_tlb_local_flush_one_kernel",
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
diff -puN arch/x86/mm/tlb.c~compile-useless-stats-out-on-up arch/x86/mm/tlb.c
--- linux.git/arch/x86/mm/tlb.c~compile-useless-stats-out-on-up	2013-07-19 08:21:37.411237672 -0700
+++ linux.git-davehans/arch/x86/mm/tlb.c	2013-07-19 09:10:16.183165988 -0700
@@ -280,10 +280,8 @@ static void do_kernel_range_flush(void *
 	unsigned long addr;
 
 	/* flush range by one by one 'invlpg' */
-	for (addr = f->flush_start; addr < f->flush_end; addr += PAGE_SIZE) {
-		count_vm_event(NR_TLB_LOCAL_FLUSH_ONE_KERNEL);
+	for (addr = f->flush_start; addr < f->flush_end; addr += PAGE_SIZE)
 		__flush_tlb_single(addr);
-	}
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
diff -puN arch/x86/mm/Makefile~compile-useless-stats-out-on-up arch/x86/mm/Makefile
diff -puN arch/x86/kernel/cpu/mtrr/generic.c~compile-useless-stats-out-on-up arch/x86/kernel/cpu/mtrr/generic.c
--- linux.git/arch/x86/kernel/cpu/mtrr/generic.c~compile-useless-stats-out-on-up	2013-07-19 08:30:41.081279304 -0700
+++ linux.git-davehans/arch/x86/kernel/cpu/mtrr/generic.c	2013-07-19 13:21:55.160158221 -0700
@@ -683,6 +683,7 @@ static void prepare_set(void) __acquires
 	}
 
 	/* Flush all TLBs via a mov %cr3, %reg; mov %reg, %cr3 */
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb();
 
 	/* Save MTRR state */
@@ -696,6 +697,7 @@ static void prepare_set(void) __acquires
 static void post_set(void) __releases(set_atomicity_lock)
 {
 	/* Flush TLBs (no need to flush caches - they are disabled) */
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb();
 
 	/* Intel (P6) standard MTRRs */
diff -puN arch/x86/include/asm/paravirt.h~compile-useless-stats-out-on-up arch/x86/include/asm/paravirt.h
diff -puN arch/x86/include/asm/tlbflush.h~compile-useless-stats-out-on-up arch/x86/include/asm/tlbflush.h
--- linux.git/arch/x86/include/asm/tlbflush.h~compile-useless-stats-out-on-up	2013-07-19 08:31:48.158245363 -0700
+++ linux.git-davehans/arch/x86/include/asm/tlbflush.h	2013-07-19 13:24:14.022307785 -0700
@@ -62,6 +62,7 @@ static inline void __flush_tlb_all(void)
 
 static inline void __flush_tlb_one(unsigned long addr)
 {
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__flush_tlb_single(addr);
 }
 
@@ -84,14 +85,39 @@ static inline void __flush_tlb_one(unsig
 
 #ifndef CONFIG_SMP
 
-#define flush_tlb() __flush_tlb()
-#define flush_tlb_all() __flush_tlb_all()
-#define local_flush_tlb() __flush_tlb()
+/* "_up" is for UniProcessor
+ *
+ * This is a helper for other header functions.  *Not*
+ * intended to be called directly.  All global TLB
+ * flushes need to either call this, or do the bump the
+ * vm statistics themselves.
+ */
+static inline void __flush_tlb_up(void)
+{
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	__flush_tlb();
+}
+
+static inline void flush_tlb_all(void)
+{
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	__flush_tlb_all();
+}
+
+static inline void flush_tlb(void)
+{
+	__flush_tlb_up();
+}
+
+static inline void local_flush_tlb(void)
+{
+	__flush_tlb_up();
+}
 
 static inline void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (mm == current->active_mm)
-		__flush_tlb();
+		__flush_tlb_up();
 }
 
 static inline void flush_tlb_page(struct vm_area_struct *vma,
@@ -105,14 +131,14 @@ static inline void flush_tlb_range(struc
 				   unsigned long start, unsigned long end)
 {
 	if (vma->vm_mm == current->active_mm)
-		__flush_tlb();
+		__flush_tlb_up();
 }
 
 static inline void flush_tlb_mm_range(struct mm_struct *mm,
 	   unsigned long start, unsigned long end, unsigned long vmflag)
 {
 	if (mm == current->active_mm)
-		__flush_tlb();
+		__flush_tlb_up();
 }
 
 static inline void native_flush_tlb_others(const struct cpumask *cpumask,
diff -puN arch/x86/include/asm/cpufeature.h~compile-useless-stats-out-on-up arch/x86/include/asm/cpufeature.h
diff -puN arch/x86/mm/init_64.c~compile-useless-stats-out-on-up arch/x86/mm/init_64.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
