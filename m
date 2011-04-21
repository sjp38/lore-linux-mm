Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 46D9A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 10:43:06 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1500454fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:43:03 -0700 (PDT)
Date: Thu, 21 Apr 2011 16:43:00 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110421144300.GA22898@htj.dyndns.org>
References: <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
 <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home>
 <20110414211522.GE21397@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
 <alpine.DEB.2.00.1104180930580.23207@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104180930580.23207@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph.

On Mon, Apr 18, 2011 at 09:38:03AM -0500, Christoph Lameter wrote:
> Preemption flips are not cheap since enabling preemption may mean a call
> into the scheduler. On RT things get more expensive.
> 
> Preempt_enable means at least one additional branch. We are saving a
> branch by not using preempt.

It is cheap.  The cost of preempt_enable() regarding scheduler call is
TIF_NEED_RESCHED check.  The scheduler() call occurring afterwards is
not the overhead of preemption check, but the overhead of preemption
itself.  Also, in cases where the preemption check doesn't make sense
(I don't think that's the case here), the right thing to do is using
preempt_enable_no_resched().

> In order to make it simple I avoided an preempt enable/disable. With
> Shaohua's patches there will be a simple atomic_add within the last if
> cluase. I was able to consolidate multiple code paths into the cmpxchg
> loop with this approach.
> 
> The one below avoids the #ifdef that is ugly...

That said, combined with Shaohua's patch, maybe it's better this way.
Let's see...

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
