Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 87ECD900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:18:24 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3678153fxm.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 07:18:21 -0700 (PDT)
Date: Fri, 29 Apr 2011 16:18:17 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110429141817.GN16552@htj.dyndns.org>
References: <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <1304065171.3981.594.camel@sli10-conroe>
 <20110429084424.GJ16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104290855060.7776@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104290855060.7776@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Apr 29, 2011 at 09:02:23AM -0500, Christoph Lameter wrote:
> On Fri, 29 Apr 2011, Tejun Heo wrote:
> We agree it seems that _sum is a pretty attempt to be more accurate but
> not really gets you total accuracy (atomic_t). Our experiences with adding
> a _sum

With concurrent updates, what is total accuracy anyway?  The order of
operations isn't defined.  Sure, atomic_t is serialized and in that
sense it might be totally accurate but without outer synchronization
the concurrent events it is counting aren't ordered.  Let's forget
about total accuracy.  I don't care and I don't think anyone should
care, but I do want reasonable output without out-of-place hiccups.

> free block count is always an estimate if it only uses percpu_counter
> without other serialization. "Pretty accurate" is saying you feel good
> about it. In fact the potential deviations are not that much different.

Well, I feel good for a reason - it doesn't hiccup on a single
touch(1) going on somewhere.

> 1. Bound the differential by time and size (we already have a batch notion
> here but we need to add a time boundary. Run a function over all counters
> every second or so that sums up the diffs).
> 
> 2. Use lockless operations for differentials and atomics for globals to
> make it scale well.
> 
> If someone wants more accuracy then we need the ability to dynamically set
> the batch limit similar to what the vm statistics do.

So, if you can remove _sum() by doing the above without introducing
excessive complexity or penalizing use cases which might not have too
much commonality with vmstat, by all means, but please pay attention
to the current users.  Actually take a look at them.

Also, if someone is gonna put considerable amount of effort into it,
please also invest some time into showing actual performance benefits,
or at least possibility of actual benefits.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
