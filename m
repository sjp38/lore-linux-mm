Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D25C38D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:58:43 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1514129fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:58:40 -0700 (PDT)
Date: Thu, 21 Apr 2011 16:58:37 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110421145837.GB22898@htj.dyndns.org>
References: <alpine.DEB.2.00.1104131521050.25812@router.home>
 <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home>
 <20110414211522.GE21397@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
 <alpine.DEB.2.00.1104180930580.23207@router.home>
 <20110421144300.GA22898@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421144300.GA22898@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph, Shaohua.

On Thu, Apr 21, 2011 at 04:43:00PM +0200, Tejun Heo wrote:
> > In order to make it simple I avoided an preempt enable/disable. With
> > Shaohua's patches there will be a simple atomic_add within the last if
> > cluase. I was able to consolidate multiple code paths into the cmpxchg
> > loop with this approach.
> > 
> > The one below avoids the #ifdef that is ugly...
> 
> That said, combined with Shaohua's patch, maybe it's better this way.
> Let's see...

Unfortunately, I have a new concern for __percpu_counter_sum(), which
applies to both your and Shaohua's change.  Before these changes,
percpu_counter->lock protects whole of batch transfer.  IOW, while
__percpu_counter_sum() is holding ->lock, it can be sure that batch
transfer from percpu counter to the main counter isn't in progress and
that the deviation it might see is limited by the number of on-going
percpu inc/dec's which is much lower than batch transfers.

With the proposed changes to percpu counter, this no longer holds.
cl's patch de-couples local counter update from the global counter
update and __percpu_counter_sum() can see batch amount of deviation
per concurrent updater making the whole visit-each-counter thing more
or less meaningless.  This, however, can be fixed by putting the whole
slow path inside spin_lock() as suggested before so that the whole
batch transferring from local to global is enclosed inside spinlock.

Unfortunately, Shaohua's atomic64_t update ain't that easy.  The whole
point of that update was avoiding spinlocks in favor of atomic64_t,
which naturally collides with the ability to enclosing local and
global updates into the same exclusion block, which is necessary for
__percpu_counter_sum() accuracy.

So, Christoph, please put the whole slow path inside spin_lock().
Shaohua, unfortunately, I think your change is caught inbetween rock
and hard place.  Any ideas?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
