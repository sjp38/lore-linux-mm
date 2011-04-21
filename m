Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ACC7A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:50:15 -0400 (EDT)
Date: Thu, 21 Apr 2011 12:50:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110421145837.GB22898@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104211243350.5741@router.home>
References: <alpine.DEB.2.00.1104131521050.25812@router.home> <1302747263.3549.9.camel@edumazet-laptop> <alpine.DEB.2.00.1104141608300.19533@router.home> <20110414211522.GE21397@mtj.dyndns.org> <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org> <alpine.DEB.2.00.1104151440070.8055@router.home> <20110415235222.GA18694@mtj.dyndns.org> <alpine.DEB.2.00.1104180930580.23207@router.home> <20110421144300.GA22898@htj.dyndns.org>
 <20110421145837.GB22898@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Thu, 21 Apr 2011, Tejun Heo wrote:

> Unfortunately, I have a new concern for __percpu_counter_sum(), which
> applies to both your and Shaohua's change.  Before these changes,
> percpu_counter->lock protects whole of batch transfer.  IOW, while
> __percpu_counter_sum() is holding ->lock, it can be sure that batch
> transfer from percpu counter to the main counter isn't in progress and
> that the deviation it might see is limited by the number of on-going
> percpu inc/dec's which is much lower than batch transfers.

Yes. But there was already a fuzzyiness coming with the
__percpu_counter_sum() not seeing the percpu counters that are being
updated due to unserialized access to the counters before this patch.
There is no material difference here. The VM statistics counters work the
same way and have to deal with similar fuzziness effects.

> With the proposed changes to percpu counter, this no longer holds.
> cl's patch de-couples local counter update from the global counter
> update and __percpu_counter_sum() can see batch amount of deviation
> per concurrent updater making the whole visit-each-counter thing more
> or less meaningless.  This, however, can be fixed by putting the whole
> slow path inside spin_lock() as suggested before so that the whole
> batch transferring from local to global is enclosed inside spinlock.

The local counter increment was already decoupled before. The shifting of
the overflow into the global counter was also not serialized before.

> Unfortunately, Shaohua's atomic64_t update ain't that easy.  The whole
> point of that update was avoiding spinlocks in favor of atomic64_t,
> which naturally collides with the ability to enclosing local and
> global updates into the same exclusion block, which is necessary for
> __percpu_counter_sum() accuracy.

There was no total accuracy before either.

> So, Christoph, please put the whole slow path inside spin_lock().
> Shaohua, unfortunately, I think your change is caught inbetween rock
> and hard place.  Any ideas?

I think there is no new problem here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
