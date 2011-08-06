Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D86E36B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 10:48:40 -0400 (EDT)
Date: Sat, 6 Aug 2011 16:48:34 +0200
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110806144834.GA29243@thinkpad>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110806094527.136636891@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Aug 06, 2011 at 04:44:52PM +0800, Wu Fengguang wrote:
> As proposed by Chris, Dave and Jan, don't start foreground writeback IO
> inside balance_dirty_pages(). Instead, simply let it idle sleep for some
> time to throttle the dirtying task. In the mean while, kick off the
> per-bdi flusher thread to do background writeback IO.
> 
> RATIONALS
> =========
> 
> - disk seeks on concurrent writeback of multiple inodes (Dave Chinner)
> 
>   If every thread doing writes and being throttled start foreground
>   writeback, it leads to N IO submitters from at least N different
>   inodes at the same time, end up with N different sets of IO being
>   issued with potentially zero locality to each other, resulting in
>   much lower elevator sort/merge efficiency and hence we seek the disk
>   all over the place to service the different sets of IO.
>   OTOH, if there is only one submission thread, it doesn't jump between
>   inodes in the same way when congestion clears - it keeps writing to
>   the same inode, resulting in large related chunks of sequential IOs
>   being issued to the disk. This is more efficient than the above
>   foreground writeback because the elevator works better and the disk
>   seeks less.
> 
> - lock contention and cache bouncing on concurrent IO submitters (Dave Chinner)
> 
>   With this patchset, the fs_mark benchmark on a 12-drive software RAID0 goes
>   from CPU bound to IO bound, freeing "3-4 CPUs worth of spinlock contention".
> 
>   * "CPU usage has dropped by ~55%", "it certainly appears that most of
>     the CPU time saving comes from the removal of contention on the
>     inode_wb_list_lock" (IMHO at least 10% comes from the reduction of
>     cacheline bouncing, because the new code is able to call much less
>     frequently into balance_dirty_pages() and hence access the global
>     page states)
> 
>   * the user space "App overhead" is reduced by 20%, by avoiding the
>     cacheline pollution by the complex writeback code path
> 
>   * "for a ~5% throughput reduction", "the number of write IOs have
>     dropped by ~25%", and the elapsed time reduced from 41:42.17 to
>     40:53.23.
> 
>   * On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%,
>     and improves IO throughput from 38MB/s to 42MB/s.
> 
> - IO size too small for fast arrays and too large for slow USB sticks
> 
>   The write_chunk used by current balance_dirty_pages() cannot be
>   directly set to some large value (eg. 128MB) for better IO efficiency.
>   Because it could lead to more than 1 second user perceivable stalls.
>   Even the current 4MB write size may be too large for slow USB sticks.
>   The fact that balance_dirty_pages() starts IO on itself couples the
>   IO size to wait time, which makes it hard to do suitable IO size while
>   keeping the wait time under control.
> 
>   Now it's possible to increase writeback chunk size proportional to the
>   disk bandwidth. In a simple test of 50 dd's on XFS, 1-HDD, 3GB ram,
>   the larger writeback size dramatically reduces the seek count to 1/10
>   (far beyond my expectation) and improves the write throughput by 24%.
> 
> - long block time in balance_dirty_pages() hurts desktop responsiveness
> 
>   Many of us may have the experience: it often takes a couple of seconds
>   or even long time to stop a heavy writing dd/cp/tar command with
>   Ctrl-C or "kill -9".
> 
> - IO pipeline broken by bumpy write() progress
> 
>   There are a broad class of "loop {read(buf); write(buf);}" applications
>   whose read() pipeline will be under-utilized or even come to a stop if
>   the write()s have long latencies _or_ don't progress in a constant rate.
>   The current threshold based throttling inherently transfers the large
>   low level IO completion fluctuations to bumpy application write()s,
>   and further deteriorates with increasing number of dirtiers and/or bdi's.
> 
>   For example, when doing 50 dd's + 1 remote rsync to an XFS partition,
>   the rsync progresses very bumpy in legacy kernel, and throughput is
>   improved by 67% by this patchset. (plus the larger write chunk size,
>   it will be 93% speedup).
> 
>   The new rate based throttling can support 1000+ dd's with excellent
>   smoothness, low latency and low overheads.
> 
> For the above reasons, it's much better to do IO-less and low latency
> pauses in balance_dirty_pages().
> 
> Jan Kara, Dave Chinner and me explored the scheme to let
> balance_dirty_pages() wait for enough writeback IO completions to
> safeguard the dirty limit. However it's found to have two problems:
> 
> - in large NUMA systems, the per-cpu counters may have big accounting
>   errors, leading to big throttle wait time and jitters.
> 
> - NFS may kill large amount of unstable pages with one single COMMIT.
>   Because NFS server serves COMMIT with expensive fsync() IOs, it is
>   desirable to delay and reduce the number of COMMITs. So it's not
>   likely to optimize away such kind of bursty IO completions, and the
>   resulted large (and tiny) stall times in IO completion based throttling.
> 
> So here is a pause time oriented approach, which tries to control the
> pause time in each balance_dirty_pages() invocations, by controlling
> the number of pages dirtied before calling balance_dirty_pages(), for
> smooth and efficient dirty throttling:
> 
> - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> - avoid too small pause time (less than   4ms, which burns CPU power)
> - avoid too large pause time (more than 200ms, which hurts responsiveness)
> - avoid big fluctuations of pause times
> 
> It can control pause times at will. The default policy will be to do
> ~10ms pauses in 1-dd case, and increase to ~100ms in 1000-dd case.
> 
> BEHAVIOR CHANGE
> ===============
> 
> (1) dirty threshold
> 
> Users will notice that the applications will get throttled once crossing
> the global (background + dirty)/2=15% threshold, and then balanced around
> 17.5%. Before patch, the behavior is to just throttle it at 20% dirtyable
> memory in 1-dd case.
> 
> Since the task will be soft throttled earlier than before, it may be
> perceived by end users as performance "slow down" if his application
> happens to dirty more than 15% dirtyable memory.
> 
> (2) smoothness/responsiveness
> 
> Users will notice a more responsive system during heavy writeback.
> "killall dd" will take effect instantly.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---

Another minor nit below.

>  include/trace/events/writeback.h |   24 ----
>  mm/page-writeback.c              |  142 +++++++----------------------
>  2 files changed, 37 insertions(+), 129 deletions(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2011-08-06 11:17:26.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-08-06 16:16:30.000000000 +0800
> @@ -242,50 +242,6 @@ static void bdi_writeout_fraction(struct
>  				numerator, denominator);
>  }
>  
> -static inline void task_dirties_fraction(struct task_struct *tsk,
> -		long *numerator, long *denominator)
> -{
> -	prop_fraction_single(&vm_dirties, &tsk->dirties,
> -				numerator, denominator);
> -}
> -
> -/*
> - * task_dirty_limit - scale down dirty throttling threshold for one task
> - *
> - * task specific dirty limit:
> - *
> - *   dirty -= (dirty/8) * p_{t}
> - *
> - * To protect light/slow dirtying tasks from heavier/fast ones, we start
> - * throttling individual tasks before reaching the bdi dirty limit.
> - * Relatively low thresholds will be allocated to heavy dirtiers. So when
> - * dirty pages grow large, heavy dirtiers will be throttled first, which will
> - * effectively curb the growth of dirty pages. Light dirtiers with high enough
> - * dirty threshold may never get throttled.
> - */
> -#define TASK_LIMIT_FRACTION 8
> -static unsigned long task_dirty_limit(struct task_struct *tsk,
> -				       unsigned long bdi_dirty)
> -{
> -	long numerator, denominator;
> -	unsigned long dirty = bdi_dirty;
> -	u64 inv = dirty / TASK_LIMIT_FRACTION;
> -
> -	task_dirties_fraction(tsk, &numerator, &denominator);
> -	inv *= numerator;
> -	do_div(inv, denominator);
> -
> -	dirty -= inv;
> -
> -	return max(dirty, bdi_dirty/2);
> -}
> -
> -/* Minimum limit for any task */
> -static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
> -{
> -	return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION;
> -}
> -
>  /*
>   *
>   */
> @@ -855,24 +811,28 @@ static unsigned long ratelimit_pages(uns
>   * perform some writeout.
>   */
>  static void balance_dirty_pages(struct address_space *mapping,
> -				unsigned long write_chunk)
> +				unsigned long pages_dirtied)
>  {
> -	unsigned long nr_reclaimable, bdi_nr_reclaimable;
> +	unsigned long nr_reclaimable;
>  	unsigned long nr_dirty;  /* = file_dirty + writeback + unstable_nfs */
>  	unsigned long bdi_dirty;
>  	unsigned long background_thresh;
>  	unsigned long dirty_thresh;
>  	unsigned long bdi_thresh;
> -	unsigned long task_bdi_thresh;
> -	unsigned long min_task_bdi_thresh;
> -	unsigned long pages_written = 0;
> -	unsigned long pause = 1;
> +	unsigned long pause = 0;
>  	bool dirty_exceeded = false;
> -	bool clear_dirty_exceeded = true;
> +	unsigned long bw;
> +	unsigned long base_bw;
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  	unsigned long start_time = jiffies;
>  
>  	for (;;) {
> +		/*
> +		 * Unstable writes are a feature of certain networked
> +		 * filesystems (i.e. NFS) in which data may have been
> +		 * written to the server's write cache, but has not yet
> +		 * been flushed to permanent storage.
> +		 */
>  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
>  					global_page_state(NR_UNSTABLE_NFS);
>  		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
> @@ -888,8 +848,6 @@ static void balance_dirty_pages(struct a
>  			break;
>  
>  		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> -		min_task_bdi_thresh = task_min_dirty_limit(bdi_thresh);
> -		task_bdi_thresh = task_dirty_limit(current, bdi_thresh);
>  
>  		/*
>  		 * In order to avoid the stacked BDI deadlock we need
> @@ -901,56 +859,38 @@ static void balance_dirty_pages(struct a
>  		 * actually dirty; with m+n sitting in the percpu
>  		 * deltas.
>  		 */
> -		if (task_bdi_thresh < 2 * bdi_stat_error(bdi)) {
> -			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> -			bdi_dirty = bdi_nr_reclaimable +
> +		if (bdi_thresh < 2 * bdi_stat_error(bdi))
> +			bdi_dirty = bdi_stat_sum(bdi, BDI_RECLAIMABLE) +
>  				    bdi_stat_sum(bdi, BDI_WRITEBACK);
> -		} else {
> -			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> -			bdi_dirty = bdi_nr_reclaimable +
> +		else
> +			bdi_dirty = bdi_stat(bdi, BDI_RECLAIMABLE) +
>  				    bdi_stat(bdi, BDI_WRITEBACK);
> -		}
>  
> -		/*
> -		 * The bdi thresh is somehow "soft" limit derived from the
> -		 * global "hard" limit. The former helps to prevent heavy IO
> -		 * bdi or process from holding back light ones; The latter is
> -		 * the last resort safeguard.
> -		 */
> -		dirty_exceeded = (bdi_dirty > task_bdi_thresh) ||
> +		dirty_exceeded = (bdi_dirty > bdi_thresh) ||
>  				  (nr_dirty > dirty_thresh);
> -		clear_dirty_exceeded = (bdi_dirty <= min_task_bdi_thresh) &&
> -					(nr_dirty <= dirty_thresh);
> -
> -		if (!dirty_exceeded)
> -			break;
> -
> -		if (!bdi->dirty_exceeded)
> +		if (dirty_exceeded && !bdi->dirty_exceeded)
>  			bdi->dirty_exceeded = 1;
>  
>  		bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
>  				     bdi_thresh, bdi_dirty, start_time);
>  
> -		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> -		 * Unstable writes are a feature of certain networked
> -		 * filesystems (i.e. NFS) in which data may have been
> -		 * written to the server's write cache, but has not yet
> -		 * been flushed to permanent storage.
> -		 * Only move pages to writeback if this bdi is over its
> -		 * threshold otherwise wait until the disk writes catch
> -		 * up.
> -		 */
> -		trace_balance_dirty_start(bdi);
> -		if (bdi_nr_reclaimable > task_bdi_thresh) {
> -			pages_written += writeback_inodes_wb(&bdi->wb,
> -							     write_chunk);
> -			trace_balance_dirty_written(bdi, pages_written);
> -			if (pages_written >= write_chunk)
> -				break;		/* We've done our duty */
> +		if (unlikely(!writeback_in_progress(bdi)))
> +			bdi_start_background_writeback(bdi);
> +
> +		base_bw = bdi->dirty_ratelimit;
> +		bw = bdi_position_ratio(bdi, dirty_thresh, nr_dirty,
> +					bdi_thresh, bdi_dirty);
> +		if (unlikely(bw == 0)) {
> +			pause = MAX_PAUSE;
> +			goto pause;
>  		}
> +		bw = (u64)base_bw * bw >> BANDWIDTH_CALC_SHIFT;
> +		pause = (HZ * pages_dirtied + bw / 2) / (bw | 1);
> +		pause = min(pause, MAX_PAUSE);

Fix this build warning:

 mm/page-writeback.c: In function a??balance_dirty_pagesa??:
 mm/page-writeback.c:889:11: warning: comparison of distinct pointer types lacks a cast

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 mm/page-writeback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a36f83d..a998931 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -886,7 +886,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		}
 		bw = (u64)base_bw * bw >> BANDWIDTH_CALC_SHIFT;
 		pause = (HZ * pages_dirtied + bw / 2) / (bw | 1);
-		pause = min(pause, MAX_PAUSE);
+		pause = min_t(unsigned long, pause, MAX_PAUSE);
 
 pause:
 		__set_current_state(TASK_UNINTERRUPTIBLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
