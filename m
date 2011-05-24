Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C34C86B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:04:18 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p4OG014R004142
	for <linux-mm@kvack.org>; Wed, 25 May 2011 02:00:01 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4OG3ZU91376418
	for <linux-mm@kvack.org>; Wed, 25 May 2011 02:03:40 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4OG46q8025302
	for <linux-mm@kvack.org>; Wed, 25 May 2011 02:04:07 +1000
Date: Tue, 24 May 2011 21:16:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V5] memcg: add memory.numastat api for numa statistics
Message-ID: <20110524154644.GA3440@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1305928918-15207-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1305928918-15207-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-05-20 15:01:58]:

> The new API exports numa_maps per-memcg basis. This is a piece of useful
> information where it exports per-memcg page distribution across real numa
> nodes.
> 
> One of the usecase is evaluating application performance by combining this
> information w/ the cpu allocation to the application.
> 
> The output of the memory.numastat tries to follow w/ simiar format of numa_maps
> like:
> 
> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> 
> And we have per-node:
> total = file + anon + unevictable
> 
> $ cat /dev/cgroup/memory/memory.numa_stat
> total=250020 N0=87620 N1=52367 N2=45298 N3=64735
> file=225232 N0=83402 N1=46160 N2=40522 N3=55148
> anon=21053 N0=3424 N1=6207 N2=4776 N3=6646
> unevictable=3735 N0=794 N1=0 N2=0 N3=2941
> 
> This patch is based on mmotm-2011-05-06-16-39
> 
> change v5..v4:
> 1. disable the API non-NUMA kernel.
> 
> change v4..v3:
> 1. add per-node "unevictable" value.
> 2. change the functions to be static.
> 
> change v3..v2:
> 1. calculate the "total" based on the per-memcg lru size instead of rss+cache.
> this makes the "total" value to be consistant w/ the per-node values follows
> after.
> 
> change v2..v1:
> 1. add also the file and anon pages on per-node distribution.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |  155 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 155 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e14677c..ced414b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1162,6 +1162,93 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  	return MEM_CGROUP_ZSTAT(mz, lru);
>  }
> 
> +#ifdef CONFIG_NUMA
> +static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
> +							int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> +
> +	return ret;
> +}
> +
> +static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_file_lru_pages(memcg, nid);
> +
> +	return total;
> +}
> +
> +static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
> +							int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> +
> +	return ret;
> +}
> +
> +static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_anon_lru_pages(memcg, nid);
> +
> +	return total;
> +}
> +
> +static unsigned long
> +mem_cgroup_node_nr_unevictable_lru_pages(struct mem_cgroup *memcg, int nid)
> +{
> +	return mem_cgroup_get_zonestat_node(memcg, nid, LRU_UNEVICTABLE);
> +}
> +
> +static unsigned long
> +mem_cgroup_nr_unevictable_lru_pages(struct mem_cgroup *memcg)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_unevictable_lru_pages(memcg, nid);
> +
> +	return total;
> +}
> +
> +static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
> +							int nid)
> +{
> +	enum lru_list l;
> +	u64 total = 0;
> +
> +	for_each_lru(l)
> +		total += mem_cgroup_get_zonestat_node(memcg, nid, l);
> +
> +	return total;
> +}
> +
> +static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_lru_pages(memcg, nid);
> +
> +	return total;
> +}
> +#endif /* CONFIG_NUMA */
> +
>  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone)
>  {
> @@ -4048,6 +4135,51 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
>  		mem_cgroup_get_local_stat(iter, s);
>  }
> 
> +#ifdef CONFIG_NUMA
> +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
> +{
> +	int nid;
> +	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
> +	unsigned long node_nr;
> +	struct cgroup *cont = m->private;
> +	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
> +
> +	total_nr = mem_cgroup_nr_lru_pages(mem_cont);
> +	seq_printf(m, "total=%lu", total_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	file_nr = mem_cgroup_nr_file_lru_pages(mem_cont);
> +	seq_printf(m, "file=%lu", file_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_file_lru_pages(mem_cont, nid);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	anon_nr = mem_cgroup_nr_anon_lru_pages(mem_cont);
> +	seq_printf(m, "anon=%lu", anon_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_anon_lru_pages(mem_cont, nid);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	unevictable_nr = mem_cgroup_nr_unevictable_lru_pages(mem_cont);
> +	seq_printf(m, "unevictable=%lu", unevictable_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_unevictable_lru_pages(mem_cont,
> +									nid);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +	return 0;
> +}
> +#endif /* CONFIG_NUMA */
> +
>  static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  				 struct cgroup_map_cb *cb)
>  {
> @@ -4058,6 +4190,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  	memset(&mystat, 0, sizeof(mystat));
>  	mem_cgroup_get_local_stat(mem_cont, &mystat);
> 
> +
>  	for (i = 0; i < NR_MCS_STAT; i++) {
>  		if (i == MCS_SWAP && !do_swap_account)
>  			continue;
> @@ -4481,6 +4614,22 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	return 0;
>  }
> 
> +#ifdef CONFIG_NUMA
> +static const struct file_operations mem_control_numa_stat_file_operations = {
> +	.read = seq_read,
> +	.llseek = seq_lseek,
> +	.release = single_release,
> +};
> +

Do we need this?


> +static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
> +{
> +	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
> +
> +	file->f_op = &mem_control_numa_stat_file_operations;
> +	return single_open(file, mem_control_numa_stat_show, cont);
> +}
> +#endif /* CONFIG_NUMA */
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
> @@ -4544,6 +4693,12 @@ static struct cftype mem_cgroup_files[] = {
>  		.unregister_event = mem_cgroup_oom_unregister_event,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> +#ifdef CONFIG_NUMA
> +	{
> +		.name = "numa_stat",
> +		.open = mem_control_numa_stat_open,
> +	},
> +#endif

Can't we do this the way we do the stats file? Please see
mem_control_stat_show().

>  };
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> -- 
> 1.7.3.1
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
