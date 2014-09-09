Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C760F6B0036
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 06:39:58 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so974247pdj.8
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 03:39:58 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id km1si1607756pbd.191.2014.09.09.03.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 03:39:57 -0700 (PDT)
Date: Tue, 9 Sep 2014 14:39:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140909103943.GA29897@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
 <20140905082846.GA25641@esperanza>
 <5409C6BB.7060009@jp.fujitsu.com>
 <20140905160029.GF25641@esperanza>
 <540A4420.2030504@jp.fujitsu.com>
 <20140908110131.GA11812@esperanza>
 <540DB4EC.6060100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <540DB4EC.6060100@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 08, 2014 at 10:53:48PM +0900, Kamezawa Hiroyuki wrote:
> (2014/09/08 20:01), Vladimir Davydov wrote:
> >But OK, you don't like OOM on hitting anon+swap limit and propose to
> >introduce a kind of userspace notification instead, but the problem
> >actually isn't *WHAT* we should do on hitting anon+swap limit, but *HOW*
> >we should implement it (or should we implement it at all).
> 
> 
> I'm not sure you're aware of or not, "hardlimit" counter is too expensive
> for your purpose.
> 
> If I was you, I'll use some lightweight counter like percpu_counter() or
> memcg's event handling system.
> Did you see how threshold notifier or vmpressure works ? It's very light weight.

OK, after looking through the memory thresholds code and pondering the
problem a bit I tend to agree with you. We can tweak the notifiers to
trigger on anon+swap thresholds, handle them in userspace and do
whatever we like. At least for now, I don't see anything why this could
be worse than hard anon+swap limit except it requires more steps to
configure. Thank you for your patience while explaining this to me :-)

However, there's one thing, which made me start this discussion, and it
still bothers me. It's about memsw.limit_in_bytes knob itself.

First, its value must be greater or equal to memory.limit_in_bytes.
IMO, such a dependency in the user interface isn't great, but it isn't
the worst thing. What is worse, there's only point in setting it to
infinity if one wants to fully make use of soft limits as I pointed out
earlier.

So, we have a userspace knob that suits only for strict sand-boxing when
one wants to hard-limit the amount of memory and swap an app can use.
When it comes to soft limits, you have to set it to infinity, and it'll
still be accounted at the cost of performance, but without any purpose.
It just seems meaningless to me.

Not counting that the knob itself is a kind of confusing IMO. memsw
means memory+swap, so one would mistakenly think memsw.limit-mem.limit
is the limit on swap usage, but that's wrong.

My point is that anon+swap accounting instead of the current
anon+file+swap memsw implementation would be more flexible. We could
still sandbox apps by setting hard anon+swap and memory limits, but it
would also be possible to make use of it in "soft" environments. It
wouldn't be mandatory though. If one doesn't like OOM, he can use
threshold notifications to restart the container when it starts to
behave badly. But if the user just doesn't want to bother about
configuration or is OK with OOM-killer, he could set hard anon+swap
limit. Besides, it would untie mem.limit knob from memsw.limit, which
would make the user interface simpler and cleaner.

So, I think anon+swap limit would be more flexible than file+anon+swap
limit we have now. Is there any use case where anon+swap and anon+file
accounting couldn't satisfy the user requirements while the
anon+file+swap and anon+file pair could?

> >No matter which way we go, in-kernel OOM or userland notifications, we have to
> >*INTRODUCE ANON+SWAP ACCOUNTING* to achieve that so that on breaching a
> >predefined threshold we could invoke OOM or issue a userland
> >notification or both. And here goes the problem: there's anon+file and
> >anon+file+swap resource counters, but no anon+swap counter. To react on
> >anon+swap limit breaching, we must introduce one. I propose to *REUSE*
> >memsw instead by slightly modifying its meaning.
> >
> you can see "anon+swap"  via memcg's accounting.
> 
> >What we would get then is the ability to react on potentially
> >unreclaimable memory growth inside a container. What we would loose is
> >the current implementation of memory+swap limit, *BUT* we would still be
> >able to limit memory+swap usage by imposing limits on total memory and
> >anon+swap usage.
> >
> 
> I repeatedly say anon+swap "hardlimit" just means OOM. That's not buy.

anon+file+swap hardlimit eventually means OOM too :-/

> >>And your idea can't help swap-out caused by memory pressure comes from "zones".
> >
> >It would help limit swap-out to a sane value.
> >
> >
> >I'm sorry if I'm not clear or don't understand something that looks
> >trivial to you.
> >
> 
> It seems your purpose is to avoiding system-wide-oom-situation. Right ?

This is the purpose of any hard memory limit, including the current
implementation - avoiding global memory pressure in general and
system-wide OOM in particular.

> Implementing system-wide-oom-kill-avoidance logic in memcg doesn't
> sound good to me. It should work under system-wide memory management logic.
> If memcg can be a help for it, it will be good.
> 
> 
> For your purpose, you need to implement your method in system-wide way.
> It seems crazy to set per-cgroup-anon-limit for avoding system-wide-oom.
> You'll need help of system-wide-cgroup-configuration-middleware even if
> you have a method in a cgroup. If you say logic should be in OS kernel,
> please implement it in a system wide logic rather than cgroup.

What if on global pressure a memory cgroup exceeding its soft limit is
being reclaimed, but not fast enough, because it has a lot of anon
memory? The global OOM won't be triggered then, because there's still
progress, but the system will experience hard pressure due to the
reclaimer runs. How can we detect if we should kill the container or
not? It smells like one more heuristic to vmscan, IMO.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
