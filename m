Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 25E306B0026
	for <linux-mm@kvack.org>; Thu, 19 May 2011 02:31:43 -0400 (EDT)
Date: Thu, 19 May 2011 15:22:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa
 statistics
Message-Id: <20110519152206.1dac20af.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1305766511-11469-2-git-send-email-yinghan@google.com>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
	<1305766511-11469-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, 18 May 2011 17:55:11 -0700
Ying Han <yinghan@google.com> wrote:

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
> 
> $ cat /dev/cgroup/memory/memory.numa_stat
> total=317674 N0=101850 N1=72552 N2=30120 N3=113142
> file=288219 N0=98046 N1=59220 N2=23578 N3=107375
> anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
> 
> Note: I noticed <total pages> is not equal to the sum of the rest of counters.
> I might need to change the way get that counter, comments are welcomed.
> 
Isn't it just because <total pages>(mem_cgroup_local_usage()) includes pages
which are not on any LRU, while other counters doesn't ?

> change v2..v1:
> 1. add also the file and anon pages on per-node distribution.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/memcontrol.c |  109 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 109 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index da183dc..cffc3a6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1162,6 +1162,62 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  	return MEM_CGROUP_ZSTAT(mz, lru);
>  }
>  
> +unsigned long mem_cgroup_node_nr_file_pages(struct mem_cgroup *memcg, int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_node_nr_anon_pages(struct mem_cgroup *memcg, int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
> +						int nid, bool file)
> +{
> +	if (file)
> +		return mem_cgroup_node_nr_file_pages(memcg, nid);
> +	else
> +		return mem_cgroup_node_nr_anon_pages(memcg, nid);
> +}
> +
> +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg, bool file)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_lru_pages(memcg, nid, file);
> +
> +	return total;
> +}
> +
Can these functions defined as "static" ?

> +unsigned long mem_cgroup_node_nr_pages(struct mem_cgroup *memcg, int nid)
> +{
> +	int zid;
> +	struct mem_cgroup_per_zone *mz;
> +	enum lru_list l;
> +	u64 total = 0;
> +
> +	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +		for_each_lru(l)
> +			total += MEM_CGROUP_ZSTAT(mz, l);
> +	}
> +
> +	return total;
> +}
> +
ditto.
And I think this function can be implemented by using mem_cgroup_get_zonestat_node().

	for_each_lru(l)
		total += mem_cgroup_get_zonestat_node(memcg, nid, l);

As KAMEZAWA-san posted a fix already, mem_cgroup_get_zonestat_node() must be fixed first.


Thanks,
Daisuke Nishimura.

>  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone)
>  {
> @@ -4048,6 +4104,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
>  		mem_cgroup_get_local_stat(iter, s);
>  }
>  
> +static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
> +{
> +	int nid;
> +	unsigned long total_nr, file_nr, anon_nr;
> +	unsigned long node_nr;
> +	struct cgroup *cont = m->private;
> +	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
> +
> +	total_nr = mem_cgroup_local_usage(mem_cont);
> +	seq_printf(m, "total=%lu", total_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_pages(mem_cont, nid);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	file_nr = mem_cgroup_nr_lru_pages(mem_cont, 1);
> +	seq_printf(m, "file=%lu", file_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, 1);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	anon_nr = mem_cgroup_nr_lru_pages(mem_cont, 0);
> +	seq_printf(m, "anon=%lu", anon_nr);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, 0);
> +		seq_printf(m, " N%d=%lu", nid, node_nr);
> +	}
> +	seq_putc(m, '\n');
> +
> +	return 0;
> +}
> +
>  static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  				 struct cgroup_map_cb *cb)
>  {
> @@ -4481,6 +4572,20 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> +static const struct file_operations mem_control_numa_stat_file_operations = {
> +	.read = seq_read,
> +	.llseek = seq_lseek,
> +	.release = single_release,
> +};
> +
> +static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
> +{
> +	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
> +
> +	file->f_op = &mem_control_numa_stat_file_operations;
> +	return single_open(file, mem_control_numa_stat_show, cont);
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
> @@ -4544,6 +4649,10 @@ static struct cftype mem_cgroup_files[] = {
>  		.unregister_event = mem_cgroup_oom_unregister_event,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> +	{
> +		.name = "numa_stat",
> +		.open = mem_control_numa_stat_open,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
