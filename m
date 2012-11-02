Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E35706B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 03:50:43 -0400 (EDT)
Message-ID: <50937B48.5010200@parallels.com>
Date: Fri, 2 Nov 2012 11:50:32 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 11/29] memcg: allow a memcg with kmem charges to be
 destructed.
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-12-git-send-email-glommer@parallels.com> <20121101170539.2e09dc8e.akpm@linux-foundation.org>
In-Reply-To: <20121101170539.2e09dc8e.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman
 Souhlal <suleiman@google.com>

On 11/02/2012 04:05 AM, Andrew Morton wrote:
> On Thu,  1 Nov 2012 16:07:27 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> Because the ultimate goal of the kmem tracking in memcg is to track slab
>> pages as well, we can't guarantee that we'll always be able to point a
>> page to a particular process, and migrate the charges along with it -
>> since in the common case, a page will contain data belonging to multiple
>> processes.
>>
>> Because of that, when we destroy a memcg, we only make sure the
>> destruction will succeed by discounting the kmem charges from the user
>> charges when we try to empty the cgroup.
> 
> There was a significant conflict with the sched/numa changes in
> linux-next, which I resolved as below.  Please check it.
> 
> static int mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
> {
> 	struct cgroup *cgrp = memcg->css.cgroup;
> 	int node, zid;
> 	u64 usage;
> 
> 	do {
> 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
> 			return -EBUSY;
> 		/* This is for making all *used* pages to be on LRU. */
> 		lru_add_drain_all();
> 		drain_all_stock_sync(memcg);
> 		mem_cgroup_start_move(memcg);
> 		for_each_node_state(node, N_HIGH_MEMORY) {
> 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> 				enum lru_list lru;
> 				for_each_lru(lru) {
> 					mem_cgroup_force_empty_list(memcg,
> 							node, zid, lru);
> 				}
> 			}
> 		}
> 		mem_cgroup_end_move(memcg);
> 		memcg_oom_recover(memcg);
> 		cond_resched();
> 
> 		/*
> 		 * Kernel memory may not necessarily be trackable to a specific
> 		 * process. So they are not migrated, and therefore we can't
> 		 * expect their value to drop to 0 here.
> 		 * Having res filled up with kmem only is enough.
> 		 *
> 		 * This is a safety check because mem_cgroup_force_empty_list
> 		 * could have raced with mem_cgroup_replace_page_cache callers
> 		 * so the lru seemed empty but the page could have been added
> 		 * right after the check. RES_USAGE should be safe as we always
> 		 * charge before adding to the LRU.
> 		 */
> 		usage = res_counter_read_u64(&memcg->res, RES_USAGE) -
> 			res_counter_read_u64(&memcg->kmem, RES_USAGE);
> 	} while (usage > 0);
> 
> 	return 0;
> }
> 
Andrew,

It looks fine.

One thing: Open code reading makes very difficult to spot which exactly
the conflict is. Any chance you could send those in some kind of diff
format?

In this case, it appears to me that the reason for the conflict is that
the loop conditional "while (usage > 0 || ret)" was changed to "while
(usage > 0)". Being this the case, and because kmemcg has no business
with that "ret" value, this resolution is appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
