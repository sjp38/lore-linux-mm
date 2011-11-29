Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AB8E76B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 10:21:09 -0500 (EST)
Date: Tue, 29 Nov 2011 16:21:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-ID: <20111129152106.GN5635@quack.suse.cz>
References: <20111129130900.628549879@intel.com>
 <20111129131456.666312513@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129131456.666312513@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 29-11-11 21:09:06, Wu Fengguang wrote:
> The accounting code will be compiled in by default (CONFIG_READAHEAD_STATS=y),
> and will remain inactive by default.
> 
> It can be runtime enabled/disabled through the debugfs interface
> 
> 	echo 1 > /debug/readahead/stats_enable
> 	echo 0 > /debug/readahead/stats_enable
> 
> The added overheads are two readahead_stats() calls per readahead.
> Which is trivial costs unless there are concurrent random reads on
> super fast SSDs, which may lead to cache bouncing when updating the
> global ra_stats[][]. Considering that normal users won't need this
> except when debugging performance problems, it's disabled by default.
> So it looks reasonable to keep this debug code simple rather than trying
> to improve its scalability.
> 
> Example output:
> (taken from a fresh booted NFS-ROOT console box with rsize=524288)
> 
> $ cat /debug/readahead/stats
> pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io    meta_io       size async_size    io_size
> initial           702        511          0        692        692          0          0          2          0          2
> subsequent          7          0          1          7          1          1          0         23         22         23
> context           160        161          0          2          0          1          0          0          0         16
> around            184        184        177        184        184        184          0         58          0         53
> backwards           2          0          2          2          2          0          0          4          0          3
> fadvise          2593         47          8       2588       2588          0          0          1          0          1
> oversize            0          0          0          0          0          0          0          0          0          0
> random             45         20          0         44         44          0          0          1          0          1
> all              3697        923        188       3519       3511        186          0          4          0          4
> 
> The two most important columns are
> - io		number of readahead IO
> - io_size	average readahead IO size
> 
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Jens Axboe <axboe@kernel.dk>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
  This looks all inherently racy (which doesn't matter much as you suggest)
so I just wanted to suggest that if you used per-cpu counters you'd get
race-free and faster code at the cost of larger data structures and using
percpu_counter_add() instead of ++ (which doesn't seem like a big
complication to me).

								Honza
> ---
>  mm/Kconfig     |   15 +++
>  mm/readahead.c |  194 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 209 insertions(+)
> 
> --- linux-next.orig/mm/readahead.c	2011-11-29 20:48:05.000000000 +0800
> +++ linux-next/mm/readahead.c	2011-11-29 20:58:53.000000000 +0800
> @@ -18,6 +18,17 @@
>  #include <linux/pagevec.h>
>  #include <linux/pagemap.h>
>  
> +static const char * const ra_pattern_names[] = {
> +	[RA_PATTERN_INITIAL]            = "initial",
> +	[RA_PATTERN_SUBSEQUENT]         = "subsequent",
> +	[RA_PATTERN_CONTEXT]            = "context",
> +	[RA_PATTERN_MMAP_AROUND]        = "around",
> +	[RA_PATTERN_FADVISE]            = "fadvise",
> +	[RA_PATTERN_OVERSIZE]           = "oversize",
> +	[RA_PATTERN_RANDOM]             = "random",
> +	[RA_PATTERN_ALL]                = "all",
> +};
> +
>  /*
>   * Initialise a struct file's readahead state.  Assumes that the caller has
>   * memset *ra to zero.
> @@ -32,6 +43,181 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
>  
>  #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
>  
> +#ifdef CONFIG_READAHEAD_STATS
> +#include <linux/seq_file.h>
> +#include <linux/debugfs.h>
> +
> +static u32 readahead_stats_enable __read_mostly;
> +
> +enum ra_account {
> +	/* number of readaheads */
> +	RA_ACCOUNT_COUNT,	/* readahead request */
> +	RA_ACCOUNT_EOF,		/* readahead request covers EOF */
> +	RA_ACCOUNT_CACHE_HIT,	/* readahead request covers some cached pages */
> +	RA_ACCOUNT_IOCOUNT,	/* readahead IO */
> +	RA_ACCOUNT_SYNC,	/* readahead IO that is synchronous */
> +	RA_ACCOUNT_MMAP,	/* readahead IO by mmap page faults */
> +	RA_ACCOUNT_METADATA,	/* readahead IO on metadata */
> +	/* number of readahead pages */
> +	RA_ACCOUNT_SIZE,	/* readahead size */
> +	RA_ACCOUNT_ASYNC_SIZE,	/* readahead async size */
> +	RA_ACCOUNT_ACTUAL,	/* readahead actual IO size */
> +	/* end mark */
> +	RA_ACCOUNT_MAX,
> +};
> +
> +static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
> +
> +static void readahead_stats(struct address_space *mapping,
> +			    pgoff_t offset,
> +			    unsigned long req_size,
> +			    bool for_mmap,
> +			    bool for_metadata,
> +			    enum readahead_pattern pattern,
> +			    pgoff_t start,
> +			    unsigned long size,
> +			    unsigned long async_size,
> +			    int actual)
> +{
> +	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
> +
> +recount:
> +	ra_stats[pattern][RA_ACCOUNT_COUNT]++;
> +	ra_stats[pattern][RA_ACCOUNT_SIZE] += size;
> +	ra_stats[pattern][RA_ACCOUNT_ASYNC_SIZE] += async_size;
> +	ra_stats[pattern][RA_ACCOUNT_ACTUAL] += actual;
> +
> +	if (start + size >= eof)
> +		ra_stats[pattern][RA_ACCOUNT_EOF]++;
> +	if (actual < size)
> +		ra_stats[pattern][RA_ACCOUNT_CACHE_HIT]++;
> +
> +	if (actual) {
> +		ra_stats[pattern][RA_ACCOUNT_IOCOUNT]++;
> +
> +		if (start <= offset && offset < start + size)
> +			ra_stats[pattern][RA_ACCOUNT_SYNC]++;
> +
> +		if (for_mmap)
> +			ra_stats[pattern][RA_ACCOUNT_MMAP]++;
> +		if (for_metadata)
> +			ra_stats[pattern][RA_ACCOUNT_METADATA]++;
> +	}
> +
> +	if (pattern != RA_PATTERN_ALL) {
> +		pattern = RA_PATTERN_ALL;
> +		goto recount;
> +	}
> +}
> +
> +static int readahead_stats_show(struct seq_file *s, void *_)
> +{
> +	unsigned long i;
> +
> +	seq_printf(s,
> +		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
> +		   "pattern", "readahead", "eof_hit", "cache_hit",
> +		   "io", "sync_io", "mmap_io", "meta_io",
> +		   "size", "async_size", "io_size");
> +
> +	for (i = 0; i < RA_PATTERN_MAX; i++) {
> +		unsigned long count = ra_stats[i][RA_ACCOUNT_COUNT];
> +		unsigned long iocount = ra_stats[i][RA_ACCOUNT_IOCOUNT];
> +		/*
> +		 * avoid division-by-zero
> +		 */
> +		if (count == 0)
> +			count = 1;
> +		if (iocount == 0)
> +			iocount = 1;
> +
> +		seq_printf(s, "%-10s %10lu %10lu %10lu %10lu %10lu "
> +			   "%10lu %10lu %10lu %10lu %10lu\n",
> +				ra_pattern_names[i],
> +				ra_stats[i][RA_ACCOUNT_COUNT],
> +				ra_stats[i][RA_ACCOUNT_EOF],
> +				ra_stats[i][RA_ACCOUNT_CACHE_HIT],
> +				ra_stats[i][RA_ACCOUNT_IOCOUNT],
> +				ra_stats[i][RA_ACCOUNT_SYNC],
> +				ra_stats[i][RA_ACCOUNT_MMAP],
> +				ra_stats[i][RA_ACCOUNT_METADATA],
> +				ra_stats[i][RA_ACCOUNT_SIZE] / count,
> +				ra_stats[i][RA_ACCOUNT_ASYNC_SIZE] / count,
> +				ra_stats[i][RA_ACCOUNT_ACTUAL] / iocount);
> +	}
> +
> +	return 0;
> +}
> +
> +static int readahead_stats_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, readahead_stats_show, NULL);
> +}
> +
> +static ssize_t readahead_stats_write(struct file *file, const char __user *buf,
> +				     size_t size, loff_t *offset)
> +{
> +	memset(ra_stats, 0, sizeof(ra_stats));
> +	return size;
> +}
> +
> +static const struct file_operations readahead_stats_fops = {
> +	.owner		= THIS_MODULE,
> +	.open		= readahead_stats_open,
> +	.write		= readahead_stats_write,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= single_release,
> +};
> +
> +static int __init readahead_create_debugfs(void)
> +{
> +	struct dentry *root;
> +	struct dentry *entry;
> +
> +	root = debugfs_create_dir("readahead", NULL);
> +	if (!root)
> +		goto out;
> +
> +	entry = debugfs_create_file("stats", 0644, root,
> +				    NULL, &readahead_stats_fops);
> +	if (!entry)
> +		goto out;
> +
> +	entry = debugfs_create_bool("stats_enable", 0644, root,
> +				    &readahead_stats_enable);
> +	if (!entry)
> +		goto out;
> +
> +	return 0;
> +out:
> +	printk(KERN_ERR "readahead: failed to create debugfs entries\n");
> +	return -ENOMEM;
> +}
> +
> +late_initcall(readahead_create_debugfs);
> +#endif
> +
> +static inline void readahead_event(struct address_space *mapping,
> +				   pgoff_t offset,
> +				   unsigned long req_size,
> +				   bool for_mmap,
> +				   bool for_metadata,
> +				   enum readahead_pattern pattern,
> +				   pgoff_t start,
> +				   unsigned long size,
> +				   unsigned long async_size,
> +				   int actual)
> +{
> +#ifdef CONFIG_READAHEAD_STATS
> +	if (readahead_stats_enable)
> +		readahead_stats(mapping, offset, req_size,
> +				for_mmap, for_metadata,
> +				pattern, start, size, async_size, actual);
> +#endif
> +}
> +
> +
>  /*
>   * see if a page needs releasing upon read_cache_pages() failure
>   * - the caller of read_cache_pages() may have set PG_private or PG_fscache
> @@ -228,6 +414,9 @@ int force_page_cache_readahead(struct ad
>  			ret = err;
>  			break;
>  		}
> +		readahead_event(mapping, offset, nr_to_read, 0, 0,
> +				RA_PATTERN_FADVISE, offset, this_chunk, 0,
> +				err);
>  		ret += err;
>  		offset += this_chunk;
>  		nr_to_read -= this_chunk;
> @@ -267,6 +456,11 @@ unsigned long ra_submit(struct file_ra_s
>  	actual = __do_page_cache_readahead(mapping, filp,
>  					ra->start, ra->size, ra->async_size);
>  
> +	readahead_event(mapping, offset, req_size,
> +			ra->for_mmap, ra->for_metadata,
> +			ra->pattern, ra->start, ra->size, ra->async_size,
> +			actual);
> +
>  	ra->for_mmap = 0;
>  	ra->for_metadata = 0;
>  	return actual;
> --- linux-next.orig/mm/Kconfig	2011-11-29 20:48:05.000000000 +0800
> +++ linux-next/mm/Kconfig	2011-11-29 20:48:05.000000000 +0800
> @@ -373,3 +373,18 @@ config CLEANCACHE
>  	  in a negligible performance hit.
>  
>  	  If unsure, say Y to enable cleancache
> +
> +config READAHEAD_STATS
> +	bool "Collect page cache readahead stats"
> +	depends on DEBUG_FS
> +	default y
> +	help
> +	  This provides the readahead events accounting facilities.
> +
> +	  To do readahead accounting for a workload:
> +
> +	  echo 1 > /sys/kernel/debug/readahead/stats_enable
> +	  echo 0 > /sys/kernel/debug/readahead/stats  # reset counters
> +	  # run the workload
> +	  cat /sys/kernel/debug/readahead/stats       # check counters
> +	  echo 0 > /sys/kernel/debug/readahead/stats_enable
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
