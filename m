Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DFFAB900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 21:45:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 801D83EE0C7
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:45:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64D3145DEB4
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:45:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3690445DEA6
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:45:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B4D1DB803E
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:45:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CFD381DB8038
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:45:31 +0900 (JST)
Date: Thu, 18 Aug 2011 10:38:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v9 12/13] memcg: create support routines for page
 writeback
Message-Id: <20110818103803.c2617804.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313597705-6093-13-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-13-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Wed, 17 Aug 2011 09:15:04 -0700
Greg Thelen <gthelen@google.com> wrote:

> Introduce memcg routines to assist in per-memcg dirty page management:
> 
> - mem_cgroup_balance_dirty_pages() walks a memcg hierarchy comparing
>   dirty memory usage against memcg foreground and background thresholds.
>   If an over-background-threshold memcg is found, then per-memcg
>   background writeback is queued.  Per-memcg writeback differs from
>   classic, non-memcg, per bdi writeback by setting the new
>   writeback_control.for_cgroup bit.
> 
>   If an over-foreground-threshold memcg is found, then foreground
>   writeout occurs.  When performing foreground writeout, first consider
>   inodes exclusive to the memcg.  If unable to make enough progress,
>   then consider inodes shared between memcg.  Such cross-memcg inode
>   sharing likely to be rare in situations that use per-cgroup memory
>   isolation.  So the approach tries to handle the common case well
>   without falling over in cases where such sharing exists.  This routine
>   is used by balance_dirty_pages() in a later change.
> 
> - mem_cgroup_hierarchical_dirty_info() returns the dirty memory usage
>   and limits of the memcg closest to (or over) its dirty limit.  This
>   will be used by throttle_vm_writeout() in a latter change.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Comparing page-writebakc.c, I have some questions.



> +/*
> + * This routine must be called periodically by processes which generate dirty
> + * pages.  It considers the dirty pages usage and thresholds of the current
> + * cgroup and (depending if hierarchical accounting is enabled) ancestral memcg.
> + * If any of the considered memcg are over their background dirty limit, then
> + * background writeback is queued.  If any are over the foreground dirty limit
> + * then the dirtying task is throttled while writing dirty data.  The per-memcg
> + * dirty limits checked by this routine are distinct from either the per-system,
> + * per-bdi, or per-task limits considered by balance_dirty_pages().
> + *
> + *   Example hierarchy:
> + *                 root
> + *            A            B
> + *        A1      A2         B1
> + *     A11 A12  A21 A22
> + *
> + * Assume that mem_cgroup_balance_dirty_pages() is called on A11.  This routine
> + * starts at A11 walking upwards towards the root.  If A11 is over dirty limit,
> + * then writeback A11 inodes until under limit.  Next check A1, if over limit
> + * then write A1,A11,A12.  Then check A.  If A is over A limit, then invoke
> + * writeback on A* until A is under A limit.
> + */
> +void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
> +				    unsigned long write_chunk)
> +{
> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	struct mem_cgroup *memcg;
> +	struct mem_cgroup *ref_memcg;
> +	struct dirty_info info;
> +	unsigned long nr_reclaimable;
> +	unsigned long nr_written;
> +	unsigned long sys_available_mem;
> +	unsigned long pause = 1;
> +	unsigned short id;
> +	bool over;
> +	bool shared_inodes;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	sys_available_mem = determine_dirtyable_memory();
> +
> +	/* reference the memcg so it is not deleted during this routine */
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (memcg && mem_cgroup_is_root(memcg))
> +		memcg = NULL;
> +	if (memcg)
> +		css_get(&memcg->css);
> +	rcu_read_unlock();
> +	ref_memcg = memcg;
> +
> +	/* balance entire ancestry of current's memcg. */
> +	for (; mem_cgroup_has_dirty_limit(memcg);
> +	     memcg = parent_mem_cgroup(memcg)) {
> +		id = css_id(&memcg->css);
> +
> +		/*
> +		 * Keep throttling and writing inode data so long as memcg is
> +		 * over its dirty limit.  Inode being written by multiple memcg
> +		 * (aka shared_inodes) cannot easily be attributed a particular
> +		 * memcg.  Shared inodes are thought to be much rarer than
> +		 * shared inodes.  First try to satisfy this memcg's dirty
> +		 * limits using non-shared inodes.
> +		 */
> +		for (shared_inodes = false; ; ) {
> +			/*
> +			 * if memcg is under dirty limit, then break from
> +			 * throttling loop.
> +			 */
> +			mem_cgroup_dirty_info(sys_available_mem, memcg, &info);
> +			nr_reclaimable = dirty_info_reclaimable(&info);
> +			over = nr_reclaimable > info.dirty_thresh;
> +			trace_mem_cgroup_consider_fg_writeback(
> +				id, bdi, nr_reclaimable, info.dirty_thresh,
> +				over);
> +			if (!over)
> +				break;
> +
> +			nr_written = writeback_inodes_wb(&bdi->wb, write_chunk,
> +							 memcg, shared_inodes);
> +			trace_mem_cgroup_fg_writeback(write_chunk, nr_written,
> +						      id, shared_inodes);
> +			/* if no progress, then consider shared inodes */
> +			if ((nr_written == 0) && !shared_inodes) {
> +				trace_mem_cgroup_enable_shared_writeback(id);
> +				shared_inodes = true;
> +			}

in page-writeback.c

                    if (pages_written >= write_chunk)
                                break;          /* We've done our duty */

write_chunk(ratelimit) is used. Can't we make use of this threshold ?






> +
> +			__set_current_state(TASK_UNINTERRUPTIBLE);
> +			io_schedule_timeout(pause);
> +

How do you think about MAX_PAUSE/PASS_GOOD ?
==
                /*
                 * max-pause area. If dirty exceeded but still within this
                 * area, no need to sleep for more than 200ms: (a) 8 pages per
                 * 200ms is typically more than enough to curb heavy dirtiers;
                 * (b) the pause time limit makes the dirtiers more responsive.
                 */
                if (nr_dirty < dirty_thresh +
                               dirty_thresh / DIRTY_MAXPAUSE_AREA &&
                    time_after(jiffies, start_time + MAX_PAUSE))
                        break;
                /*
                 * pass-good area. When some bdi gets blocked (eg. NFS server
                 * not responding), or write bandwidth dropped dramatically due
                 * to concurrent reads, or dirty threshold suddenly dropped and
                 * the dirty pages cannot be brought down anytime soon (eg. on
                 * slow USB stick), at least let go of the good bdi's.
                 */
                if (nr_dirty < dirty_thresh +
                               dirty_thresh / DIRTY_PASSGOOD_AREA &&
                    bdi_dirty < bdi_thresh)
                        break;
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
