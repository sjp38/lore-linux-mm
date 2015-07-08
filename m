Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 66CD66B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 04:17:54 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so5235296wgx.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 01:17:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw2si1865262wib.72.2015.07.08.01.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 01:17:52 -0700 (PDT)
Date: Wed, 8 Jul 2015 10:17:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH block/for-4.3] writeback: update writeback tracepoints to
 report cgroup
Message-ID: <20150708081748.GB725@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-41-git-send-email-tj@kernel.org>
 <20150701075009.GA7252@quack.suse.cz>
 <20150706193642.GA23362@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150706193642.GA23362@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Mon 06-07-15 15:36:42, Tejun Heo wrote:
> The following tracepoints are updated to report the cgroup used during
> cgroup writeback.
> 
> * writeback_write_inode[_start]
> * writeback_queue
> * writeback_exec
> * writeback_start
> * writeback_written
> * writeback_wait
> * writeback_nowork
> * writeback_wake_background
> * wbc_writepage
> * writeback_queue_io
> * bdi_dirty_ratelimit
> * balance_dirty_pages
> * writeback_sb_inodes_requeue
> * writeback_single_inode[_start]
> 
> Note that writeback_bdi_register is separated out from writeback_class
> as reporting cgroup doesn't make sense to it.  Tracepoints which take
> bdi are updated to take bdi_writeback instead.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> ---
> Hello,
> 
> Will soon post this as part of a patch series of cgroup writeback
> updates.

Thanks. The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza


>  fs/fs-writeback.c                |   14 +--
>  include/trace/events/writeback.h |  180 ++++++++++++++++++++++++++++++---------
>  mm/page-writeback.c              |    6 -
>  3 files changed, 151 insertions(+), 49 deletions(-)
> 
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -176,7 +176,7 @@ static void wb_wakeup(struct bdi_writeba
>  static void wb_queue_work(struct bdi_writeback *wb,
>  			  struct wb_writeback_work *work)
>  {
> -	trace_writeback_queue(wb->bdi, work);
> +	trace_writeback_queue(wb, work);
>  
>  	spin_lock_bh(&wb->work_lock);
>  	if (!test_bit(WB_registered, &wb->state))
> @@ -882,7 +882,7 @@ void wb_start_writeback(struct bdi_write
>  	 */
>  	work = kzalloc(sizeof(*work), GFP_ATOMIC);
>  	if (!work) {
> -		trace_writeback_nowork(wb->bdi);
> +		trace_writeback_nowork(wb);
>  		wb_wakeup(wb);
>  		return;
>  	}
> @@ -912,7 +912,7 @@ void wb_start_background_writeback(struc
>  	 * We just wake up the flusher thread. It will perform background
>  	 * writeback as soon as there is no other work to do.
>  	 */
> -	trace_writeback_wake_background(wb->bdi);
> +	trace_writeback_wake_background(wb);
>  	wb_wakeup(wb);
>  }
>  
> @@ -1615,14 +1615,14 @@ static long wb_writeback(struct bdi_writ
>  		} else if (work->for_background)
>  			oldest_jif = jiffies;
>  
> -		trace_writeback_start(wb->bdi, work);
> +		trace_writeback_start(wb, work);
>  		if (list_empty(&wb->b_io))
>  			queue_io(wb, work);
>  		if (work->sb)
>  			progress = writeback_sb_inodes(work->sb, wb, work);
>  		else
>  			progress = __writeback_inodes_wb(wb, work);
> -		trace_writeback_written(wb->bdi, work);
> +		trace_writeback_written(wb, work);
>  
>  		wb_update_bandwidth(wb, wb_start);
>  
> @@ -1647,7 +1647,7 @@ static long wb_writeback(struct bdi_writ
>  		 * we'll just busyloop.
>  		 */
>  		if (!list_empty(&wb->b_more_io))  {
> -			trace_writeback_wait(wb->bdi, work);
> +			trace_writeback_wait(wb, work);
>  			inode = wb_inode(wb->b_more_io.prev);
>  			spin_lock(&inode->i_lock);
>  			spin_unlock(&wb->list_lock);
> @@ -1753,7 +1753,7 @@ static long wb_do_writeback(struct bdi_w
>  	while ((work = get_next_work_item(wb)) != NULL) {
>  		struct wb_completion *done = work->done;
>  
> -		trace_writeback_exec(wb->bdi, work);
> +		trace_writeback_exec(wb, work);
>  
>  		wrote += wb_writeback(wb, work);
>  
> --- a/include/trace/events/writeback.h
> +++ b/include/trace/events/writeback.h
> @@ -131,6 +131,66 @@ DEFINE_EVENT(writeback_dirty_inode_templ
>  	TP_ARGS(inode, flags)
>  );
>  
> +#ifdef CREATE_TRACE_POINTS
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +
> +static inline size_t __trace_wb_cgroup_size(struct bdi_writeback *wb)
> +{
> +	return kernfs_path_len(wb->memcg_css->cgroup->kn) + 1;
> +}
> +
> +static inline void __trace_wb_assign_cgroup(char *buf, struct bdi_writeback *wb)
> +{
> +	struct cgroup *cgrp = wb->memcg_css->cgroup;
> +	char *path;
> +
> +	path = cgroup_path(cgrp, buf, kernfs_path_len(cgrp->kn) + 1);
> +	WARN_ON_ONCE(path != buf);
> +}
> +
> +static inline size_t __trace_wbc_cgroup_size(struct writeback_control *wbc)
> +{
> +	if (wbc->wb)
> +		return __trace_wb_cgroup_size(wbc->wb);
> +	else
> +		return 2;
> +}
> +
> +static inline void __trace_wbc_assign_cgroup(char *buf,
> +					     struct writeback_control *wbc)
> +{
> +	if (wbc->wb)
> +		__trace_wb_assign_cgroup(buf, wbc->wb);
> +	else
> +		strcpy(buf, "/");
> +}
> +
> +#else	/* CONFIG_CGROUP_WRITEBACK */
> +
> +static inline size_t __trace_wb_cgroup_size(struct bdi_writeback *wb)
> +{
> +	return 2;
> +}
> +
> +static inline void __trace_wb_assign_cgroup(char *buf, struct bdi_writeback *wb)
> +{
> +	strcpy(buf, "/");
> +}
> +
> +static inline size_t __trace_wbc_cgroup_size(struct writeback_control *wbc)
> +{
> +	return 2;
> +}
> +
> +static inline void __trace_wbc_assign_cgroup(char *buf,
> +					     struct writeback_control *wbc)
> +{
> +	strcpy(buf, "/");
> +}
> +
> +#endif	/* CONFIG_CGROUP_WRITEBACK */
> +#endif	/* CREATE_TRACE_POINTS */
> +
>  DECLARE_EVENT_CLASS(writeback_write_inode_template,
>  
>  	TP_PROTO(struct inode *inode, struct writeback_control *wbc),
> @@ -141,6 +201,7 @@ DECLARE_EVENT_CLASS(writeback_write_inod
>  		__array(char, name, 32)
>  		__field(unsigned long, ino)
>  		__field(int, sync_mode)
> +		__dynamic_array(char, cgroup, __trace_wbc_cgroup_size(wbc))
>  	),
>  
>  	TP_fast_assign(
> @@ -148,12 +209,14 @@ DECLARE_EVENT_CLASS(writeback_write_inod
>  			dev_name(inode_to_bdi(inode)->dev), 32);
>  		__entry->ino		= inode->i_ino;
>  		__entry->sync_mode	= wbc->sync_mode;
> +		__trace_wbc_assign_cgroup(__get_str(cgroup), wbc);
>  	),
>  
> -	TP_printk("bdi %s: ino=%lu sync_mode=%d",
> +	TP_printk("bdi %s: ino=%lu sync_mode=%d cgroup=%s",
>  		__entry->name,
>  		__entry->ino,
> -		__entry->sync_mode
> +		__entry->sync_mode,
> +		__get_str(cgroup)
>  	)
>  );
>  
> @@ -172,8 +235,8 @@ DEFINE_EVENT(writeback_write_inode_templ
>  );
>  
>  DECLARE_EVENT_CLASS(writeback_work_class,
> -	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work),
> -	TP_ARGS(bdi, work),
> +	TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work),
> +	TP_ARGS(wb, work),
>  	TP_STRUCT__entry(
>  		__array(char, name, 32)
>  		__field(long, nr_pages)
> @@ -183,10 +246,11 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		__field(int, range_cyclic)
>  		__field(int, for_background)
>  		__field(int, reason)
> +		__dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>  	),
>  	TP_fast_assign(
>  		strncpy(__entry->name,
> -			bdi->dev ? dev_name(bdi->dev) : "(unknown)", 32);
> +			wb->bdi->dev ? dev_name(wb->bdi->dev) : "(unknown)", 32);
>  		__entry->nr_pages = work->nr_pages;
>  		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
>  		__entry->sync_mode = work->sync_mode;
> @@ -194,9 +258,10 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		__entry->range_cyclic = work->range_cyclic;
>  		__entry->for_background	= work->for_background;
>  		__entry->reason = work->reason;
> +		__trace_wb_assign_cgroup(__get_str(cgroup), wb);
>  	),
>  	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
> -		  "kupdate=%d range_cyclic=%d background=%d reason=%s",
> +		  "kupdate=%d range_cyclic=%d background=%d reason=%s cgroup=%s",
>  		  __entry->name,
>  		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
>  		  __entry->nr_pages,
> @@ -204,13 +269,14 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		  __entry->for_kupdate,
>  		  __entry->range_cyclic,
>  		  __entry->for_background,
> -		  __print_symbolic(__entry->reason, WB_WORK_REASON)
> +		  __print_symbolic(__entry->reason, WB_WORK_REASON),
> +		  __get_str(cgroup)
>  	)
>  );
>  #define DEFINE_WRITEBACK_WORK_EVENT(name) \
>  DEFINE_EVENT(writeback_work_class, name, \
> -	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work), \
> -	TP_ARGS(bdi, work))
> +	TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work), \
> +	TP_ARGS(wb, work))
>  DEFINE_WRITEBACK_WORK_EVENT(writeback_queue);
>  DEFINE_WRITEBACK_WORK_EVENT(writeback_exec);
>  DEFINE_WRITEBACK_WORK_EVENT(writeback_start);
> @@ -230,26 +296,42 @@ TRACE_EVENT(writeback_pages_written,
>  );
>  
>  DECLARE_EVENT_CLASS(writeback_class,
> -	TP_PROTO(struct backing_dev_info *bdi),
> -	TP_ARGS(bdi),
> +	TP_PROTO(struct bdi_writeback *wb),
> +	TP_ARGS(wb),
>  	TP_STRUCT__entry(
>  		__array(char, name, 32)
> +		__dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>  	),
>  	TP_fast_assign(
> -		strncpy(__entry->name, dev_name(bdi->dev), 32);
> +		strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
> +		__trace_wb_assign_cgroup(__get_str(cgroup), wb);
>  	),
> -	TP_printk("bdi %s",
> -		  __entry->name
> +	TP_printk("bdi %s: cgroup=%s",
> +		  __entry->name,
> +		  __get_str(cgroup)
>  	)
>  );
>  #define DEFINE_WRITEBACK_EVENT(name) \
>  DEFINE_EVENT(writeback_class, name, \
> -	TP_PROTO(struct backing_dev_info *bdi), \
> -	TP_ARGS(bdi))
> +	TP_PROTO(struct bdi_writeback *wb), \
> +	TP_ARGS(wb))
>  
>  DEFINE_WRITEBACK_EVENT(writeback_nowork);
>  DEFINE_WRITEBACK_EVENT(writeback_wake_background);
> -DEFINE_WRITEBACK_EVENT(writeback_bdi_register);
> +
> +TRACE_EVENT(writeback_bdi_register,
> +	TP_PROTO(struct backing_dev_info *bdi),
> +	TP_ARGS(bdi),
> +	TP_STRUCT__entry(
> +		__array(char, name, 32)
> +	),
> +	TP_fast_assign(
> +		strncpy(__entry->name, dev_name(bdi->dev), 32);
> +	),
> +	TP_printk("bdi %s",
> +		__entry->name
> +	)
> +);
>  
>  DECLARE_EVENT_CLASS(wbc_class,
>  	TP_PROTO(struct writeback_control *wbc, struct backing_dev_info *bdi),
> @@ -265,6 +347,7 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__field(int, range_cyclic)
>  		__field(long, range_start)
>  		__field(long, range_end)
> +		__dynamic_array(char, cgroup, __trace_wbc_cgroup_size(wbc))
>  	),
>  
>  	TP_fast_assign(
> @@ -278,11 +361,12 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__entry->range_cyclic	= wbc->range_cyclic;
>  		__entry->range_start	= (long)wbc->range_start;
>  		__entry->range_end	= (long)wbc->range_end;
> +		__trace_wbc_assign_cgroup(__get_str(cgroup), wbc);
>  	),
>  
>  	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
>  		"bgrd=%d reclm=%d cyclic=%d "
> -		"start=0x%lx end=0x%lx",
> +		"start=0x%lx end=0x%lx cgroup=%s",
>  		__entry->name,
>  		__entry->nr_to_write,
>  		__entry->pages_skipped,
> @@ -292,7 +376,9 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__entry->for_reclaim,
>  		__entry->range_cyclic,
>  		__entry->range_start,
> -		__entry->range_end)
> +		__entry->range_end,
> +		__get_str(cgroup)
> +	)
>  )
>  
>  #define DEFINE_WBC_EVENT(name) \
> @@ -312,6 +398,7 @@ TRACE_EVENT(writeback_queue_io,
>  		__field(long,		age)
>  		__field(int,		moved)
>  		__field(int,		reason)
> +		__dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>  	),
>  	TP_fast_assign(
>  		unsigned long *older_than_this = work->older_than_this;
> @@ -321,13 +408,15 @@ TRACE_EVENT(writeback_queue_io,
>  				  (jiffies - *older_than_this) * 1000 / HZ : -1;
>  		__entry->moved	= moved;
>  		__entry->reason	= work->reason;
> +		__trace_wb_assign_cgroup(__get_str(cgroup), wb);
>  	),
> -	TP_printk("bdi %s: older=%lu age=%ld enqueue=%d reason=%s",
> +	TP_printk("bdi %s: older=%lu age=%ld enqueue=%d reason=%s cgroup=%s",
>  		__entry->name,
>  		__entry->older,	/* older_than_this in jiffies */
>  		__entry->age,	/* older_than_this in relative milliseconds */
>  		__entry->moved,
> -		__print_symbolic(__entry->reason, WB_WORK_REASON)
> +		__print_symbolic(__entry->reason, WB_WORK_REASON),
> +		__get_str(cgroup)
>  	)
>  );
>  
> @@ -381,11 +470,11 @@ TRACE_EVENT(global_dirty_state,
>  
>  TRACE_EVENT(bdi_dirty_ratelimit,
>  
> -	TP_PROTO(struct backing_dev_info *bdi,
> +	TP_PROTO(struct bdi_writeback *wb,
>  		 unsigned long dirty_rate,
>  		 unsigned long task_ratelimit),
>  
> -	TP_ARGS(bdi, dirty_rate, task_ratelimit),
> +	TP_ARGS(wb, dirty_rate, task_ratelimit),
>  
>  	TP_STRUCT__entry(
>  		__array(char,		bdi, 32)
> @@ -395,36 +484,39 @@ TRACE_EVENT(bdi_dirty_ratelimit,
>  		__field(unsigned long,	dirty_ratelimit)
>  		__field(unsigned long,	task_ratelimit)
>  		__field(unsigned long,	balanced_dirty_ratelimit)
> +		__dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>  	),
>  
>  	TP_fast_assign(
> -		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
> -		__entry->write_bw	= KBps(bdi->wb.write_bandwidth);
> -		__entry->avg_write_bw	= KBps(bdi->wb.avg_write_bandwidth);
> +		strlcpy(__entry->bdi, dev_name(wb->bdi->dev), 32);
> +		__entry->write_bw	= KBps(wb->write_bandwidth);
> +		__entry->avg_write_bw	= KBps(wb->avg_write_bandwidth);
>  		__entry->dirty_rate	= KBps(dirty_rate);
> -		__entry->dirty_ratelimit = KBps(bdi->wb.dirty_ratelimit);
> +		__entry->dirty_ratelimit = KBps(wb->dirty_ratelimit);
>  		__entry->task_ratelimit	= KBps(task_ratelimit);
>  		__entry->balanced_dirty_ratelimit =
> -					KBps(bdi->wb.balanced_dirty_ratelimit);
> +					KBps(wb->balanced_dirty_ratelimit);
> +		__trace_wb_assign_cgroup(__get_str(cgroup), wb);
>  	),
>  
>  	TP_printk("bdi %s: "
>  		  "write_bw=%lu awrite_bw=%lu dirty_rate=%lu "
>  		  "dirty_ratelimit=%lu task_ratelimit=%lu "
> -		  "balanced_dirty_ratelimit=%lu",
> +		  "balanced_dirty_ratelimit=%lu cgroup=%s",
>  		  __entry->bdi,
>  		  __entry->write_bw,		/* write bandwidth */
>  		  __entry->avg_write_bw,	/* avg write bandwidth */
>  		  __entry->dirty_rate,		/* bdi dirty rate */
>  		  __entry->dirty_ratelimit,	/* base ratelimit */
>  		  __entry->task_ratelimit, /* ratelimit with position control */
> -		  __entry->balanced_dirty_ratelimit /* the balanced ratelimit */
> +		  __entry->balanced_dirty_ratelimit, /* the balanced ratelimit */
> +		  __get_str(cgroup)
>  	)
>  );
>  
>  TRACE_EVENT(balance_dirty_pages,
>  
> -	TP_PROTO(struct backing_dev_info *bdi,
> +	TP_PROTO(struct bdi_writeback *wb,
>  		 unsigned long thresh,
>  		 unsigned long bg_thresh,
>  		 unsigned long dirty,
> @@ -437,7 +529,7 @@ TRACE_EVENT(balance_dirty_pages,
>  		 long pause,
>  		 unsigned long start_time),
>  
> -	TP_ARGS(bdi, thresh, bg_thresh, dirty, bdi_thresh, bdi_dirty,
> +	TP_ARGS(wb, thresh, bg_thresh, dirty, bdi_thresh, bdi_dirty,
>  		dirty_ratelimit, task_ratelimit,
>  		dirtied, period, pause, start_time),
>  
> @@ -456,11 +548,12 @@ TRACE_EVENT(balance_dirty_pages,
>  		__field(	 long,	pause)
>  		__field(unsigned long,	period)
>  		__field(	 long,	think)
> +		__dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>  	),
>  
>  	TP_fast_assign(
>  		unsigned long freerun = (thresh + bg_thresh) / 2;
> -		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
> +		strlcpy(__entry->bdi, dev_name(wb->bdi->dev), 32);
>  
>  		__entry->limit		= global_wb_domain.dirty_limit;
>  		__entry->setpoint	= (global_wb_domain.dirty_limit +
> @@ -478,6 +571,7 @@ TRACE_EVENT(balance_dirty_pages,
>  		__entry->period		= period * 1000 / HZ;
>  		__entry->pause		= pause * 1000 / HZ;
>  		__entry->paused		= (jiffies - start_time) * 1000 / HZ;
> +		__trace_wb_assign_cgroup(__get_str(cgroup), wb);
>  	),
>  
>  
> @@ -486,7 +580,7 @@ TRACE_EVENT(balance_dirty_pages,
>  		  "bdi_setpoint=%lu bdi_dirty=%lu "
>  		  "dirty_ratelimit=%lu task_ratelimit=%lu "
>  		  "dirtied=%u dirtied_pause=%u "
> -		  "paused=%lu pause=%ld period=%lu think=%ld",
> +		  "paused=%lu pause=%ld period=%lu think=%ld cgroup=%s",
>  		  __entry->bdi,
>  		  __entry->limit,
>  		  __entry->setpoint,
> @@ -500,7 +594,8 @@ TRACE_EVENT(balance_dirty_pages,
>  		  __entry->paused,	/* ms */
>  		  __entry->pause,	/* ms */
>  		  __entry->period,	/* ms */
> -		  __entry->think	/* ms */
> +		  __entry->think,	/* ms */
> +		  __get_str(cgroup)
>  	  )
>  );
>  
> @@ -514,6 +609,8 @@ TRACE_EVENT(writeback_sb_inodes_requeue,
>  		__field(unsigned long, ino)
>  		__field(unsigned long, state)
>  		__field(unsigned long, dirtied_when)
> +		__dynamic_array(char, cgroup,
> +				__trace_wb_cgroup_size(inode_to_wb(inode)))
>  	),
>  
>  	TP_fast_assign(
> @@ -522,14 +619,16 @@ TRACE_EVENT(writeback_sb_inodes_requeue,
>  		__entry->ino		= inode->i_ino;
>  		__entry->state		= inode->i_state;
>  		__entry->dirtied_when	= inode->dirtied_when;
> +		__trace_wb_assign_cgroup(__get_str(cgroup), inode_to_wb(inode));
>  	),
>  
> -	TP_printk("bdi %s: ino=%lu state=%s dirtied_when=%lu age=%lu",
> +	TP_printk("bdi %s: ino=%lu state=%s dirtied_when=%lu age=%lu cgroup=%s",
>  		  __entry->name,
>  		  __entry->ino,
>  		  show_inode_state(__entry->state),
>  		  __entry->dirtied_when,
> -		  (jiffies - __entry->dirtied_when) / HZ
> +		  (jiffies - __entry->dirtied_when) / HZ,
> +		  __get_str(cgroup)
>  	)
>  );
>  
> @@ -585,6 +684,7 @@ DECLARE_EVENT_CLASS(writeback_single_ino
>  		__field(unsigned long, writeback_index)
>  		__field(long, nr_to_write)
>  		__field(unsigned long, wrote)
> +		__dynamic_array(char, cgroup, __trace_wbc_cgroup_size(wbc))
>  	),
>  
>  	TP_fast_assign(
> @@ -596,10 +696,11 @@ DECLARE_EVENT_CLASS(writeback_single_ino
>  		__entry->writeback_index = inode->i_mapping->writeback_index;
>  		__entry->nr_to_write	= nr_to_write;
>  		__entry->wrote		= nr_to_write - wbc->nr_to_write;
> +		__trace_wbc_assign_cgroup(__get_str(cgroup), wbc);
>  	),
>  
>  	TP_printk("bdi %s: ino=%lu state=%s dirtied_when=%lu age=%lu "
> -		  "index=%lu to_write=%ld wrote=%lu",
> +		  "index=%lu to_write=%ld wrote=%lu cgroup=%s",
>  		  __entry->name,
>  		  __entry->ino,
>  		  show_inode_state(__entry->state),
> @@ -607,7 +708,8 @@ DECLARE_EVENT_CLASS(writeback_single_ino
>  		  (jiffies - __entry->dirtied_when) / HZ,
>  		  __entry->writeback_index,
>  		  __entry->nr_to_write,
> -		  __entry->wrote
> +		  __entry->wrote,
> +		  __get_str(cgroup)
>  	)
>  );
>  
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1289,7 +1289,7 @@ static void wb_update_dirty_ratelimit(st
>  	wb->dirty_ratelimit = max(dirty_ratelimit, 1UL);
>  	wb->balanced_dirty_ratelimit = balanced_dirty_ratelimit;
>  
> -	trace_bdi_dirty_ratelimit(wb->bdi, dirty_rate, task_ratelimit);
> +	trace_bdi_dirty_ratelimit(wb, dirty_rate, task_ratelimit);
>  }
>  
>  static void __wb_update_bandwidth(struct dirty_throttle_control *gdtc,
> @@ -1683,7 +1683,7 @@ static void balance_dirty_pages(struct a
>  		 * do a reset, as it may be a light dirtier.
>  		 */
>  		if (pause < min_pause) {
> -			trace_balance_dirty_pages(bdi,
> +			trace_balance_dirty_pages(wb,
>  						  sdtc->thresh,
>  						  sdtc->bg_thresh,
>  						  sdtc->dirty,
> @@ -1712,7 +1712,7 @@ static void balance_dirty_pages(struct a
>  		}
>  
>  pause:
> -		trace_balance_dirty_pages(bdi,
> +		trace_balance_dirty_pages(wb,
>  					  sdtc->thresh,
>  					  sdtc->bg_thresh,
>  					  sdtc->dirty,
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
