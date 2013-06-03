Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 132E06B004D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 05:05:17 -0400 (EDT)
Date: Mon, 3 Jun 2013 11:05:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB and PTE coherency during munmap
Message-ID: <20130603090501.GI5910@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

On Fri, May 31, 2013 at 08:09:17AM +0400, Max Filippov wrote:
> Hi Peter,
> 
> On Wed, May 29, 2013 at 9:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > What about something like this?
> 
> With that patch I still get mtest05 firing my TLB/PTE incoherency check
> in the UP PREEMPT_VOLUNTARY configuration. This happens after
> zap_pte_range completion in the end of unmap_region because of
> rescheduling called in the following call chain:

OK, so there two options; completely kill off fast-mode or something like the
below where we add magic to the scheduler :/

I'm aware people might object to something like the below -- but since its a
possibility I thought we ought to at least mention it.

For those new to the thread; the problem is that since the introduction of
preemptible mmu_gather the traditional UP fast-mode is broken. Fast-mode is
where we free the pages first and flush TLBs later. This is not a problem if
there's no concurrency, but obviously if you can preempt there now is.

I think I prefer completely killing off fast-mode esp. since UP seems to go the
way of the Dodo and it does away with an exception in the mmu_gather code.

Anyway; opinions? Linus, Thomas, Ingo?

---
nclude/asm-generic/tlb.h | 19 +++++++++++++++----
 include/linux/sched.h     |  1 +
 kernel/sched/core.c       |  9 +++++++++
 mm/memory.c               |  3 +++
 4 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b1b1fa6..8d84154 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -116,15 +116,26 @@ struct mmu_gather {
 
 static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
+#ifdef CONFIG_PREEMPT
+	/*
+	 * We don't want to add to the schedule fast path for preemptible
+	 * kernels; disable fast mode unconditionally.
+	 */
+	return 0;
+#endif
+
 #ifdef CONFIG_SMP
+	/*
+	 * We can only use fast mode if there's a single CPU online;
+	 * otherwise SMP might trip over stale TLB entries.
+	 */
 	return tlb->fast_mode;
-#else
+#endif
+
 	/*
-	 * For UP we don't need to worry about TLB flush
-	 * and page free order so much..
+	 * Non-preempt UP can do fast mode unconditionally.
 	 */
 	return 1;
-#endif
 }
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 178a8d9..3dc6930 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1416,6 +1416,7 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+	struct mmu_gather *tlb;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 36f85be..6829b78 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2374,6 +2374,15 @@ static void __sched __schedule(void)
 	struct rq *rq;
 	int cpu;
 
+#ifndef CONFIG_PREEMPT
+	/*
+	 * We always force batched mmu_gather for preemptible kernels in order
+	 * to minimize scheduling delays. See tlb_fast_mode().
+	 */
+	if (current->tlb && tlb_fast_mode(current->tlb))
+		tlb_flush_mmu(current->tlb);
+#endif
+
 need_resched:
 	preempt_disable();
 	cpu = smp_processor_id();
diff --git a/mm/memory.c b/mm/memory.c
index d7d54a1..8925578 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -230,6 +230,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm)
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+	current->tlb = tlb;
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -274,6 +275,8 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
 		free_pages((unsigned long)batch, 0);
 	}
 	tlb->local.next = NULL;
+
+	current->tlb = NULL;
 }
 
 /* __tlb_remove_page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
