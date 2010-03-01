Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1C5956B0078
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 05:24:22 -0500 (EST)
Date: Mon, 1 Mar 2010 11:24:14 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100301102414.GA2087@linux>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
 <1267224751-6382-2-git-send-email-arighi@develer.com>
 <20100301100910.1d8bd486.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100301100910.1d8bd486.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Suleiman Souhlal <suleiman@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 10:09:10AM +0900, KAMEZAWA Hiroyuki wrote:
> > +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> > +			enum mem_cgroup_dirty_param idx)
> > +{
> > +	unsigned long ret;
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> 
> do we need lock ?

I think yes. Not for a single param, but when we change dirty_ratio we
need to disable dirty_bytes (set ot 0) atomically, and vice versa.

The same for dirty_background_ratio/dirty_background_bytes.

> 
> 
> > +	switch (idx) {
> > +	case MEM_CGROUP_DIRTY_RATIO:
> > +		ret = memcg->dirty_ratio;
> > +		break;
> > +	case MEM_CGROUP_DIRTY_BYTES:
> > +		ret = memcg->dirty_bytes;
> > +		break;
> > +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> > +		ret = memcg->dirty_background_ratio;
> > +		break;
> > +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> > +		ret = memcg->dirty_background_bytes;
> > +		break;
> > +	default:
> > +		VM_BUG_ON(1);
> > +	}
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return ret;
> > +}
> > +
> > +long mem_cgroup_dirty_ratio(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	long ret = vm_dirty_ratio;
> > +
> > +	if (mem_cgroup_disabled())
> > +		goto out;
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> 
> please add some excuse comment here. As...
> 
> /*
>  * It's possible that "current" may be moved to other cgroup while
>  * we access cgroup. But precise check is meaningless because the task
>  * can be moved after our access and writeback tends to take long time.
>  * At least, "memcg" will not be freed under rcu_read_lock().
>  */

OK.

> 
> 
> > +	if (likely(memcg))
> > +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> > +	rcu_read_unlock();
> > +out:
> > +	return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_dirty_bytes(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	unsigned long ret = vm_dirty_bytes;
> > +
> > +	if (mem_cgroup_disabled())
> > +		goto out;
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (likely(memcg))
> > +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> > +	rcu_read_unlock();
> > +out:
> > +	return ret;
> > +}
> > +
> > +long mem_cgroup_dirty_background_ratio(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	long ret = dirty_background_ratio;
> > +
> > +	if (mem_cgroup_disabled())
> > +		goto out;
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (likely(memcg))
> > +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> > +	rcu_read_unlock();
> > +out:
> > +	return ret;
> > +}
> > +
> > +unsigned long mem_cgroup_dirty_background_bytes(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	unsigned long ret = dirty_background_bytes;
> > +
> > +	if (mem_cgroup_disabled())
> > +		goto out;
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (likely(memcg))
> > +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +	rcu_read_unlock();
> > +out:
> > +	return ret;
> > +}
> > +
> Hmm, how about
> 
> 	memcg->dirty_params[XXXX]
> and access by memcg->dirt_params[MEM_CGROUP_DIRTY_BACKGROUND_BYTES]] ?
> 
> Then, we don't need to have 4 functsion in the same implementation.

Agreed. I like this.

> 
> 
> > +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> > +				enum mem_cgroup_page_stat_item item)
> > +{
> > +	s64 ret;
> > +
> > +	switch (item) {
> > +	case MEMCG_NR_DIRTYABLE_PAGES:
> > +		ret = res_counter_read_u64(&memcg->res, RES_LIMIT) -
> > +			res_counter_read_u64(&memcg->res, RES_USAGE);
> > +		/* Translate free memory in pages */
> > +		ret >>= PAGE_SHIFT;
> > +		ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
> > +			mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
> > +			mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON) +
> > +			mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
> > +		break;
> Hmm, is this correct in swapless case ?

Something like this should be better:

static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
{
	return do_swap_account ?
		res_counter_read_u64(&memcg->memsw, RES_LIMIT) :
		nr_swap_pages > 0;
}
...
	ret +=	mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
		mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
	if (mem_cgroup_can_swap(memcg))
		ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
			mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);

> 
> 
> > +	case MEMCG_NR_RECLAIM_PAGES:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
> > +			mem_cgroup_read_stat(memcg,
> > +					MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +		break;
> > +	case MEMCG_NR_WRITEBACK:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
> > +		break;
> > +	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> > +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
> > +			mem_cgroup_read_stat(memcg,
> > +				MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +		break;
> > +	default:
> > +		ret = 0;
> > +		WARN_ON_ONCE(1);
> > +	}
> > +	return ret;
> > +}
> > +
> > +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> > +{
> > +	struct mem_cgroup_page_stat *stat = (struct mem_cgroup_page_stat *)data;
> > +
> > +	stat->value += mem_cgroup_get_local_page_stat(mem, stat->item);
> > +	return 0;
> > +}
> > +
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +	struct mem_cgroup_page_stat stat = {};
> > +	struct mem_cgroup *memcg;
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (memcg) {
> > +		/*
> > +		 * Recursively evaulate page statistics against all cgroup
> > +		 * under hierarchy tree
> > +		 */
> > +		stat.item = item;
> > +		mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> > +	} else
> > +		stat.value = -ENOMEM;
> > +	rcu_read_unlock();
> > +
> > +	return stat.value;
> > +}
> > +
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >  	int *val = data;
> > @@ -1263,10 +1419,10 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >  
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update memory cgroup statistics.
> >   */
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> > @@ -1286,7 +1442,8 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
> >  	/*
> >  	 * Preemption is already disabled. We can use __this_cpu_xxx
> >  	 */
> > -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> > +	VM_BUG_ON(idx >= MEM_CGROUP_STAT_NSTATS);
> > +	__this_cpu_add(mem->stat->count[idx], val);
> >  
> >  done:
> >  	unlock_page_cgroup(pc);
> > @@ -3033,6 +3190,10 @@ enum {
> >  	MCS_PGPGIN,
> >  	MCS_PGPGOUT,
> >  	MCS_SWAP,
> > +	MCS_FILE_DIRTY,
> > +	MCS_WRITEBACK,
> > +	MCS_WRITEBACK_TEMP,
> > +	MCS_UNSTABLE_NFS,
> >  	MCS_INACTIVE_ANON,
> >  	MCS_ACTIVE_ANON,
> >  	MCS_INACTIVE_FILE,
> > @@ -3055,6 +3216,10 @@ struct {
> >  	{"pgpgin", "total_pgpgin"},
> >  	{"pgpgout", "total_pgpgout"},
> >  	{"swap", "total_swap"},
> > +	{"filedirty", "dirty_pages"},
> > +	{"writeback", "writeback_pages"},
> > +	{"writeback_tmp", "writeback_temp_pages"},
> > +	{"nfs", "nfs_unstable"},
> >  	{"inactive_anon", "total_inactive_anon"},
> >  	{"active_anon", "total_active_anon"},
> >  	{"inactive_file", "total_inactive_file"},
> > @@ -3083,6 +3248,14 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
> >  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
> >  	}
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
> > +	s->stat[MCS_FILE_DIRTY] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK);
> > +	s->stat[MCS_WRITEBACK] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK_TEMP);
> > +	s->stat[MCS_WRITEBACK_TEMP] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +	s->stat[MCS_UNSTABLE_NFS] += val;
> >  
> >  	/* per zone stat */
> >  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> > @@ -3467,6 +3640,100 @@ unlock:
> >  	return ret;
> >  }
> >  
> > +static u64 mem_cgroup_dirty_ratio_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_ratio_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	if ((cgrp->parent == NULL) || (val > 100))
> > +		return -EINVAL;
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	memcg->dirty_ratio = val;
> > +	memcg->dirty_bytes = 0;
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return 0;
> > +}
> > +
> > +static u64 mem_cgroup_dirty_bytes_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	if (cgrp->parent == NULL)
> > +		return -EINVAL;
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	memcg->dirty_ratio = 0;
> > +	memcg->dirty_bytes = val;
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_ratio_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_ratio_write(struct cgroup *cgrp,
> > +				struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	if ((cgrp->parent == NULL) || (val > 100))
> > +		return -EINVAL;
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	memcg->dirty_background_ratio = val;
> > +	memcg->dirty_background_bytes = 0;
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_bytes_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_bytes_write(struct cgroup *cgrp,
> > +				struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	if (cgrp->parent == NULL)
> > +		return -EINVAL;
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	memcg->dirty_background_ratio = 0;
> > +	memcg->dirty_background_bytes = val;
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return 0;
> > +}
> > +
> >  static struct cftype mem_cgroup_files[] = {
> >  	{
> >  		.name = "usage_in_bytes",
> > @@ -3518,6 +3785,26 @@ static struct cftype mem_cgroup_files[] = {
> >  		.write_u64 = mem_cgroup_swappiness_write,
> >  	},
> >  	{
> > +		.name = "dirty_ratio",
> > +		.read_u64 = mem_cgroup_dirty_ratio_read,
> > +		.write_u64 = mem_cgroup_dirty_ratio_write,
> > +	},
> > +	{
> > +		.name = "dirty_bytes",
> > +		.read_u64 = mem_cgroup_dirty_bytes_read,
> > +		.write_u64 = mem_cgroup_dirty_bytes_write,
> > +	},
> > +	{
> > +		.name = "dirty_background_ratio",
> > +		.read_u64 = mem_cgroup_dirty_background_ratio_read,
> > +		.write_u64 = mem_cgroup_dirty_background_ratio_write,
> > +	},
> > +	{
> > +		.name = "dirty_background_bytes",
> > +		.read_u64 = mem_cgroup_dirty_background_bytes_read,
> > +		.write_u64 = mem_cgroup_dirty_background_bytes_write,
> > +	},
> > +	{
> >  		.name = "move_charge_at_immigrate",
> >  		.read_u64 = mem_cgroup_move_charge_read,
> >  		.write_u64 = mem_cgroup_move_charge_write,
> > @@ -3776,8 +4063,23 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	mem->last_scanned_child = 0;
> >  	spin_lock_init(&mem->reclaim_param_lock);
> >  
> > -	if (parent)
> > +	if (parent) {
> >  		mem->swappiness = get_swappiness(parent);
> > +
> > +		mem->dirty_ratio = get_dirty_param(parent,
> > +					MEM_CGROUP_DIRTY_RATIO);
> > +		mem->dirty_bytes = get_dirty_param(parent,
> > +					MEM_CGROUP_DIRTY_BYTES);
> > +		mem->dirty_background_ratio = get_dirty_param(parent,
> > +					MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> > +		mem->dirty_background_bytes = get_dirty_param(parent,
> > +					MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> > +	} else {
> > +		mem->dirty_ratio = vm_dirty_ratio;
> > +		mem->dirty_bytes = vm_dirty_bytes;
> > +		mem->dirty_background_ratio = vm_dirty_ratio;
> > +		mem->dirty_background_bytes = vm_dirty_bytes;
> 
> background_dirty_ratio ?

Sounds better.

OK, I'll apply all the changes and post another version.

Thanks!
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
