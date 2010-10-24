Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 116996B0089
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 14:44:58 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2][memcg+dirtylimit] Fix  overwriting global vm dirty limit setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page accounting
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020140255.5b8afb63.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 24 Oct 2010 11:44:38 -0700
Message-ID: <xr937hh7sa5l.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> Fixed one here.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, at calculating dirty limit, vm_dirty_param() is called.
> This function returns dirty-limit related parameters considering
> memory cgroup settings.
>
> Now, assume that vm_dirty_bytes=100M (global dirty limit) and
> memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
> 500MB.
>
> In this case, global_dirty_limits will consider dirty_limt as
> 500 *0.4 = 200MB. This is bad...memory cgroup is not back door.
>
> This patch limits the return value of vm_dirty_param() considring
> global settings.
>
> Changelog:
>  - fixed an argument "mem" int to u64
>  - fixed to use global available memory to cap memcg's value.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    5 +++--
>  mm/memcontrol.c            |   30 +++++++++++++++++++++++++++++-
>  mm/page-writeback.c        |    3 ++-
>  3 files changed, 34 insertions(+), 4 deletions(-)
>
> Index: dirty_limit_new/mm/memcontrol.c
> ===================================================================
> --- dirty_limit_new.orig/mm/memcontrol.c
> +++ dirty_limit_new/mm/memcontrol.c
> @@ -1171,9 +1171,11 @@ static void __mem_cgroup_dirty_param(str
>   * can be moved after our access and writeback tends to take long time.  At
>   * least, "memcg" will not be freed while holding rcu_read_lock().
>   */
> -void vm_dirty_param(struct vm_dirty_param *param)
> +void vm_dirty_param(struct vm_dirty_param *param,
> +	 u64 mem, u64 global)
>  {
>  	struct mem_cgroup *memcg;
> +	u64 limit, bglimit;
>  
>  	if (mem_cgroup_disabled()) {
>  		global_vm_dirty_param(param);
> @@ -1183,6 +1185,32 @@ void vm_dirty_param(struct vm_dirty_para
>  	rcu_read_lock();
>  	memcg = mem_cgroup_from_task(current);
>  	__mem_cgroup_dirty_param(param, memcg);
> +	/*
> +	 * A limitation under memory cgroup is under global vm, too.
> +	 */
> +	if (vm_dirty_ratio)
> +		limit = global * vm_dirty_ratio / 100;
> +	else
> +		limit = vm_dirty_bytes;
> +	if (param->dirty_ratio) {
> +		param->dirty_bytes = mem * param->dirty_ratio / 100;
> +		param->dirty_ratio = 0;
> +	}
> +	if (param->dirty_bytes > limit)
> +		param->dirty_bytes = limit;
> +
> +	if (dirty_background_ratio)
> +		bglimit = global * dirty_background_ratio / 100;
> +	else
> +		bglimit = dirty_background_bytes;
> +
> +	if (param->dirty_background_ratio) {
> +		param->dirty_background_bytes =
> +			mem * param->dirty_background_ratio / 100;
> +		param->dirty_background_ratio = 0;
> +	}
> +	if (param->dirty_background_bytes > bglimit)
> +		param->dirty_background_bytes = bglimit;
>  	rcu_read_unlock();
>  }
>  
> Index: dirty_limit_new/include/linux/memcontrol.h
> ===================================================================
> --- dirty_limit_new.orig/include/linux/memcontrol.h
> +++ dirty_limit_new/include/linux/memcontrol.h
> @@ -171,7 +171,7 @@ static inline void mem_cgroup_dec_page_s
>  }
>  
>  bool mem_cgroup_has_dirty_limit(void);
> -void vm_dirty_param(struct vm_dirty_param *param);
> +void vm_dirty_param(struct vm_dirty_param *param, u64 mem, u64 global);
>  s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
>  
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> @@ -360,7 +360,8 @@ static inline bool mem_cgroup_has_dirty_
>  	return false;
>  }
>  
> -static inline void vm_dirty_param(struct vm_dirty_param *param)
> +static inline void vm_dirty_param(struct vm_dirty_param *param,
> +		u64 mem, u64 global)
>  {
>  	global_vm_dirty_param(param);
>  }
> Index: dirty_limit_new/mm/page-writeback.c
> ===================================================================
> --- dirty_limit_new.orig/mm/page-writeback.c
> +++ dirty_limit_new/mm/page-writeback.c
> @@ -466,7 +466,8 @@ void global_dirty_limits(unsigned long *
>  	struct task_struct *tsk;
>  	struct vm_dirty_param dirty_param;
>  
> -	vm_dirty_param(&dirty_param);
> +	vm_dirty_param(&dirty_param,
> +		available_memory, global_dirtyable_memory());
>  
>  	if (dirty_param.dirty_bytes)
>  		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);

I think there is a problem with the patch above.  In the patch
vm_dirty_param() sets param->dirty_[background_]bytes to the smallest
limits considering the memcg and global limits.  Assuming the current
task is in a memcg, then the memcg dirty (not system-wide) usage is
always compared to the selected limits (which may be per-memcg or
system).  The problem is that if:
a) per-memcg dirty limit is smaller than system then vm_dirty_param()
   will select per-memcg dirty limit, and
b) per-memcg dirty usage is well below memcg dirty limit, and
b) system usage is at system limit
Then the above patch will not trigger writeback.  Example with two
memcg:
         sys
        B   C
      
      limit  usage
  sys  10     10
   B    7      6
   C    5      4

If B wants to grow, the system will exceed system limit of 10 and should
be throttled.  However, the smaller limit (7) will be selected and
applied to memcg usage (6), which indicates no need to throttle, so the
system could get as bad as:

      limit  usage
  sys  10     12
   B    7      7
   C    5      5

In this case the system usage exceeds the system limit because each
the per-memcg checks see no per-memcg problems.

To solve this I propose we create a new structure to aggregate both
dirty limit and usage data:
	struct dirty_limits {
	       unsigned long dirty_thresh;
	       unsigned long background_thresh;
	       unsigned long nr_reclaimable;
	       unsigned long nr_writeback;
	};

global_dirty_limits() would then query both the global and memcg limits
and dirty usage of one that is closest to its limit.  This change makes
global_dirty_limits() look like:

void global_dirty_limits(struct dirty_limits *limits)
{
	unsigned long background;
	unsigned long dirty;
	unsigned long nr_reclaimable;
	unsigned long nr_writeback;
	unsigned long available_memory = determine_dirtyable_memory();
	struct task_struct *tsk;

	if (vm_dirty_bytes)
		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
	else
		dirty = (vm_dirty_ratio * available_memory) / 100;

	if (dirty_background_bytes)
		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
	else
		background = (dirty_background_ratio * available_memory) / 100;

	nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
				global_page_state(NR_UNSTABLE_NFS);
	nr_writeback = global_page_state(NR_WRITEBACK);

	if (mem_cgroup_dirty_limits(available_memory, limits) &&
	    dirty_available(limits->dirty_thresh, limits->nr_reclaimable,
			    limits->nr_writeback) <
	    dirty_available(dirty, nr_reclaimable, nr_writeback)) {
		dirty = min(dirty, limits->dirty_thresh);
		background = min(background, limits->background_thresh);
	} else {
		limits->nr_reclaimable = nr_reclaimable;
		limits->nr_writeback = nr_writeback;
	}

	if (background >= dirty)
		background = dirty / 2;
	tsk = current;
	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
		background += background / 4;
		dirty += dirty / 4;
	}
	limits->background_thresh = background;
	limits->dirty_thresh = dirty;
}

Because this approach considered both memcg and system limits, the
problem described above is avoided.

I have this change integrated into the memcg dirty limit series (-v3 was
the last post; v4 is almost ready with this change).  I will post -v4
with this approach is there is no strong objection.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
