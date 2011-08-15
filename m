Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CFC466B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 11:03:54 -0400 (EDT)
Date: Mon, 15 Aug 2011 17:03:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110815150348.GC6597@quack.suse.cz>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313189245-7197-2-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri 12-08-11 15:47:25, Curt Wohlgemuth wrote:
> Add a new file, /proc/writeback/stats, which displays
> machine global data for how many pages were cleaned for
> which reasons.  It also displays some additional counts for
> various writeback events.
> 
> These data are also available for each BDI, in
> /sys/block/<device>/bdi/writeback_stats .
  I think /sys/kernel/debug/bdi/<device>/writeback_stats might be a better
place since we don't really want to make a stable interface out of this,
do we?

> Sample output:
> 
>    page: balance_dirty_pages           2561544
>    page: background_writeout              5153
>    page: try_to_free_pages                   0
>    page: sync                                0
>    page: kupdate                        102723
>    page: fdatawrite                    1228779
>    page: laptop_periodic                     0
>    page: free_more_memory                    0
>    page: fs_free_space                       0
  The above stats are probably useful. I'm not so convinced about the stats
below - it looks like it should be simple enough to get them by enabling
some trace points and processing output (or if we are missing some
tracepoints, it would be worthwhile to add them).

>    periodic writeback                      377
>    single inode wait                         0
>    writeback_wb wait                         1
> 
> Signed-off-by: Curt Wohlgemuth <curtw@google.com>
...
> +static size_t writeback_stats_to_str(struct writeback_stats *stats,
> +				    char *buf, size_t len)
> +{
> +	int bufsize = len - 1;
> +	int i, printed = 0;
> +	for (i = 0; i < WB_STAT_MAX; i++) {
> +		const char *label = wb_stats_labels[i];
> +		if (label == NULL)
> +			continue;
> +		printed += snprintf(buf + printed, bufsize - printed,
> +				"%-32s %10llu\n", label, stats->stats[i]);
  Cast stats->stats[i] to unsigned long long explicitely since it doesn't
have to be u64...

> +		if (printed >= bufsize) {
> +			buf[len - 1] = '\n';
> +			return len;
> +		}
> +	}
> +
> +	buf[printed - 1] = '\n';
> +	return printed;
> +}
> +
> +static int writeback_seq_show(struct seq_file *m, void *data)
> +{
> +	char *buf;
> +	size_t size;
> +	switch ((enum writeback_op)m->private) {
> +	case WB_STATS_OP:
  What's the point of WB_STATS_OP?

> +		size = seq_get_buf(m, &buf);
> +		if (size == 0)
> +			return 0;
> +		size = writeback_stats_print(writeback_sys_stats, buf, size);
> +		seq_commit(m, size);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	return 0;
> +}
> +
> +static int writeback_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, writeback_seq_show, PDE(inode)->data);
> +}
> +
> +static const struct file_operations writeback_ops = {
> +	.open           = writeback_open,
> +	.read           = seq_read,
> +	.llseek         = seq_lseek,
> +	.release        = single_release,
> +};
> +
> +
> +void __init proc_writeback_init(void)
> +{
> +	struct proc_dir_entry *base_dir;
> +	base_dir = proc_mkdir("writeback", NULL);
> +	if (base_dir == NULL) {
> +		printk(KERN_ERR "Creating /proc/writeback/ failed");
> +		return;
> +	}
> +
> +	writeback_sys_stats = alloc_percpu(struct writeback_stats);
> +
> +	proc_create_data("stats", S_IRUGO|S_IWUSR, base_dir,
  Can user really write to the file?

> +			&writeback_ops, (void *)WB_STATS_OP);
> +}

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
