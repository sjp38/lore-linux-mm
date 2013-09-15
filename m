Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AB2A06B0089
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 15:04:11 -0400 (EDT)
Date: Sun, 15 Sep 2013 15:04:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2 v3] memcg: support hierarchical memory.numa_stats
Message-ID: <20130915190401.GC3278@cmpxchg.org>
References: <1378362539-18100-1-git-send-email-gthelen@google.com>
 <1378362539-18100-2-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378362539-18100-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hughd@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>

Hello Greg!

On Wed, Sep 04, 2013 at 11:28:59PM -0700, Greg Thelen wrote:
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -571,15 +571,19 @@ an memcg since the pages are allowed to be allocated from any physical
>  node.  One of the use cases is evaluating application performance by
>  combining this information with the application's CPU allocation.
>  
> -We export "total", "file", "anon" and "unevictable" pages per-node for
> -each memcg.  The ouput format of memory.numa_stat is:
> +Each memcg's numa_stat file includes "total", "file", "anon" and "unevictable"
> +per-node page counts including "hierarchical_<counter>" which sums of all
> +hierarchical children's values in addition to the memcg's own value.

"[...] which sums UP [...]"?

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5394,6 +5394,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
>  	int nid;
>  	unsigned long nr;
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	struct mem_cgroup *iter;
>  
>  	for (stat = stats; stat->name; stat++) {
>  		nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
> @@ -5406,6 +5407,21 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
>  		seq_putc(m, '\n');
>  	}
>  
> +	for (stat = stats; stat->name; stat++) {

Move the struct mem_cgroup *iter declaration here?

> +		nr = 0;
> +		for_each_mem_cgroup_tree(iter, memcg)
> +			nr += mem_cgroup_nr_lru_pages(iter, stat->lru_mask);
> +		seq_printf(m, "hierarchical_%s=%lu", stat->name, nr);
> +		for_each_node_state(nid, N_MEMORY) {
> +			nr = 0;
> +			for_each_mem_cgroup_tree(iter, memcg)
> +				nr += mem_cgroup_node_nr_lru_pages(
> +					iter, nid, stat->lru_mask);
> +			seq_printf(m, " N%d=%lu", nid, nr);
> +		}
> +		seq_putc(m, '\n');
> +	}
> +
>  	return 0;
>  }
>  #endif /* CONFIG_NUMA */

Rest looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
