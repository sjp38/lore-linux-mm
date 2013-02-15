Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id EB4C26B000E
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 03:20:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 85AD83EE0BC
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:20:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 68CE945DE5D
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:20:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 414CC45DE5C
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:20:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D2BF1DB8052
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:20:03 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CAE6B1DB8049
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:20:02 +0900 (JST)
Message-ID: <511DEF94.1080709@jp.fujitsu.com>
Date: Fri, 15 Feb 2013 17:19:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/6] memcg: relax memcg iter caching
References: <1360848396-16564-1-git-send-email-mhocko@suse.cz> <1360848396-16564-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1360848396-16564-4-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

(2013/02/14 22:26), Michal Hocko wrote:
> Now that per-node-zone-priority iterator caches memory cgroups rather
> than their css ids we have to be careful and remove them from the
> iterator when they are on the way out otherwise they might live for
> unbounded amount of time even though their group is already gone (until
> the global/targeted reclaim triggers the zone under priority to find out
> the group is dead and let it to find the final rest).
> 
> We can fix this issue by relaxing rules for the last_visited memcg.
> Instead of taking a reference to the css before it is stored into
> iter->last_visited we can just store its pointer and track the number of
> removed groups from each memcg's subhierarchy.
> 
> This number would be stored into iterator everytime when a memcg is
> cached. If the iter count doesn't match the curent walker root's one we
> will start from the root again. The group counter is incremented upwards
> the hierarchy every time a group is removed.
> 
> The iter_lock can be dropped because racing iterators cannot leak
> the reference anymore as the reference count is not elevated for
> last_visited when it is cached.
> 
> Locking rules got a bit complicated by this change though. The iterator
> primarily relies on rcu read lock which makes sure that once we see
> a valid last_visited pointer then it will be valid for the whole RCU
> walk. smp_rmb makes sure that dead_count is read before last_visited
> and last_dead_count while smp_wmb makes sure that last_visited is
> updated before last_dead_count so the up-to-date last_dead_count cannot
> point to an outdated last_visited. css_tryget then makes sure that
> the last_visited is still alive in case the iteration races with the
> cached group removal (css is invalidated before mem_cgroup_css_offline
> increments dead_count).
> 
> In short:
> mem_cgroup_iter
>   rcu_read_lock()
>   dead_count = atomic_read(parent->dead_count)
>   smp_rmb()
>   if (dead_count != iter->last_dead_count)
>   	last_visited POSSIBLY INVALID -> last_visited = NULL
>   if (!css_tryget(iter->last_visited))
>   	last_visited DEAD -> last_visited = NULL
>   next = find_next(last_visited)
>   css_tryget(next)
>   css_put(last_visited) 	// css would be invalidated and parent->dead_count
>   			// incremented if this was the last reference
>   iter->last_visited = next
>   smp_wmb()
>   iter->last_dead_count = dead_count
>   rcu_read_unlock()
> 
> cgroup_rmdir
>   cgroup_destroy_locked
>    atomic_add(CSS_DEACT_BIAS, &css->refcnt) // subsequent css_tryget fail
>     mem_cgroup_css_offline
>      mem_cgroup_invalidate_reclaim_iterators
>       while(parent = parent_mem_cgroup)
>       	atomic_inc(parent->dead_count)
>    css_put(css) // last reference held by cgroup core
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Original-idea-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

interesting. Thank you for your hard works.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
