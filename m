Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97063900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:02:28 -0400 (EDT)
Date: Fri, 29 Apr 2011 09:02:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110429084424.GJ16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104290855060.7776@router.home>
References: <20110421183727.GG15988@htj.dyndns.org> <alpine.DEB.2.00.1104211350310.5741@router.home> <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org> <1304065171.3981.594.camel@sli10-conroe> <20110429084424.GJ16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2011, Tejun Heo wrote:

> > ok, I got your point. I'd agree there is sporadic erratic behaviors, but
> > I expect there is no problem here. We all agree the worst case is the
> > same before/after the change. Any program should be able to handle the
> > worst case, otherwise the program itself is buggy. Discussing a buggy
> > program is meaningless. After the change, something behavior is changed,
> > but the worst case isn't. So I don't think this is a big problem.
>
> If you really think that, go ahead and remove _sum(), really.  If you
> still can't see the difference between "reasonably accurate unless
> there's concurrent high frequency update" and "can jump on whatever",
> I can't help you.  Worst case is important to consider but that's not
> the only criterion you base your decisions on.

We agree it seems that _sum is a pretty attempt to be more accurate but
not really gets you total accuracy (atomic_t). Our experiences with adding
a _sum

> Think about it.  It becomes the difference between "oh yeah, while my
> crazy concurrent FS benchmark is running, free block count is an
> estimate but otherwise it's pretty accruate" and "holy shit, it jumped
> while there's almost nothing going on the filesystem".  It drastically
> limits both the usefulness of _sum() and thus the percpu counter and
> how much we can scale @batch on heavily loaded counters because it
> ends up directly affecting the accuracy of _sum().

free block count is always an estimate if it only uses percpu_counter
without other serialization. "Pretty accurate" is saying you feel good
about it. In fact the potential deviations are not that much different.

The problem with quietness arises because per_cpu_counter_add does not
have the time boundary that f.e. VM statistics have. Those fold the
differentials into the global sum every second or so.

It would be better to replace _sum() with a loop that adds the
differential and then zaps it. With the cmpxchg solution this is possible.


Could we do the handling here in the same way that vm stat per cpu
counters are done:

1. Bound the differential by time and size (we already have a batch notion
here but we need to add a time boundary. Run a function over all counters
every second or so that sums up the diffs).

2. Use lockless operations for differentials and atomics for globals to
make it scale well.

If someone wants more accuracy then we need the ability to dynamically set
the batch limit similar to what the vm statistics do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
