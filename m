Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9B46B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 19:58:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EE0B13EE081
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:58:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7D2A45DE50
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:58:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0A0645DE4D
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:58:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B168C1DB803B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:58:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 711041DB802F
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:58:39 +0900 (JST)
Date: Fri, 20 May 2011 08:51:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 3/3] memcg: add memory.numastat api for numa
 statistics
Message-Id: <20110520085152.e518ac71.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305826360-2167-3-git-send-email-yinghan@google.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 19 May 2011 10:32:40 -0700
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
> total=246594 N0=18225 N1=72025 N2=26378 N3=129966
> file=221728 N0=15030 N1=60804 N2=23238 N3=122656
> anon=21120 N0=2937 N1=7733 N2=3140 N3=7310
> 

Hmm ? this doesn't seem consistent....Isn't this log updated ?

Thanks,
-Kame

> change v3..v2:
> 1. calculate the "total" based on the per-memcg lru size instead of rss+cache.
> this makes the "total" value to be consistant w/ the per-node values follows
> after.
> 
> change v2..v1:
> 1. add also the file and anon pages on per-node distribution.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/memcontrol.c |  120 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 120 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e14677c..268d806 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1162,6 +1162,73 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  	return MEM_CGROUP_ZSTAT(mz, lru);
>  }
>  
> +
> +unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
> +						int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
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
> +unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
> +						int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
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
> +unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg, int nid)
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
> +unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
> +{
> +	u64 total = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_HIGH_MEMORY)
> +		total += mem_cgroup_node_nr_lru_pages(memcg, nid);
> +
> +	return total;
> +}
> +
>  struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone)
>  {
> @@ -4048,6 +4115,41 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
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
> +	return 0;
> +}
> +
>  static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  				 struct cgroup_map_cb *cb)
>  {
> @@ -4481,6 +4583,20 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
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
> @@ -4544,6 +4660,10 @@ static struct cftype mem_cgroup_files[] = {
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
