Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA2A6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 07:01:49 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so4509051pad.34
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 04:01:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c16si17113451pdk.131.2014.09.08.04.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Sep 2014 04:01:48 -0700 (PDT)
Date: Mon, 8 Sep 2014 15:01:31 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140908110131.GA11812@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
 <20140905082846.GA25641@esperanza>
 <5409C6BB.7060009@jp.fujitsu.com>
 <20140905160029.GF25641@esperanza>
 <540A4420.2030504@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <540A4420.2030504@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Sep 06, 2014 at 08:15:44AM +0900, Kamezawa Hiroyuki wrote:
> As you noticed, hitting anon+swap limit just means oom-kill.
> My point is that using oom-killer for "server management" just seems crazy.
> 
> Let my clarify things. your proposal was.
>  1. soft-limit will be a main feature for server management.
>  2. Because of soft-limit, global memory reclaim runs.
>  3. Using swap at global memory reclaim can cause poor performance.
>  4. So, making use of OOM-Killer for avoiding swap.
> 
> I can't agree "4". I think
> 
>  - don't configure swap.

Suppose there are two containers, each having soft limit set to 50% of
total system RAM. One of the containers eats 90% of the system RAM by
allocating anonymous pages. Another starts using file caches and wants
more than 10% of RAM to work w/o issuing disk reads. So what should we
do then? We won't be able to shrink the first container to its soft
limit, because there's no swap. Leaving it as is would be unfair from
the second container's point of view. Kill it? But the whole system is
going OK, because the working set of the second container is easily
shrinkable. Besides there may be some progress in shrinking file caches
from the first container.

>  - use zram

In fact this isn't different from the previous proposal (working w/o
swap). ZRAM only compresses data while still storing them in RAM so we
eventually may get into a situation where almost all RAM is full of
compressed anon pages.

>  - use SSD for swap

Such a requirement might be OK in enterprise, but forcing SMB to update
their hardware to run a piece of software is a no go. And again, SSD
isn't infinite, we may use it up.

> Or
>  - provide a way to notify usage of "anon+swap" to container management software.
> 
>    Now we have "vmpressure". Container management software can kill or respawn container
>    with using user-defined policy for avoidng swap.
> 
>    If you don't want to run kswapd at all, threshold notifier enhancement may be required.
> 
> /proc/meminfo provides total number of ANON/CACHE pages.
> Many things can be done in userland.

AFAIK OOM-in-userspace-handling has been discussed many times, but
there's still no agreement upon it. Basically it isn't reliable, because
it can lead to a deadlock if the userspace handler won't be able to
allocate memory to proceed or will get stuck in some other way. IMO
there must be in-kernel OOM-handling as a last resort anyway. And
actually we already have one - we may kill processes when they hit the
memsw limit.

But OK, you don't like OOM on hitting anon+swap limit and propose to
introduce a kind of userspace notification instead, but the problem
actually isn't *WHAT* we should do on hitting anon+swap limit, but *HOW*
we should implement it (or should we implement it at all). No matter
which way we go, in-kernel OOM or userland notifications, we have to
*INTRODUCE ANON+SWAP ACCOUNTING* to achieve that so that on breaching a
predefined threshold we could invoke OOM or issue a userland
notification or both. And here goes the problem: there's anon+file and
anon+file+swap resource counters, but no anon+swap counter. To react on
anon+swap limit breaching, we must introduce one. I propose to *REUSE*
memsw instead by slightly modifying its meaning.

What we would get then is the ability to react on potentially
unreclaimable memory growth inside a container. What we would loose is
the current implementation of memory+swap limit, *BUT* we would still be
able to limit memory+swap usage by imposing limits on total memory and
anon+swap usage.

> And your idea can't help swap-out caused by memory pressure comes from "zones".

It would help limit swap-out to a sane value.


I'm sorry if I'm not clear or don't understand something that looks
trivial to you.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
