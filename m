Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id D7EBC6B007D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 21:32:48 -0400 (EDT)
Date: Tue, 16 Apr 2013 18:32:43 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: support hierarchical memory.numa_stats
Message-ID: <20130417013243.GB20835@dhcp22.suse.cz>
References: <1365458326-17091-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365458326-17091-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

I am sorry but I didn't get to this sooner.

On Mon 08-04-13 14:58:46, Ying Han wrote:
> The memory.numa_stat is not currently hierarchical. Memory charged to the
> children are not shown in parent's numa_stat.
> 
> This change adds the "hierarchical_" stats on top of all existing stats, and
> it includes the sum of all children's values in addition to the value of
> the memcg.

OK, I guess it makes some sense to be consistent with what we have in
memory.stat file. We are using total_ prefix there for most things
though (except for the limit which uses hierarchical). I am not sure
total_total sounds that great... So maybe hierarchical_ wouldn't be that
bad in the end.

Few comments bellow but other than that
Acked-by: Michal Hocko <mhocko@suse.cz>

[...]
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1177,6 +1177,32 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>  	     iter != NULL;				\
>  	     iter = mem_cgroup_iter(NULL, iter, NULL))
>  
> +static unsigned long
> +mem_cgroup_node_hierarchical_nr_lru_pages(struct mem_cgroup *memcg,
> +				int nid, unsigned int lru_mask)
> +{
> +	u64 total = 0;
> +	struct mem_cgroup *iter;
> +
> +	for_each_mem_cgroup_tree(iter, memcg)
> +		total += mem_cgroup_node_nr_lru_pages(iter, nid, lru_mask);
> +
> +	return total;
> +}
> +
> +static unsigned long
> +mem_cgroup_hierarchical_nr_lru_pages(struct mem_cgroup *memcg,
> +					unsigned int lru_mask)
> +{
> +	u64 total = 0;
> +	struct mem_cgroup *iter;
> +
> +	for_each_mem_cgroup_tree(iter, memcg)
> +	total += mem_cgroup_nr_lru_pages(iter, lru_mask);

Indentation

> +
> +	return total;
> +}
> +

These do not need to be defined for !CONFIG_NUMA. I do not think this is
generally usable functionality. Just move it memcg_numa_stat_show

>  void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  {
>  	struct mem_cgroup *memcg;
> @@ -5267,6 +5293,45 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
>  		seq_printf(m, " N%d=%lu", nid, node_nr);
>  	}
>  	seq_putc(m, '\n');
> +
> +	total_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL);
> +	seq_printf(m, "hierarchical_total=%lu", total_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr =
> +			mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
> +								LRU_ALL);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	file_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL_FILE);
> +	seq_printf(m, "hierarchical_file=%lu", file_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
> +				LRU_ALL_FILE);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	anon_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL_ANON);
> +	seq_printf(m, "hierarchical_anon=%lu", anon_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	unevictable_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg,
> +						BIT(LRU_UNEVICTABLE));
> +	seq_printf(m, "hierarchical_unevictable=%lu", unevictable_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
> +				BIT(LRU_UNEVICTABLE));
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
>  	return 0;
>  }
>  #endif /* CONFIG_NUMA */
> -- 
> 1.8.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
