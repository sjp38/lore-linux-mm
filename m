Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0F7B6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:23:37 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2706808fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:23:34 -0700 (PDT)
Date: Thu, 28 Apr 2011 16:23:31 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428142331.GA16552@htj.dyndns.org>
References: <20110421183727.GG15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211350310.5741@router.home>
 <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104280904240.15775@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, Christoph.

On Thu, Apr 28, 2011 at 09:11:20AM -0500, Christoph Lameter wrote:
> Sporadic erratic behavior exists today since any thread can add an
> abitrary number to its local counter while you are adding up all the per
> cpu differentials. If this happens just after you picked up the value then
> a single cpu can cause a high deviation. If multiple cpus do this then a
> high degree of deviation can even be had with todays implementation.

Yeah, but that's still something which is expected.  If the user is
adding/subtracing large number concurrently, sure.  What I'm concerned
about is adding unexpected deviation.  Currently, the _sum interface
basically provides basically the same level of expectedness (is this
even a word?) as atomic_t - the deviations are solely caused and
limited by concurrent updates.  After the proposed changes, one
concurrent updater doing +1 can cause @batch deviation.

> Can you show in some tests how the chance of deviations is increased? If
> at all then in some special sitations. Maybe others get better?

It's kinda obvious, isn't it?  Do relatively low freq (say, every
10ms) +1's and continuously do _sum().  Before, _sum() would never
deviate much from the real count.  After, there will be @batch jumps.
If you still need proof code, I would write it but please note that
I'm pretty backed up.

> The counters were always designed to be racy for performance reasons.
> Trying to serialize them goes against the design of these things. In order
> to increase accuracy you have to decrease the allowable delta in the per
> cpu differentials.
> 
> Looping over all differentials to get more accuracy is something that may
> not work as we have seen recently with the VM counters issues that caused
> bad behavior during reclaim.

Such users then shouldn't use _sum() - maybe rename it to
_very_slow_sum() if you're concerned about misusage.  percpu_counter()
is already used in filesystems to count free blocks and there are
times where atomic_t type accuracy is needed and _sum() achieves that.
The proposed changes break that.  Why do I need to say this over and
over again?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
