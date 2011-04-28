Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0EC5B6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:11:24 -0400 (EDT)
Date: Thu, 28 Apr 2011 09:11:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110428100938.GA10721@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104280904240.15775@router.home>
References: <20110421180159.GF15988@htj.dyndns.org> <alpine.DEB.2.00.1104211308300.5741@router.home> <20110421183727.GG15988@htj.dyndns.org> <alpine.DEB.2.00.1104211350310.5741@router.home> <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2011, Tejun Heo wrote:

> Hmm... we're now more lost than ever. :-( Can you please re-read my
> message two replies ago?  The one where I talked about sporadic
> erratic behaviors in length and why I was worried about it.
>
> In your last reply, you talked about preemption and that you didn't
> have problems with disabling preemption, which, unfortunately, doesn't
> have much to do with my concern with the sporadic erratic behaviors
> and that's what I pointed out in my previous reply.  So, it doesn't
> feel like anything is resolved.

Sporadic erratic behavior exists today since any thread can add an
abitrary number to its local counter while you are adding up all the per
cpu differentials. If this happens just after you picked up the value then
a single cpu can cause a high deviation. If multiple cpus do this then a
high degree of deviation can even be had with todays implementation.

Can you show in some tests how the chance of deviations is increased? If
at all then in some special sitations. Maybe others get better?

The counters were always designed to be racy for performance reasons.
Trying to serialize them goes against the design of these things. In order
to increase accuracy you have to decrease the allowable delta in the per
cpu differentials.

Looping over all differentials to get more accuracy is something that may
not work as we have seen recently with the VM counters issues that caused
bad behavior during reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
