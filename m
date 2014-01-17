Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id DD9EB6B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 03:53:11 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so1988397eek.36
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 00:53:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si6150668eem.124.2014.01.17.00.53.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 00:53:09 -0800 (PST)
Date: Fri, 17 Jan 2014 08:53:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmstat: Do not display stats for TLB flushes unless
 debugging
Message-ID: <20140117085305.GS4963@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
 <1389278098-27154-2-git-send-email-mgorman@suse.de>
 <20140116111205.GN4963@suse.de>
 <alpine.DEB.2.02.1401161515540.4182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401161515540.4182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 16, 2014 at 03:22:12PM -0800, David Rientjes wrote:
> On Thu, 16 Jan 2014, Mel Gorman wrote:
> 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 7249614..def5dd2 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -851,12 +851,14 @@ const char * const vmstat_text[] = {
> >  	"thp_zero_page_alloc",
> >  	"thp_zero_page_alloc_failed",
> >  #endif
> > +#ifdef CONFIG_DEBUG_TLBFLUSH
> >  #ifdef CONFIG_SMP
> >  	"nr_tlb_remote_flush",
> >  	"nr_tlb_remote_flush_received",
> > -#endif
> > +#endif /* CONFIG_SMP */
> >  	"nr_tlb_local_flush_all",
> >  	"nr_tlb_local_flush_one",
> > +#endif /* CONFIG_DEBUG_TLBFLUSH */
> >  
> >  #endif /* CONFIG_VM_EVENTS_COUNTERS */
> >  };
> 
> Hmm, so why are NR_TLB_REMOTE_FLUSH{,_RECEIVED} defined for !CONFIG_SMP in 
> linux-next?

Because there are times when I am a complete muppet and this
is one of them. This is a revised version of the patch "x86:
mm: Account for TLB flushes only when debugging" which is
x86-mm-account-for-tlb-flushes-only-when-debugging.patch in mmotm

Thanks David.

---8<---
x86: mm: Account for TLB flushes only when debugging

Bisection between 3.11 and 3.12 fingered commit 9824cf97 (mm: vmstats:
tlb flush counters).  The counters are undeniably useful but how often
do we really need to debug TLB flush related issues? It does not justify
taking the penalty everywhere so make it a debugging option.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/tlbflush.h    |  6 +++---
 arch/x86/kernel/cpu/mtrr/generic.c |  4 ++--
 arch/x86/mm/tlb.c                  | 14 +++++++-------
 include/linux/vm_event_item.h      |  4 +++-
 include/linux/vmstat.h             |  8 ++++++++
 mm/vmstat.c                        |  4 +++-
 6 files changed, 26 insertions(+), 14 deletions(-)

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
index ae699b3..05446c1 100644
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
@@ -215,7 +215,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 
 	/* tlb_flushall_shift is on balance point, details in commit log */
 	if ((end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift) {
-		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
+		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {
 		if (has_large_page(mm, start, end)) {
@@ -224,7 +224,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		}
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
index c557c6d..3a712e2 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -71,12 +71,14 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
+#ifdef CONFIG_DEBUG_TLBFLUSH
 #ifdef CONFIG_SMP
 		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
 		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
-#endif
+#endif /* CONFIG_SMP */
 		NR_TLB_LOCAL_FLUSH_ALL,
 		NR_TLB_LOCAL_FLUSH_ONE,
+#endif /* CONFIG_DEBUG_TLBFLUSH */
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
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7249614..def5dd2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -851,12 +851,14 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+#ifdef CONFIG_DEBUG_TLBFLUSH
 #ifdef CONFIG_SMP
 	"nr_tlb_remote_flush",
 	"nr_tlb_remote_flush_received",
-#endif
+#endif /* CONFIG_SMP */
 	"nr_tlb_local_flush_all",
 	"nr_tlb_local_flush_one",
+#endif /* CONFIG_DEBUG_TLBFLUSH */
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
