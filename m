Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF648D0047
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:20:41 -0400 (EDT)
Date: Thu, 31 Mar 2011 15:20:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
Message-ID: <20110331132036.GA7692@tiehlicka.suse.cz>
References: <1301532498-20309-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301532498-20309-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed 30-03-11 17:48:18, Ying Han wrote:
> In memory controller, we do both targeting reclaim and global reclaim. The
> later one walks through the global lru which links all the allocated pages
> on the system. It breaks the memory isolation since pages are evicted
> regardless of their memcg owners. This patch takes pages off global lru
> as long as they are added to per-memcg lru.
> 
> Memcg and cgroup together provide the solution of memory isolation where
> multiple cgroups run in parallel without interfering with each other. In
> vm, memory isolation requires changes in both page allocation and page
> reclaim. The current memcg provides good user page accounting, but need
> more work on the page reclaim.
> 
> In an over-committed machine w/ 32G ram, here is the configuration:
> 
> cgroup-A/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> cgroup-B/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> 
> 1) limit_in_bytes is the hard_limit where process will be throttled or OOM
> killed by going over the limit.
> 2) memory between soft_limit and limit_in_bytes are best-effort. soft_limit
> provides "guarantee" in some sense.
> 
> Then, it is easy to generate the following senario where:
> 
> cgroup-A/  -- usage_in_bytes = 20G
> cgroup-B/  -- usage_in_bytes = 12G
> 
> The global memory pressure triggers while cgroup-A keep allocating memory. At
> this point, pages belongs to cgroup-B can be evicted from global LRU.
> 
> We do have per-memcg targeting reclaim including per-memcg background reclaim
> and soft_limit reclaim. Both of them need some improvement, and regardless we
> still need this patch since it breaks isolation.

The patch basically does what I am looking for except it is more
"radical" in that regard that it basically makes all (soft) unlimitted
groups isolated (and this is the default IIUC) which makes things more
complicated.
While I am working on the opt-in approach with an expectation that one
who configures it knows what he is doing this approach, on other hand,
expects that all the cgroups behave and that limits are reasonable.

Btw. This implementation doesn't enable cgroups which would be just for
throttling memory consumption where page/swap out is not hurting that
much. Setting soft_limit very low would trigger per-cgroup too early
while having it high, on the other hand, would prevent from reclaim
if kernel itself is short on memory. Sometimes it might be valuable to
keep pages on the global LRU because global picture is important as
well.

[...]
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4407dd0..9079e2e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -880,7 +880,7 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
>  	if (mem_cgroup_is_root(pc->mem_cgroup))
>  		return;
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> -	list_move_tail(&pc->lru, &mz->lists[lru]);
> +	list_move(&page->lru, &mz->lists[lru]);

why not list_move_tail?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
