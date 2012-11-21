Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 89EE56B004D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 14:02:04 -0500 (EST)
Date: Wed, 21 Nov 2012 19:01:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121121190157.GL8218@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
 <20121121173316.GA29311@gmail.com>
 <20121121180200.GK8218@suse.de>
 <20121121182158.GA29893@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121121182158.GA29893@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 21, 2012 at 07:21:58PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Nov 21, 2012 at 06:33:16PM +0100, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > On Wed, Nov 21, 2012 at 06:03:06PM +0100, Ingo Molnar wrote:
> > > > > 
> > > > > * Mel Gorman <mgorman@suse.de> wrote:
> > > > > 
> > > > > > On Wed, Nov 21, 2012 at 10:21:06AM +0000, Mel Gorman wrote:
> > > > > > > 
> > > > > > > I am not including a benchmark report in this but will be posting one
> > > > > > > shortly in the "Latest numa/core release, v16" thread along with the latest
> > > > > > > schednuma figures I have available.
> > > > > > > 
> > > > > > 
> > > > > > Report is linked here https://lkml.org/lkml/2012/11/21/202
> > > > > > 
> > > > > > I ended up cancelling the remaining tests and restarted with
> > > > > > 
> > > > > > 1. schednuma + patches posted since so that works out as
> > > > > 
> > > > > Mel, I'd like to ask you to refer to our tree as numa/core or 
> > > > > 'numacore' in the future. Would such a courtesy to use the 
> > > > > current name of our tree be possible?
> > > > > 
> > > > 
> > > > Sure, no problem.
> > > 
> > > Thanks!
> > > 
> > > I ran a quick test with your 'balancenuma v4' tree and while 
> > > numa02 and numa01-THREAD-ALLOC performance is looking good, 
> > > numa01 performance does not look very good:
> > > 
> > >                     mainline    numa/core      balancenuma-v4
> > >      numa01:           340.3       139.4          276 secs
> > > 
> > > 97% slower than numa/core.
> > > 
> > 
> > It would be. numa01 is an adverse workload where all threads 
> > are hammering the same memory.  The two-stage filter in 
> > balancenuma restricts the amount of migration it does so it 
> > ends up in a situation where it cannot balance properly. [...]
> 
> Do you mean this "balancenuma v4" patch attributed to you:
> 
>  Subject: mm: Numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
>  From: Mel Gorman <mgorman@suse.de>
>  Date: Wed, 21 Nov 2012 10:21:42 +0000
> 

Yes.

>  ...
> 
>  Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> which has:
> 
>                 /*
>                  * Multi-stage node selection is used in conjunction
>                  * with a periodic migration fault to build a temporal
>                  * task<->page relation. By using a two-stage filter we
>                  * remove short/unlikely relations.
>                  *
>                  * Using P(p) ~ n_p / n_t as per frequentist
>                  * probability, we can equate a task's usage of a
>                  * particular page (n_p) per total usage of this
>                  * page (n_t) (in a given time-span) to a probability.
>                  *
>                  * Our periodic faults will sample this probability and
>                  * getting the same result twice in a row, given these
>                  * samples are fully independent, is then given by
>                  * P(n)^2, provided our sample period is sufficiently
>                  * short compared to the usage pattern.
>                  *
>                  * This quadric squishes small probabilities, making
>                  * it less likely we act on an unlikely task<->page
>                  * relation.
> 
> This looks very similar to the code and text that Peter wrote 
> for numa/core:
> 
> /*
>  * Multi-stage node selection is used in conjunction with a periodic
>  * migration fault to build a temporal task<->page relation. By
>  * using a two-stage filter we remove short/unlikely relations.
>  *
>  * Using P(p) ~ n_p / n_t as per frequentist probability, we can
>  * equate a task's usage of a particular page (n_p) per total usage
>  * of this page (n_t) (in a given time-span) to a probability.
>  *
>  * Our periodic faults will then sample this probability and getting
>  * the same result twice in a row, given these samples are fully
>  * independent, is then given by P(n)^2, provided our sample period
>  * is sufficiently short compared to the usage pattern.
>  *
>  * This quadric squishes small probabilities, making it less likely
>  * we act on an unlikely task<->page relation.
>  *
>  * Return the best node ID this page should be on, or -1 if it should
>  * stay where it is.
>  */
> 
> see commit:
> 
>   30f93abc6cb3 sched, numa, mm: Add the scanning page fault machinery
> 
> ?
> 
> I think it's the very same concept - yours is taken from an 
> older sched/numa commit and attributed to yourself? [If so then 
> please fix the attribution.]

Yes, it's completely based on earlier sched/numa patches. In many of the
patches you'll see notes where I documented what patches I originally
based on -- be it from sched/numa, autonuma or some combination of both.
In many cases I could not keep the signed-off-by because the end result
was simply too different to claim that the author was happy with it. I was
hoping that these notes would convert to signed-offs-by after review from
the original authors who were cc'd at all times.

> We have the same filter in numa/core - because we wrote it (FYI, 
> I wrote bits of the last_cpu variant in numa/core), yet our 
> numa01 performance is much better than the one of balancenuma.
> 

Yes, the lack of a note was a mistake. I've added the following note to
the top of this patch now

Note: This two-stage filter was taken directly from the sched/numa patch
        "sched, numa, mm: Add the scanning page fault machinery" but is
        only a partial extraction. As the end result is not necessarily
        recognisable, the signed-offs-by had to be removed. Will be
        added back if requested.

Thanks and apologies in advance for any other patch where I failed to
document the history correctly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
