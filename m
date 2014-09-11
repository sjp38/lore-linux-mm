Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5566B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:23:33 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so6334047pab.25
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:23:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id j4si341086pdb.62.2014.09.11.01.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 01:23:32 -0700 (PDT)
Date: Thu, 11 Sep 2014 12:23:11 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140911082311.GB4151@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
 <20140905082846.GA25641@esperanza>
 <5409C6BB.7060009@jp.fujitsu.com>
 <20140905160029.GF25641@esperanza>
 <540A4420.2030504@jp.fujitsu.com>
 <20140908110131.GA11812@esperanza>
 <540DB4EC.6060100@jp.fujitsu.com>
 <20140909103943.GA29897@esperanza>
 <54110339.6000702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <54110339.6000702@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 11, 2014 at 11:04:41AM +0900, Kamezawa Hiroyuki wrote:
> (2014/09/09 19:39), Vladimir Davydov wrote:
> 
> >>For your purpose, you need to implement your method in system-wide way.
> >>It seems crazy to set per-cgroup-anon-limit for avoding system-wide-oom.
> >>You'll need help of system-wide-cgroup-configuration-middleware even if
> >>you have a method in a cgroup. If you say logic should be in OS kernel,
> >>please implement it in a system wide logic rather than cgroup.
> >
> >What if on global pressure a memory cgroup exceeding its soft limit is
> >being reclaimed, but not fast enough, because it has a lot of anon
> >memory? The global OOM won't be triggered then, because there's still
> >progress, but the system will experience hard pressure due to the
> >reclaimer runs. How can we detect if we should kill the container or
> >not? It smells like one more heuristic to vmscan, IMO.
> 
> 
> That's you are trying to implement by per-cgroup-anon+swap-limit, the difference
> is heuristics by system designer at container creation or heuristics by kernel in
> the dynamic way.

anon+swap limit isn't a heuristic, it's a configuration!

The difference is that the user usually knows *minimal* requirements of
the app he's going to run in a container/VM. Basing on them, he buys a
container/VM with some predefined amount of RAM. From the whole system
POV it's suboptimal to set the hard limit for the container by the user
configuration, because there might be free memory, which could be used
for file caches and hence lower disk load. If we had anon+swap hard
limit, we could use it in conjunction with the soft limit instead of the
hard limit. That would be more efficient than VM-like sand-boxing though
still safe.

When I'm talking about in-kernel heuristics, I mean a pile of
hard-to-read functions with a bunch of obscure constants. This is much
worse than providing the user with a convenient and flexible interface.

> I said it should be done by system/cloud-container-scheduler based on notification.

Basically, it's unsafe to hand this out to userspace completely. The
system would be prone to DOS attacks from inside containers then.

> But okay, let me think of kernel help in global reclaim.
> 
>  - Assume "priority" is a value calculated by "usage - soft limit".
> 
>  - weighted kswapd/direct reclaim
>    => Based on priority of each threads/cgroup,  increase "wait" in direct reclaim
>       if it's contended.
>       Low prio container will sleep longer until memory contention is fixed.
> 
>  - weighted anon allocation
>    similar to above, if memory is contended, page fault speed should be weighted
>    based on priority(softlimit).
> 
>  - off cpu direct-reclaim
>    run direct recalim in workqueue with cpu mask. the cpu mask is a global setting
>    per numa node, which determines cpus available for being used to reclaim memory.
>    "How to wait" may affect the performance of system but this can allow masked cpus
>    to be used for more important jobs.

That's what I call a bunch of heuristics. And actually I don't see how
it'd help us against latency spikes caused by reclaimer runs, seems the
set is still incomplete :-/

For example, there are two cgroups, one having a huge soft limit excess
and full of anon memory and another not exceeding its soft limit but
using primarily clean file caches. This prioritizing/weighting stuff
would result in shrinking the first group first on global pressure,
though it's way slower than shrinking the second one. That means a
latency spike in other containers. The heuristics you proposed above
will only make it non-critical - the system will get over sooner or
later. However, it's still a kind of DOS, which anon+swap hard limit
would prevent.

Sorry, but I simply don't understand what would go wrong if we
substituted the current memsw (anon+file+swap) with anon+swap limit. As
I stated before it would be more flexible and logical:

On Tue, Sep 09, 2014 at 02:39:43PM +0400, Vladimir Davydov wrote:
> However, there's one thing, which made me start this discussion, and it
> still bothers me. It's about memsw.limit_in_bytes knob itself.
> 
> First, its value must be greater or equal to memory.limit_in_bytes.
> IMO, such a dependency in the user interface isn't great, but it isn't
> the worst thing. What is worse, there's only point in setting it to
> infinity if one wants to fully make use of soft limits as I pointed out
> earlier.
> 
> So, we have a userspace knob that suits only for strict sand-boxing when
> one wants to hard-limit the amount of memory and swap an app can use.
> When it comes to soft limits, you have to set it to infinity, and it'll
> still be accounted at the cost of performance, but without any purpose.
> It just seems meaningless to me.
> 
> Not counting that the knob itself is a kind of confusing IMO. memsw
> means memory+swap, so one would mistakenly think memsw.limit-mem.limit
> is the limit on swap usage, but that's wrong.
> 
> My point is that anon+swap accounting instead of the current
> anon+file+swap memsw implementation would be more flexible. We could
> still sandbox apps by setting hard anon+swap and memory limits, but it
> would also be possible to make use of it in "soft" environments. It
> wouldn't be mandatory though. If one doesn't like OOM, he can use
> threshold notifications to restart the container when it starts to
> behave badly. But if the user just doesn't want to bother about
> configuration or is OK with OOM-killer, he could set hard anon+swap
> limit. Besides, it would untie mem.limit knob from memsw.limit, which
> would make the user interface simpler and cleaner.
> 
> So, I think anon+swap limit would be more flexible than file+anon+swap
> limit we have now. Is there any use case where anon+swap and anon+file
> accounting couldn't satisfy the user requirements while the
> anon+file+swap and anon+file pair could?

I would appreciate if anybody could answer this.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
