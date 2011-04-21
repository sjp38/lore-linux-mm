Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAD08D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:37:33 -0400 (EDT)
Received: by fxm18 with SMTP id 18so27373fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 11:37:30 -0700 (PDT)
Date: Thu, 21 Apr 2011 20:37:27 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110421183727.GG15988@htj.dyndns.org>
References: <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
 <alpine.DEB.2.00.1104180930580.23207@router.home>
 <20110421144300.GA22898@htj.dyndns.org>
 <20110421145837.GB22898@htj.dyndns.org>
 <alpine.DEB.2.00.1104211243350.5741@router.home>
 <20110421180159.GF15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211308300.5741@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104211308300.5741@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph.

On Thu, Apr 21, 2011 at 01:20:39PM -0500, Christoph Lameter wrote:
> I dont think multiple times of batch is such a concern. Either the per cpu
> counter is high or the overflow has been folded into the global counter.
> 
> The interregnum is very short and since the counters are already fuzzy
> this is tolerable. We do the same thing elsewhere for vmstats.

We're talking about three different levels of fuzziness.

1. percpu_counter_sum() before the changes

	May deviate by the number of concurrent updaters and cacheline
	update latencies.

2. percpu_counter_sum() after the changes

	May deviate by multiples of @batch; however, the duration
	during which the deviation may be visible is brief (really?
	we're allowing preemption between local and global updates).

3. percpu_counter_read()

	May deviate by multiples of @batch.  Deviations are visible
	almost always.

You're arguing that change from #1 to #2 should be okay, which might
as well be true, but your change per-se doesn't require such
compromise and there's no reason to bundle the two changes together,
so, again, please update your patch to avoid the transition from #1 to
#2.

Shaohua's change requires transition from #1 to #2, which might or
might not be okay.  I really don't know.  You say it should be okay as
it came from vmstat and vmstat is updated the same way; however, no
matter where it came from, percpu_counter is now used in different
places which may or may not have different expectations regarding the
level of fuzziness in percpu_counter_sum(), so we would need more than
"but vmstat does that too" to make the change.

If you haven't noticed yet, I'm not feeling too enthusiastic about
cold path optimizations.  If cold path is kicking in too often, change
the code such that things don't happen that way instead of trying to
make cold paths go faster.  Leave cold paths robust and easy to
understand.

So, unless someone can show me that percpu_counter_sum() is
unnecessary (ie. the differences between not only #1 and #2 but also
between #1 and #3 are irrelevant), I don't think I'm gonna change the
slow path.  It's silly to micro optimize slow path to begin with and
I'm not gonna do that at the cost of subtle functionality change which
can bite us in the ass in twisted ways.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
