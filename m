Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A81296B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 18:30:01 -0500 (EST)
Date: Mon, 21 Nov 2011 15:29:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-Id: <20111121152958.e4fd76d4.akpm@linux-foundation.org>
In-Reply-To: <20111121093846.636765408@intel.com>
References: <20111121091819.394895091@intel.com>
	<20111121093846.636765408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, 21 Nov 2011 17:18:24 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> The accounting code will be compiled in by default (CONFIG_READAHEAD_STATS=y),
> and will remain inactive unless enabled explicitly with either boot option
> 
> 	readahead_stats=1
> 
> or through the debugfs interface
> 
> 	echo 1 > /debug/readahead/stats_enable

It's unfortunate that these two things have different names.

I'd have thought that the debugfs knob was sufficient - no need for the
boot option.

> The added overheads are two readahead_stats() calls per readahead.
> Which is trivial costs unless there are concurrent random reads on
> super fast SSDs, which may lead to cache bouncing when updating the
> global ra_stats[][]. Considering that normal users won't need this
> except when debugging performance problems, it's disabled by default.
> So it looks reasonable to keep this debug code simple rather than trying
> to improve its scalability.

I may be wrong, but I don't think the CPU cost of this code matters a
lot.  People will rarely turn it on and disk IO is a lot slower than
CPU actions and it's waaaaaaay more important to get high-quality info
about readahead than it is to squeeze out a few CPU cycles.

>
> ...
>
> @@ -51,6 +62,182 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
>  
>  #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
>  
> +#ifdef CONFIG_READAHEAD_STATS
> +#include <linux/seq_file.h>
> +#include <linux/debugfs.h>
> +
> +static u32 readahead_stats_enable __read_mostly;
> +
> +static int __init config_readahead_stats(char *str)
> +{
> +	int enable = 1;
> +	get_option(&str, &enable);
> +	readahead_stats_enable = enable;
> +	return 0;
> +}
> +early_param("readahead_stats", config_readahead_stats);

Why use early_param() rather than plain old __setup()?

> +enum ra_account {
> +	/* number of readaheads */
> +	RA_ACCOUNT_COUNT,	/* readahead request */
> +	RA_ACCOUNT_EOF,		/* readahead request covers EOF */
> +	RA_ACCOUNT_CHIT,	/* readahead request covers some cached pages */

I don't like chit :)  "cache_hit" would be better.  Or just "hit".

> +	RA_ACCOUNT_IOCOUNT,	/* readahead IO */
> +	RA_ACCOUNT_SYNC,	/* readahead IO that is synchronous */
> +	RA_ACCOUNT_MMAP,	/* readahead IO by mmap page faults */
> +	/* number of readahead pages */
> +	RA_ACCOUNT_SIZE,	/* readahead size */
> +	RA_ACCOUNT_ASIZE,	/* readahead async size */
> +	RA_ACCOUNT_ACTUAL,	/* readahead actual IO size */
> +	/* end mark */
> +	RA_ACCOUNT_MAX,
> +};
> +
>
> ...
>
> +static void readahead_event(struct address_space *mapping,
> +			    pgoff_t offset,
> +			    unsigned long req_size,
> +			    unsigned int ra_flags,
> +			    pgoff_t start,
> +			    unsigned int size,
> +			    unsigned int async_size,
> +			    unsigned int actual)
> +{
> +#ifdef CONFIG_READAHEAD_STATS
> +	if (readahead_stats_enable) {
> +		readahead_stats(mapping, offset, req_size, ra_flags,
> +				start, size, async_size, actual);
> +		readahead_stats(mapping, offset, req_size,
> +				RA_PATTERN_ALL << READAHEAD_PATTERN_SHIFT,
> +				start, size, async_size, actual);
> +	}
> +#endif
> +}

The stub should be inlined, methinks.  The overhead of evaluating and
preparing eight arguments is significant.  I don't think the compiler
is yet smart enough to save us.

>
> ...
>
> --- linux-next.orig/Documentation/kernel-parameters.txt	2011-11-21 17:08:38.000000000 +0800
> +++ linux-next/Documentation/kernel-parameters.txt	2011-11-21 17:08:51.000000000 +0800
> @@ -2251,6 +2251,12 @@ bytes respectively. Such letter suffixes
>  			This default max readahead size may be overrode
>  			in some cases, notably NFS, btrfs and software RAID.
>  
> +	readahead_stats[=0|1]
> +			Enable/disable readahead stats accounting.
> +
> +			It's also possible to enable/disable it after boot:
> +			echo 1 > /sys/kernel/debug/readahead/stats_enable

Can the current setting be read back?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
