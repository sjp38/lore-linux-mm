Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 331206B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 12:21:31 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so175254397wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:21:31 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id v195si5732673wmv.20.2015.12.15.09.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 09:21:29 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id l126so3969147wml.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 09:21:29 -0800 (PST)
Date: Tue, 15 Dec 2015 18:21:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151215172127.GC27880@dhcp22.suse.cz>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <20151214194258.GH28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214194258.GH28521@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 14-12-15 22:42:58, Vladimir Davydov wrote:
> On Mon, Dec 14, 2015 at 04:30:37PM +0100, Michal Hocko wrote:
> > On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
> > > In the legacy hierarchy we charge memsw, which is dubious, because:
> > > 
> > >  - memsw.limit must be >= memory.limit, so it is impossible to limit
> > >    swap usage less than memory usage. Taking into account the fact that
> > >    the primary limiting mechanism in the unified hierarchy is
> > >    memory.high while memory.limit is either left unset or set to a very
> > >    large value, moving memsw.limit knob to the unified hierarchy would
> > >    effectively make it impossible to limit swap usage according to the
> > >    user preference.
> > > 
> > >  - memsw.usage != memory.usage + swap.usage, because a page occupying
> > >    both swap entry and a swap cache page is charged only once to memsw
> > >    counter. As a result, it is possible to effectively eat up to
> > >    memory.limit of memory pages *and* memsw.limit of swap entries, which
> > >    looks unexpected.
> > > 
> > > That said, we should provide a different swap limiting mechanism for
> > > cgroup2.
> > > This patch adds mem_cgroup->swap counter, which charges the actual
> > > number of swap entries used by a cgroup. It is only charged in the
> > > unified hierarchy, while the legacy hierarchy memsw logic is left
> > > intact.
> > 
> > I agree that the previous semantic was awkward. The problem I can see
> > with this approach is that once the swap limit is reached the anon
> > memory pressure might spill over to other and unrelated memcgs during
> > the global memory pressure. I guess this is what Kame referred to as
> > anon would become mlocked basically. This would be even more of an issue
> > with resource delegation to sub-hierarchies because nobody will prevent
> > setting the swap amount to a small value and use that as an anon memory
> > protection.
> 
> AFAICS such anon memory protection has a side-effect: real-life
> workloads need page cache to run smoothly (at least for mapping
> executables). Disabling swapping would switch pressure to page caches,
> resulting in performance degradation. So, I don't think per memcg swap
> limit can be abused to boost your workload on an overcommitted system.

Well, you can trash on the page cache which could slow down the workload
but the executable pages get an additional protection so this might be
not sufficient and still trigger a massive disruption on the global level.

> If you mean malicious users, well, they already have plenty ways to eat
> all available memory up to the hard limit by creating unreclaimable
> kernel objects.
> 
> Anyway, if you don't trust a container you'd better set the hard memory
> limit so that it can't hurt others no matter what it runs and how it
> tweaks its sub-tree knobs.

I completely agree that malicious/untrusted users absolutely have to
be capped by the hard limit. Then the separate swap limit would work
for sure. But I am less convinced about usefulness of the rigid (to
the global memory pressure) swap limit without the hard limit. All the
memory that could have been swapped out will make a memory pressure to
the rest of the system without being punished for it too much. Memcg
is allowed to grow over the high limit (in the current implementation)
without any way to shrink back in other words.

My understanding was that the primary use case for the swap limit is to
handle potential (not only malicious but also unexpectedly misbehaving
application) anon memory consumption runaways more gracefully without
the massive disruption on the global level. I simply didn't see swap
space partitioning as important enough because an alternative to swap
usage is to consume primary memory which is a more precious resource
IMO. Swap storage is really cheap and runtime expandable resource which
is not the case for the primary memory in general. Maybe there are other
use cases I am not aware of, though. Do you want to guarantee the swap
availability?

Just to make it clear. I am not against the new way of the swap
accounting. It is much more clear then the previous one. I am just
worried it allows for an easy misconfiguration and we do not have any
measures to help the global system healthiness. I am OK with the patch
if we document the risk for now. I still think we will end up doing some
heuristic to throttle for a large unreclaimable high limit excess in the
future but I agree this shouldn't be the prerequisite.

> ...
> > My question now is. Is the knob usable/useful even without additional
> > heuristics? Do we want to protect swap space so rigidly that a swap
> > limited memcg can cause bigger problems than without the swap limit
> > globally?
> 
> Hmm, I don't see why problems might get bigger with per memcg swap limit
> than w/o it.

because the reclaim fairness between different memcg hierarchies will be
severely affected.

> W/o swap limit, a memcg can eat all swap space on the host
> and disable swapping for everyone, not just for itself alone.

this is true of course but this is not very much different from pushing
everybody else to the swap while eating the unreclaimable anonymous
memory and eventually hit the OOM killer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
