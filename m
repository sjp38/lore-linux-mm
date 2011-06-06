Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F2FDB6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 14:47:37 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v8 10/12] memcg: create support routines for page-writeback
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-11-git-send-email-gthelen@google.com>
	<20110605031156.GB5914@barrios-laptop>
Date: Mon, 06 Jun 2011 11:47:03 -0700
Message-ID: <xr931uz623x4.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

Minchan Kim <minchan.kim@gmail.com> writes:

> Hi Greg,
>
> On Fri, Jun 03, 2011 at 09:12:16AM -0700, Greg Thelen wrote:
>> Introduce memcg routines to assist in per-memcg dirty page management:
>> 
>> - mem_cgroup_balance_dirty_pages() walks a memcg hierarchy comparing
>>   dirty memory usage against memcg foreground and background thresholds.
>>   If an over-background-threshold memcg is found, then per-memcg
>>   background writeback is queued.  Per-memcg writeback differs from
>>   classic, non-memcg, per bdi writeback by setting the new
>>   writeback_control.for_cgroup bit.
>> 
>>   If an over-foreground-threshold memcg is found, then foreground
>>   writeout occurs.  When performing foreground writeout, first consider
>>   inodes exclusive to the memcg.  If unable to make enough progress,
>>   then consider inodes shared between memcg.  Such cross-memcg inode
>>   sharing likely to be rare in situations that use per-cgroup memory
>>   isolation.  The approach tries to handle the common (non-shared)
>>   case well without punishing well behaved (non-sharing) cgroups.
>>   As a last resort writeback shared inodes.
>> 
>>   This routine is used by balance_dirty_pages() in a later change.
>> 
>> - mem_cgroup_hierarchical_dirty_info() returns the dirty memory usage
>>   and limits of the memcg closest to (or over) its dirty limit.  This
>>   will be used by throttle_vm_writeout() in a latter change.
>> 
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>> Changelog since v7:
>> - Add more detail to commit description.
>> 
>> - Declare the new writeback_control for_cgroup bit in this change, the
>>   first patch that uses the new field is first used.  In -v7 the field
>>   was declared in a separate patch.
>> 
>>  include/linux/memcontrol.h        |   18 +++++
>>  include/linux/writeback.h         |    1 +
>>  include/trace/events/memcontrol.h |   83 ++++++++++++++++++++
>>  mm/memcontrol.c                   |  150 +++++++++++++++++++++++++++++++++++++
>>  4 files changed, 252 insertions(+), 0 deletions(-)
>> 
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 3d72e09..0d0363e 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -167,6 +167,11 @@ bool should_writeback_mem_cgroup_inode(struct inode *inode,
>>  				       struct writeback_control *wbc);
>>  bool mem_cgroups_over_bground_dirty_thresh(void);
>>  void mem_cgroup_writeback_done(void);
>> +bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
>> +					struct mem_cgroup *mem,
>> +					struct dirty_info *info);
>> +void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
>> +				    unsigned long write_chunk);
>>  
>>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>>  						gfp_t gfp_mask,
>> @@ -383,6 +388,19 @@ static inline void mem_cgroup_writeback_done(void)
>>  {
>>  }
>>  
>> +static inline void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
>> +						  unsigned long write_chunk)
>> +{
>> +}
>> +
>> +static inline bool
>> +mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
>> +				   struct mem_cgroup *mem,
>> +				   struct dirty_info *info)
>> +{
>> +	return false;
>> +}
>> +
>>  static inline
>>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>>  					    gfp_t gfp_mask,
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index 66ec339..4f5c0d2 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -47,6 +47,7 @@ struct writeback_control {
>>  	unsigned for_reclaim:1;		/* Invoked from the page allocator */
>>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>>  	unsigned more_io:1;		/* more io to be dispatched */
>> +	unsigned for_cgroup:1;		/* enable cgroup writeback */
>>  	unsigned shared_inodes:1;	/* write inodes spanning cgroups */
>>  };
>>  
>> diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
>> index 326a66b..b42dae1 100644
>> --- a/include/trace/events/memcontrol.h
>> +++ b/include/trace/events/memcontrol.h
>> @@ -109,6 +109,89 @@ TRACE_EVENT(mem_cgroups_over_bground_dirty_thresh,
>>  		  __entry->first_id)
>>  )
>>  
>> +DECLARE_EVENT_CLASS(mem_cgroup_consider_writeback,
>> +	TP_PROTO(unsigned short css_id,
>> +		 struct backing_dev_info *bdi,
>> +		 unsigned long nr_reclaimable,
>> +		 unsigned long thresh,
>> +		 bool over_limit),
>> +
>> +	TP_ARGS(css_id, bdi, nr_reclaimable, thresh, over_limit),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(unsigned short, css_id)
>> +		__field(struct backing_dev_info *, bdi)
>> +		__field(unsigned long, nr_reclaimable)
>> +		__field(unsigned long, thresh)
>> +		__field(bool, over_limit)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->css_id = css_id;
>> +		__entry->bdi = bdi;
>> +		__entry->nr_reclaimable = nr_reclaimable;
>> +		__entry->thresh = thresh;
>> +		__entry->over_limit = over_limit;
>> +	),
>> +
>> +	TP_printk("css_id=%d bdi=%p nr_reclaimable=%ld thresh=%ld "
>> +		  "over_limit=%d", __entry->css_id, __entry->bdi,
>> +		  __entry->nr_reclaimable, __entry->thresh, __entry->over_limit)
>> +)
>> +
>> +#define DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(name) \
>> +DEFINE_EVENT(mem_cgroup_consider_writeback, name, \
>> +	TP_PROTO(unsigned short id, \
>> +		 struct backing_dev_info *bdi, \
>> +		 unsigned long nr_reclaimable, \
>> +		 unsigned long thresh, \
>> +		 bool over_limit), \
>> +	TP_ARGS(id, bdi, nr_reclaimable, thresh, over_limit) \
>> +)
>> +
>> +DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_bg_writeback);
>> +DEFINE_MEM_CGROUP_CONSIDER_WRITEBACK_EVENT(mem_cgroup_consider_fg_writeback);
>> +
>> +TRACE_EVENT(mem_cgroup_fg_writeback,
>> +	TP_PROTO(unsigned long write_chunk,
>> +		 struct writeback_control *wbc),
>> +
>> +	TP_ARGS(write_chunk, wbc),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(unsigned long, write_chunk)
>> +		__field(long, wbc_to_write)
>> +		__field(bool, shared_inodes)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->write_chunk = write_chunk;
>> +		__entry->wbc_to_write = wbc->nr_to_write;
>> +		__entry->shared_inodes = wbc->shared_inodes;
>> +	),
>> +
>> +	TP_printk("write_chunk=%ld nr_to_write=%ld shared_inodes=%d",
>> +		  __entry->write_chunk,
>> +		  __entry->wbc_to_write,
>> +		  __entry->shared_inodes)
>> +)
>> +
>> +TRACE_EVENT(mem_cgroup_enable_shared_writeback,
>> +	TP_PROTO(unsigned short css_id),
>> +
>> +	TP_ARGS(css_id),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(unsigned short, css_id)
>> +		),
>> +
>> +	TP_fast_assign(
>> +		__entry->css_id = css_id;
>> +		),
>> +
>> +	TP_printk("enabling shared writeback for memcg %d", __entry->css_id)
>> +)
>> +
>>  #endif /* _TRACE_MEMCONTROL_H */
>>  
>>  /* This part must be outside protection */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index a5b1794..17cb888 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1622,6 +1622,156 @@ void mem_cgroup_writeback_done(void)
>>  	}
>>  }
>>  
>> +/*
>> + * This routine must be called by processes which are generating dirty pages.
>> + * It considers the dirty pages usage and thresholds of the current cgroup and
>> + * (depending if hierarchical accounting is enabled) ancestral memcg.  If any of
>> + * the considered memcg are over their background dirty limit, then background
>> + * writeback is queued.  If any are over the foreground dirty limit then
>> + * throttle the dirtying task while writing dirty data.  The per-memcg dirty
>> + * limits check by this routine are distinct from either the per-system,
>> + * per-bdi, or per-task limits considered by balance_dirty_pages().
>> + */
>> +void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
>> +				    unsigned long write_chunk)
>> +{
>> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
>> +	struct mem_cgroup *mem;
>> +	struct mem_cgroup *ref_mem;
>> +	struct dirty_info info;
>> +	unsigned long nr_reclaimable;
>> +	unsigned long sys_available_mem;
>> +	unsigned long pause = 1;
>> +	unsigned short id;
>> +	bool over;
>> +	bool shared_inodes;
>> +
>> +	if (mem_cgroup_disabled())
>> +		return;
>> +
>> +	sys_available_mem = determine_dirtyable_memory();
>> +
>> +	/* reference the memcg so it is not deleted during this routine */
>> +	rcu_read_lock();
>> +	mem = mem_cgroup_from_task(current);
>> +	if (mem && mem_cgroup_is_root(mem))
>> +		mem = NULL;
>> +	if (mem)
>> +		css_get(&mem->css);
>> +	rcu_read_unlock();
>> +	ref_mem = mem;
>> +
>> +	/* balance entire ancestry of current's mem. */
>> +	for (; mem_cgroup_has_dirty_limit(mem); mem = parent_mem_cgroup(mem)) {
>> +		id = css_id(&mem->css);
>> +
>> +		/*
>> +		 * keep throttling and writing inode data so long as mem is over
>> +		 * its dirty limit.
>> +		 */
>> +		for (shared_inodes = false; ; ) {
>> +			struct writeback_control wbc = {
>> +				.sync_mode	= WB_SYNC_NONE,
>> +				.older_than_this = NULL,
>> +				.range_cyclic	= 1,
>> +				.for_cgroup	= 1,
>> +				.nr_to_write	= write_chunk,
>> +				.shared_inodes	= shared_inodes,
>> +			};
>> +
>> +			/*
>> +			 * if mem is under dirty limit, then break from
>> +			 * throttling loop.
>> +			 */
>> +			mem_cgroup_dirty_info(sys_available_mem, mem, &info);
>> +			nr_reclaimable = dirty_info_reclaimable(&info);
>> +			over = nr_reclaimable > info.dirty_thresh;
>> +			trace_mem_cgroup_consider_fg_writeback(
>> +				id, bdi, nr_reclaimable, info.dirty_thresh,
>> +				over);
>> +			if (!over)
>> +				break;
>> +
>> +			mem_cgroup_mark_over_bg_thresh(mem);
>
> We are over the fg_thresh.
> Then, why do you mark bg_thresh, too?

It is possible for a cgroup to exceed its background limit without
calling balance_dirty_pages() due to rate limiting in
balance_dirty_pages_ratelimited_nr().  So this call to
mem_cgroup_mark_over_bg_thresh() is needed to ensure that the cgroup is
marked as over-bg-limit.  The writeback_inodes_wb() call below writes
the inodes owned by over-bg-limit memcg.  This is not obvious.  I will
add a comment here explaining why marking over_bg_thresh in this
situation.

>> +			writeback_inodes_wb(&bdi->wb, &wbc);
>> +			trace_mem_cgroup_fg_writeback(write_chunk, &wbc);
>> +			/* if no progress, then consider shared inodes */
>> +			if ((wbc.nr_to_write == write_chunk) &&
>> +			    !shared_inodes) {
>> +				trace_mem_cgroup_enable_shared_writeback(id);
>> +				shared_inodes = true;
>
> I am not sure this is really right condition to punish shared inodes.
> We requested wbc with async. If bdi was congested, isn't it possible
> that we can't write anyting in this turn?
>
> If shared inodes are on different bdi, it would be effective but they
> are on same bdi?
> 
> If you assume that shared inode case is rare in memcg configuration
> and it's right assumption, I don't have a concern about it. But I have
> no idea.

I am not sure if bdi congestion can cause a problem here.  I don't think
that bdi congestion would cause writeback to fail to submit IOs and
decrement nr_to_write.  But I could be wrong.

There are other reasons that writeback_inodes_wb() may not make progress
(e.g. if b_io has only one inode currently under writeback, then no
progress may be made).  To detect such cases would require adding more
counters in the writeback code.  I do not feel that it is necessary to
avoid downshifting here into writing shared inodes.  But I do see value
in first trying to write non-shared inodes (as proposed in the patch).
Shared inodes should be rare because their usage would further limit
isolation offered by cgroups.

I will add a comment to this section to clarify this.

>> +			}
>> +
>> +			/*
>> +			 * Sleep up to 100ms to throttle writer and wait for
>> +			 * queued background I/O to complete.
>> +			 */
>> +			__set_current_state(TASK_UNINTERRUPTIBLE);
>> +			io_schedule_timeout(pause);
>> +			pause <<= 1;
>> +			if (pause > HZ / 10)
>> +				pause = HZ / 10;
>> +		}
>> +
>> +		/* if mem is over background limit, then queue bg writeback */
>> +		over = nr_reclaimable >= info.background_thresh;
>> +		trace_mem_cgroup_consider_bg_writeback(
>> +			id, bdi, nr_reclaimable, info.background_thresh,
>> +			over);
>> +		if (over)
>> +			mem_cgroup_queue_bg_writeback(mem, bdi);
>> +	}
>> +
>> +	if (ref_mem)
>> +		css_put(&ref_mem->css);
>> +}
>> +
>> +/*
>> + * Return the dirty thresholds and usage for the mem (within the ancestral chain
>> + * of @mem) closest to its dirty limit or the first memcg over its limit.
>
> dirty_info has return value 'bool'.
> What's meaning? Of course, we can guess it by look the code.
> But let's make user painful.
> Please write down the menaing of return value, too.

Good point.  I will add more details to the comment.

>> + *
>> + * The check is not stable because the usage and limits can change asynchronous
>> + * to this routine.
>> + */
>> +bool mem_cgroup_hierarchical_dirty_info(unsigned long sys_available_mem,
>> +					struct mem_cgroup *mem,
>> +					struct dirty_info *info)
>> +{
>> +	unsigned long usage;
>> +	struct dirty_info uninitialized_var(cur_info);
>> +
>> +	if (mem_cgroup_disabled())
>> +		return false;
>> +
>> +	info->nr_writeback = ULONG_MAX;  /* invalid initial value */
>> +
>> +	/* walk up hierarchy enabled parents */
>> +	for (; mem_cgroup_has_dirty_limit(mem); mem = parent_mem_cgroup(mem)) {
>> +		mem_cgroup_dirty_info(sys_available_mem, mem, &cur_info);
>> +		usage = dirty_info_reclaimable(&cur_info) +
>> +			cur_info.nr_writeback;
>> +
>> +		/* if over limit, stop searching */
>> +		if (usage >= cur_info.dirty_thresh) {
>> +			*info = cur_info;
>> +			break;
>> +		}
>> +
>> +		/*
>> +		 * Save dirty usage of mem closest to its limit if either:
>> +		 *     - mem is the first mem considered
>> +		 *     - mem dirty margin is smaller than last recorded one
>> +		 */
>> +		if ((info->nr_writeback == ULONG_MAX) ||
>> +		    (cur_info.dirty_thresh - usage) <
>> +		    (info->dirty_thresh -
>> +		     (dirty_info_reclaimable(info) + info->nr_writeback)))
>> +			*info = cur_info;
>> +	}
>> +
>> +	return info->nr_writeback != ULONG_MAX;
>> +}
>> +
>>  static void mem_cgroup_start_move(struct mem_cgroup *mem)
>>  {
>>  	int cpu;
>> -- 
>> 1.7.3.1
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
