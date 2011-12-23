Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8F0DE6B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 06:16:35 -0500 (EST)
Date: Fri, 23 Dec 2011 12:16:11 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-ID: <20111223111611.GB22691@quack.suse.cz>
References: <20111129130900.628549879@intel.com>
 <20111129131456.666312513@intel.com>
 <20111129152106.GN5635@quack.suse.cz>
 <20111214063625.GA13824@localhost>
 <20111219163241.GA4107@quack.suse.cz>
 <20111221012935.GA13231@localhost>
 <20111221040656.GB23662@dastard>
 <20111223033320.GA21390@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111223033320.GA21390@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 23-12-11 11:33:20, Wu Fengguang wrote:
> On Wed, Dec 21, 2011 at 12:06:56PM +0800, Dave Chinner wrote:
> > On Wed, Dec 21, 2011 at 09:29:36AM +0800, Wu Fengguang wrote:
> > > On Tue, Dec 20, 2011 at 12:32:41AM +0800, Jan Kara wrote:
> > > > On Wed 14-12-11 14:36:25, Wu Fengguang wrote:
> > > > > >   This looks all inherently racy (which doesn't matter much as you suggest)
> > > > > > so I just wanted to suggest that if you used per-cpu counters you'd get
> > > > > > race-free and faster code at the cost of larger data structures and using
> > > > > > percpu_counter_add() instead of ++ (which doesn't seem like a big
> > > > > > complication to me).
> > > > > 
> > > > > OK, here is the incremental patch to use per-cpu counters :)
> > > >   Thanks! This looks better. I just thought you would use per-cpu counters
> > > > as defined in include/linux/percpu_counter.h and are used e.g. by bdi
> > > > stats. This is more standard for statistics in the kernel than using
> > > > per-cpu variables directly.
> > > 
> > > Ah yes, I overlooked that facility! However the percpu_counter's
> > > ability to maintain and quickly retrieve the global value seems
> > > unnecessary feature/overheads for readahead stats, because here we
> > > only need to sum up the global value when the user requests it. If
> > > switching to percpu_counter, I'm afraid every readahead(1MB) event
> > > will lead to the update of percpu_counter global value (grabbing the
> > > spinlock) due to 1MB > some small batch size. This actually performs
> > > worse than the plain global array of values in the v1 patch.
> > 
> > So use a custom batch size so that typical increments don't require
> > locking for every add. The bdi stat counters are an example of this
> > sort of setup to reduce lock contention on typical IO workloads as
> > concurrency increases.
> > 
> > All these stats have is a requirement for a different batch size to
> > avoid frequent lock grabs. The stats don't have to update the global
> > counter very often (only to prvent overflow!) so you count get away
> > with a batch size in the order of 2^30 without any issues....
> > 
> > We have a general per-cpu counter infrastructure - we should be
> > using it and improving it and not reinventing it a different way
> > every time we need a per-cpu counter.
> 
> OK, let's try using percpu_counter, with a huge batch size.
> 
> It actually adds both code size and runtime overheads slightly.
> Are you sure you like this incremental patch?
  Well, I like it because it's easier to see the code is doing the right
thing when it's using standard kernel infrastructure...

								Honza

> ---
>  mm/readahead.c |   74 ++++++++++++++++++++++++++---------------------
>  1 file changed, 41 insertions(+), 33 deletions(-)
> 
> --- linux-next.orig/mm/readahead.c	2011-12-23 10:04:32.000000000 +0800
> +++ linux-next/mm/readahead.c	2011-12-23 11:18:35.000000000 +0800
> @@ -61,7 +61,18 @@ enum ra_account {
>  	RA_ACCOUNT_MAX,
>  };
>  
> -static DEFINE_PER_CPU(unsigned long[RA_PATTERN_ALL][RA_ACCOUNT_MAX], ra_stat);
> +#define RA_STAT_BATCH	(INT_MAX / 2)
> +static struct percpu_counter ra_stat[RA_PATTERN_ALL][RA_ACCOUNT_MAX];
> +
> +static inline void add_ra_stat(int i, int j, s64 amount)
> +{
> +	__percpu_counter_add(&ra_stat[i][j], amount, RA_STAT_BATCH);
> +}
> +
> +static inline void inc_ra_stat(int i, int j)
> +{
> +	add_ra_stat(i, j, 1);
> +}
>  
>  static void readahead_stats(struct address_space *mapping,
>  			    pgoff_t offset,
> @@ -76,62 +87,54 @@ static void readahead_stats(struct addre
>  {
>  	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
>  
> -	preempt_disable();
> -
> -	__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_COUNT]);
> -	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_SIZE], size);
> -	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ASYNC_SIZE], async_size);
> -	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ACTUAL], actual);
> +	inc_ra_stat(pattern, RA_ACCOUNT_COUNT);
> +	add_ra_stat(pattern, RA_ACCOUNT_SIZE, size);
> +	add_ra_stat(pattern, RA_ACCOUNT_ASYNC_SIZE, async_size);
> +	add_ra_stat(pattern, RA_ACCOUNT_ACTUAL, actual);
>  
>  	if (start + size >= eof)
> -		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_EOF]);
> +		inc_ra_stat(pattern, RA_ACCOUNT_EOF);
>  	if (actual < size)
> -		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_CACHE_HIT]);
> +		inc_ra_stat(pattern, RA_ACCOUNT_CACHE_HIT);
>  
>  	if (actual) {
> -		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_IOCOUNT]);
> +		inc_ra_stat(pattern, RA_ACCOUNT_IOCOUNT);
>  
>  		if (start <= offset && offset < start + size)
> -			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_SYNC]);
> +			inc_ra_stat(pattern, RA_ACCOUNT_SYNC);
>  
>  		if (for_mmap)
> -			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_MMAP]);
> +			inc_ra_stat(pattern, RA_ACCOUNT_MMAP);
>  		if (for_metadata)
> -			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_METADATA]);
> +			inc_ra_stat(pattern, RA_ACCOUNT_METADATA);
>  	}
> -
> -	preempt_enable();
>  }
>  
>  static void ra_stats_clear(void)
>  {
> -	int cpu;
>  	int i, j;
>  
> -	for_each_online_cpu(cpu)
> -		for (i = 0; i < RA_PATTERN_ALL; i++)
> -			for (j = 0; j < RA_ACCOUNT_MAX; j++)
> -				per_cpu(ra_stat[i][j], cpu) = 0;
> +	for (i = 0; i < RA_PATTERN_ALL; i++)
> +		for (j = 0; j < RA_ACCOUNT_MAX; j++)
> +			percpu_counter_set(&ra_stat[i][j], 0);
>  }
>  
> -static void ra_stats_sum(unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX])
> +static void ra_stats_sum(long long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX])
>  {
> -	int cpu;
>  	int i, j;
>  
> -	for_each_online_cpu(cpu)
> -		for (i = 0; i < RA_PATTERN_ALL; i++)
> -			for (j = 0; j < RA_ACCOUNT_MAX; j++) {
> -				unsigned long n = per_cpu(ra_stat[i][j], cpu);
> -				ra_stats[i][j] += n;
> -				ra_stats[RA_PATTERN_ALL][j] += n;
> -			}
> +	for (i = 0; i < RA_PATTERN_ALL; i++)
> +		for (j = 0; j < RA_ACCOUNT_MAX; j++) {
> +			s64 n = percpu_counter_sum(&ra_stat[i][j]);
> +			ra_stats[i][j] += n;
> +			ra_stats[RA_PATTERN_ALL][j] += n;
> +		}
>  }
>  
>  static int readahead_stats_show(struct seq_file *s, void *_)
>  {
> -	unsigned long i;
> -	unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
> +	long long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
> +	int i;
>  
>  	seq_printf(s,
>  		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
> @@ -153,8 +156,8 @@ static int readahead_stats_show(struct s
>  		if (iocount == 0)
>  			iocount = 1;
>  
> -		seq_printf(s, "%-10s %10lu %10lu %10lu %10lu %10lu "
> -			   "%10lu %10lu %10lu %10lu %10lu\n",
> +		seq_printf(s, "%-10s %10lld %10lld %10lld %10lld %10lld "
> +			   "%10lld %10lld %10lld %10lld %10lld\n",
>  				ra_pattern_names[i].name,
>  				ra_stats[i][RA_ACCOUNT_COUNT],
>  				ra_stats[i][RA_ACCOUNT_EOF],
> @@ -196,6 +199,7 @@ static int __init readahead_create_debug
>  {
>  	struct dentry *root;
>  	struct dentry *entry;
> +	int i, j;
>  
>  	root = debugfs_create_dir("readahead", NULL);
>  	if (!root)
> @@ -211,6 +215,10 @@ static int __init readahead_create_debug
>  	if (!entry)
>  		goto out;
>  
> +	for (i = 0; i < RA_PATTERN_ALL; i++)
> +		for (j = 0; j < RA_ACCOUNT_MAX; j++)
> +			percpu_counter_init(&ra_stat[i][j], 0);
> +
>  	return 0;
>  out:
>  	printk(KERN_ERR "readahead: failed to create debugfs entries\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
