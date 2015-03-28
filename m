Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE246B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 09:45:04 -0400 (EDT)
Received: by pdcp1 with SMTP id p1so33568900pdc.3
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 06:45:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id gg9si1723229pbc.104.2015.03.28.06.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 06:45:02 -0700 (PDT)
Date: Sat, 28 Mar 2015 14:44:57 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150328134457.GK27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55169723.3070006@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viresh kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat, Mar 28, 2015 at 05:27:23PM +0530, viresh kumar wrote:
> So probably we need to make 'base' aligned to 8 bytes ?

Yeah, something like the below (at the very end) should ensure the thing
is cacheline aligned, that should give us a fair few bits.

> So, what you are suggesting is something like this (untested):

> @@ -1202,6 +1208,7 @@ static inline void __run_timers(struct tvec_base *base)
>                         timer_stats_account_timer(timer);
> 
>                         base->running_timer = timer;
> +                       tbase_set_running(timer->base);
>                         detach_expired_timer(timer, base);
> 
>                         if (irqsafe) {
> @@ -1216,6 +1223,7 @@ static inline void __run_timers(struct tvec_base *base)
>                 }
>         }
>         base->running_timer = NULL;
> +       tbase_clear_running(timer->base);
>         spin_unlock_irq(&base->lock);
>  }

That's broken. You need to clear running on all the timers you set it
on. Furthermore, you need to revalidate timer->base == base after
call_timer_fn().

Something like so:

diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d3f5c504939..489ce182f8ec 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1213,6 +1213,21 @@ static inline void __run_timers(struct tvec_base *base)
 				call_timer_fn(timer, fn, data);
 				spin_lock_irq(&base->lock);
 			}
+
+			if (unlikely(timer->base != base)) {
+				unsigned long flags;
+				struct tvec_base *tbase;
+
+				spin_unlock(&base->lock);
+
+				tbase = lock_timer_base(timer, &flags);
+				tbase_clear_running(timer->base);
+				spin_unlock(&tbase->lock);
+
+				spin_lock(&base->lock);
+			} else {
+				tbase_clear_running(timer->base);
+			}
 		}
 	}
 	base->running_timer = NULL;

Also, once you have tbase_running, we can take base->running_timer out
altogether.

> Now there are few issues I see here (Sorry if they are all imaginary):
> - In case a timer re-arms itself from its handler and is migrated from CPU A to B, what
>   happens if the re-armed timer fires before the first handler finishes ? i.e. timer->fn()
>   hasn't finished running on CPU A and it has fired again on CPU B. Wouldn't this expose
>   us to a lot of other problems? It wouldn't be serialized to itself anymore ?

What I said above.

> - Because the timer has migrated to another CPU, the locking in __run_timers()
>   needs to be fixed. And that will make it complicated ..

Hardly.

>   - __run_timer() doesn't lock bases of other CPUs, and it has to do it now..

Yep, but rarely.

>   - We probably need to take locks of both local CPU and the one to which timer migrated.

Nope, or rather, not at the same time. That's what the NULL magic buys
us.

> - Its possible now that there can be more than one running timer for a base, which wasn't
>   true earlier. Not sure if it will break something.

Only if you messed it up real bad :-)

---
 kernel/time/timer.c | 36 ++++++++----------------------------
 1 file changed, 8 insertions(+), 28 deletions(-)

diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d3f5c504939..c8c45bf50b2e 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -93,6 +93,7 @@ struct tvec_base {
 struct tvec_base boot_tvec_bases;
 EXPORT_SYMBOL(boot_tvec_bases);
 static DEFINE_PER_CPU(struct tvec_base *, tvec_bases) = &boot_tvec_bases;
+static DEFINE_PER_CPU(struct tvec_base, __tvec_bases);
 
 /* Functions below help us manage 'deferrable' flag */
 static inline unsigned int tbase_get_deferrable(struct tvec_base *base)
@@ -1534,46 +1535,25 @@ EXPORT_SYMBOL(schedule_timeout_uninterruptible);
 
 static int init_timers_cpu(int cpu)
 {
-	int j;
-	struct tvec_base *base;
+	struct tvec_base *base = per_cpu(tvec_bases, cpu);
 	static char tvec_base_done[NR_CPUS];
+	int j;
 
 	if (!tvec_base_done[cpu]) {
 		static char boot_done;
 
-		if (boot_done) {
-			/*
-			 * The APs use this path later in boot
-			 */
-			base = kzalloc_node(sizeof(*base), GFP_KERNEL,
-					    cpu_to_node(cpu));
-			if (!base)
-				return -ENOMEM;
-
-			/* Make sure tvec_base has TIMER_FLAG_MASK bits free */
-			if (WARN_ON(base != tbase_get_base(base))) {
-				kfree(base);
-				return -ENOMEM;
-			}
-			per_cpu(tvec_bases, cpu) = base;
+		if (!boot_done) {
+			boot_done = 1; /* skip the boot cpu */
 		} else {
-			/*
-			 * This is for the boot CPU - we use compile-time
-			 * static initialisation because per-cpu memory isn't
-			 * ready yet and because the memory allocators are not
-			 * initialised either.
-			 */
-			boot_done = 1;
-			base = &boot_tvec_bases;
+			base = per_cpu_ptr(&__tvec_bases);
+			per_cpu(tvec_bases, cpu) = base;
 		}
+
 		spin_lock_init(&base->lock);
 		tvec_base_done[cpu] = 1;
 		base->cpu = cpu;
-	} else {
-		base = per_cpu(tvec_bases, cpu);
 	}
 
-
 	for (j = 0; j < TVN_SIZE; j++) {
 		INIT_LIST_HEAD(base->tv5.vec + j);
 		INIT_LIST_HEAD(base->tv4.vec + j);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
