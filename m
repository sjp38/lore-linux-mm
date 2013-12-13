Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE1C6B0036
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:01:15 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so1101377eek.9
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:01:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si3235384eeg.31.2013.12.13.12.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 12:01:14 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] x86: mm: Account for TLB flushes only when debugging
Date: Fri, 13 Dec 2013 20:01:08 +0000
Message-Id: <1386964870-6690-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386964870-6690-1-git-send-email-mgorman@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Bisection between 3.11 and 3.12 fingered commit 9824cf97 (mm: vmstats:
tlb flush counters).  The counters are undeniably useful but how often
do we really need to debug TLB flush related issues? It does not justify
taking the penalty everywhere so make it a debugging option.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/tlbflush.h    |  6 +++---
 arch/x86/kernel/cpu/mtrr/generic.c |  4 ++--
 arch/x86/mm/tlb.c                  | 14 +++++++-------
 include/linux/vm_event_item.h      |  4 ++--
 include/linux/vmstat.h             |  8 ++++++++
 5 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index e6d90ba..04905bf 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -62,7 +62,7 @@ static inline void __flush_tlb_all(void)
 
 static inline void __flush_tlb_one(unsigned long addr)
 {
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ONE);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__flush_tlb_single(addr);
 }
 
@@ -93,13 +93,13 @@ static inline void __flush_tlb_one(unsigned long addr)
  */
 static inline void __flush_tlb_up(void)
 {
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb();
 }
 
 static inline void flush_tlb_all(void)
 {
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb_all();
 }
 
diff --git a/arch/x86/kernel/cpu/mtrr/generic.c b/arch/x86/kernel/cpu/mtrr/generic.c
index ce2d0a2..0e25a1b 100644
--- a/arch/x86/kernel/cpu/mtrr/generic.c
+++ b/arch/x86/kernel/cpu/mtrr/generic.c
@@ -683,7 +683,7 @@ static void prepare_set(void) __acquires(set_atomicity_lock)
 	}
 
 	/* Flush all TLBs via a mov %cr3, %reg; mov %reg, %cr3 */
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb();
 
 	/* Save MTRR state */
@@ -697,7 +697,7 @@ static void prepare_set(void) __acquires(set_atomicity_lock)
 static void post_set(void) __releases(set_atomicity_lock)
 {
 	/* Flush TLBs (no need to flush caches - they are disabled) */
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__flush_tlb();
 
 	/* Intel (P6) standard MTRRs */
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 09b8cb8..5176526 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -103,7 +103,7 @@ static void flush_tlb_func(void *info)
 	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
 
-	count_vm_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
 		if (f->flush_end == TLB_FLUSH_ALL)
 			local_flush_tlb();
@@ -131,7 +131,7 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 	info.flush_start = start;
 	info.flush_end = end;
 
-	count_vm_event(NR_TLB_REMOTE_FLUSH);
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
 	if (is_uv_system()) {
 		unsigned int cpu;
 
@@ -151,7 +151,7 @@ void flush_tlb_current_task(void)
 
 	preempt_disable();
 
-	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	local_flush_tlb();
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
@@ -219,12 +219,12 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 
 	/* tlb_flushall_shift is on balance point, details in commit log */
 	if (nr_base_pages > act_entries || has_large_page(mm, start, end)) {
-		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
 		/* flush range by one by one 'invlpg' */
 		for (addr = start; addr < end;	addr += PAGE_SIZE) {
-			count_vm_event(NR_TLB_LOCAL_FLUSH_ONE);
+			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 			__flush_tlb_single(addr);
 		}
 
@@ -262,7 +262,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 
 static void do_flush_tlb_all(void *info)
 {
-	count_vm_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	__flush_tlb_all();
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_LAZY)
 		leave_mm(smp_processor_id());
@@ -270,7 +270,7 @@ static void do_flush_tlb_all(void *info)
 
 void flush_tlb_all(void)
 {
-	count_vm_event(NR_TLB_REMOTE_FLUSH);
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
 	on_each_cpu(do_flush_tlb_all, NULL, 1);
 }
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index c557c6d..070de3d 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -71,12 +71,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
-#ifdef CONFIG_SMP
+#ifdef CONFIG_DEBUG_TLBFLUSH
 		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
 		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
-#endif
 		NR_TLB_LOCAL_FLUSH_ALL,
 		NR_TLB_LOCAL_FLUSH_ONE,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index e4b9480..80ebba9 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -83,6 +83,14 @@ static inline void vm_events_fold_cpu(int cpu)
 #define count_vm_numa_events(x, y) do { (void)(y); } while (0)
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_DEBUG_TLBFLUSH
+#define count_vm_tlb_event(x)	   count_vm_event(x)
+#define count_vm_tlb_events(x, y)  count_vm_events(x, y)
+#else
+#define count_vm_tlb_event(x)     do {} while (0)
+#define count_vm_tlb_events(x, y) do { (void)(y); } while (0)
+#endif
+
 #define __count_zone_vm_events(item, zone, delta) \
 		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
 		zone_idx(zone), delta)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
