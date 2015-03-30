Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 98A186B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:47:59 -0400 (EDT)
Received: by pdcp1 with SMTP id p1so83226514pdc.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 05:47:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id df5si14588546pbb.239.2015.03.30.05.47.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 05:47:58 -0700 (PDT)
Date: Mon, 30 Mar 2015 14:47:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150330124746.GI21418@twins.programming.kicks-ass.net>
References: <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
 <20150328134457.GK27490@worktop.programming.kicks-ass.net>
 <20150329102440.GC32047@worktop.ger.corp.intel.com>
 <CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 30, 2015 at 05:32:16PM +0530, Viresh Kumar wrote:
> On 29 March 2015 at 15:54, Peter Zijlstra <peterz@infradead.org> wrote:

> > What I didn't say, but had thought of is that __run_timer() should skip
> > any timer that has RUNNING set -- for obvious reasons :-)

> Below is copied from your first reply, and so you probably already
> said that ? :)
> 
> > Also, once you have tbase_running, we can take base->running_timer out
> > altogether.

No, I means something else with that. We can remove the
tvec_base::running_timer field. Everything that uses that can use
tbase_running() AFAICT.

> I wanted to clarify if I understood it correctly..
> 
> Are you saying that:

> Case 2.) we keep retrying for it, until the time the other handler finishes?

That.

If we remove it from the list before we call ->fn. Therefore, even if
migrate happens, it will not see a RUNNING timer entry, seeing how its
not actually on any lists.

The only way to get on a list while running is if ->fn() requeues itself
_on_another_base_. When that happens, we need to wait for it to complete
running.

> Case 2.) We kept waiting for the first handler to finish ..
> - cpuY may waste some cycles as it kept waiting for handler to finish on cpuX ..

True, rather silly to requeue a timer on the same jiffy as its already
running through, but yes, an unlikely possibility.

You can run another timer while we wait -- if there is another of
course.

> - We may need to perform base unlock/lock on cpuY, so that cpuX can take cpuY's
> lock to reset tbase_running. And that might be racy, not sure.

Drop yes, racy not so much I think.


diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 2d3f5c504939..1394f9540348 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1189,12 +1189,39 @@ static inline void __run_timers(struct tvec_base *base)
 			cascade(base, &base->tv5, INDEX(3));
 		++base->timer_jiffies;
 		list_replace_init(base->tv1.vec + index, head);
+
+again:
 		while (!list_empty(head)) {
 			void (*fn)(unsigned long);
 			unsigned long data;
 			bool irqsafe;
 
-			timer = list_first_entry(head, struct timer_list,entry);
+			timer = list_first_entry(head, struct timer_list, entry);
+			if (unlikely(tbase_running(timer))) {
+				/* Only one timer on the list, force wait. */
+				if (unlikely(head->next == head->prev)) {
+					spin_unlock(&base->lock);
+
+					/*
+					 * The only way to get here is if the
+					 * handler requeued itself on another
+					 * base, this guarantees the timer will
+					 * not go away.
+					 */
+					while (tbase_running(timer))
+						cpu_relax();
+
+					spin_lock(&base->lock);
+				} else  {
+					/*
+					 * Otherwise, rotate the list and try
+					 * someone else.
+					 */
+					list_move_tail(&timer->entry, head);
+				}
+				goto again;
+			}
+
 			fn = timer->function;
 			data = timer->data;
 			irqsafe = tbase_get_irqsafe(timer->base);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
