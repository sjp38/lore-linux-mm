Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A68426B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 10:16:55 -0500 (EST)
Date: Mon, 11 Feb 2013 16:16:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130211151649.GD19922@dhcp22.suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
 <1357235661-29564-5-git-send-email-mhocko@suse.cz>
 <20130208193318.GA15951@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130208193318.GA15951@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Fri 08-02-13 14:33:18, Johannes Weiner wrote:
[...]
> for each in hierarchy:
>   for each node:
>     for each zone:
>       for each reclaim priority:
> 
> every time a cgroup is destroyed.  I don't think such a hammer is
> justified in general, let alone for consolidating code a little.
> 
> Can we invalidate the position cache lazily?  Have a global "cgroup
> destruction" counter and store a snapshot of that counter whenever we
> put a cgroup pointer in the position cache.  We only use the cached
> pointer if that counter has not changed in the meantime, so we know
> that the cgroup still exists.

Currently we have:
rcu_read_lock()	// keeps cgroup links safe
	iter->iter_lock	// keeps selection exclusive for a specific iterator
	1) global_counter == iter_counter
	2) css_tryget(cached_memcg)  // check it is still alive
rcu_read_unlock()

What would protect us from races when css would disappear between 1 and
2?

css is invalidated from worker context scheduled from __css_put and it
is using dentry locking which we surely do not want to pull here. We
could hook into css_offline which is called with cgroup_mutex but we
cannot use this one here because it is no longer exported and Tejun
would kill us for that.
So we can add a new global memcg internal lock to do this atomically.
Ohh, this is getting uglier...
	
> It is pretty pretty imprecise and we invalidate the whole cache every
> time a cgroup is destroyed, but I think that should be okay. 

I am not sure this is OK because this gives an indirect way of
influencing reclaim in one hierarchy by another one which opens a door
for regressions (or malicious over-reclaim in the extreme case).
So I do not like this very much.

> If not, better ideas are welcome.

Maybe we could keep the counter per memcg but that would mean that we
would need to go up the hierarchy as well. We wouldn't have to go over
node-zone-priority cleanup so it would be much more lightweight.

I am not sure this is necessarily better than explicit cleanup because
it brings yet another kind of generation number to the game but I guess
I can live with it if people really thing the relaxed way is much
better.
What do you think about the patch below (untested yet)?
---
