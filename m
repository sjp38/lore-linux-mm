Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C1A046B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 17:24:17 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1582670pad.30
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:24:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qc1si6589216pac.68.2014.05.15.14.24.16
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 14:24:16 -0700 (PDT)
Date: Thu, 15 May 2014 14:24:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v4
Message-Id: <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
In-Reply-To: <20140515104808.GF23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-20-git-send-email-mgorman@suse.de>
	<20140513125313.GR23991@suse.de>
	<20140513141748.GD2485@laptop.programming.kicks-ass.net>
	<20140514161152.GA2615@redhat.com>
	<20140514192945.GA10830@redhat.com>
	<20140515104808.GF23991@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, 15 May 2014 11:48:09 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Changelog since v3
> o Correct handling of exclusive waits
> 
> This patch introduces a new page flag for 64-bit capable machines,
> PG_waiters, to signal there are processes waiting on PG_lock and uses it to
> avoid memory barriers and waitqueue hash lookup in the unlock_page fastpath.
> 
> This adds a few branches to the fast path but avoids bouncing a dirty
> cache line between CPUs. 32-bit machines always take the slow path but the
> primary motivation for this patch is large machines so I do not think that
> is a concern.
> 
> The test case used to evaulate this is a simple dd of a large file done
> multiple times with the file deleted on each iterations. The size of
> the file is 1/10th physical memory to avoid dirty page balancing. In the
> async case it will be possible that the workload completes without even
> hitting the disk and will have variable results but highlight the impact
> of mark_page_accessed for async IO. The sync results are expected to be
> more stable. The exception is tmpfs where the normal case is for the "IO"
> to not hit the disk.
> 
> The test machine was single socket and UMA to avoid any scheduling or
> NUMA artifacts. Throughput and wall times are presented for sync IO, only
> wall times are shown for async as the granularity reported by dd and the
> variability is unsuitable for comparison. As async results were variable
> do to writback timings, I'm only reporting the maximum figures. The sync
> results were stable enough to make the mean and stddev uninteresting.
> 
> The performance results are reported based on a run with no profiling.
> Profile data is based on a separate run with oprofile running. The
> kernels being compared are "accessed-v2" which is the patch series up
> to this patch where as lockpage-v2 includes this patch.
> 
> async dd
>                                    3.15.0-rc3            3.15.0-rc3
>                                   accessed-v3           lockpage-v3
> ext3   Max      elapsed     11.5900 (  0.00%)     11.0000 (  5.09%)
> ext4   Max      elapsed     13.3400 (  0.00%)     13.4300 ( -0.67%)
> tmpfs  Max      elapsed      0.4900 (  0.00%)      0.4800 (  2.04%)
> btrfs  Max      elapsed     12.7800 (  0.00%)     13.8200 ( -8.14%)
> xfs    Max      elapsed      2.0900 (  0.00%)      2.1100 ( -0.96%)

So ext3 got 5% faster and btrfs got 8% slower?

>
> ...
>

The numbers look pretty marginal from here and the patch is, umm, not a
thing of beauty or simplicity.

I'd be inclined to go find something else to work on, frankly.

> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -241,15 +241,22 @@ void delete_from_page_cache(struct page *page)
>  }
>  EXPORT_SYMBOL(delete_from_page_cache);
>  
> -static int sleep_on_page(void *word)
> +static int sleep_on_page(struct page *page)
>  {
> -	io_schedule();
> +	/*
> +	 * A racing unlock can miss that the waitqueue is active and clear the
> +	 * waiters again. Only sleep if PageWaiters is still set and timeout
> +	 * to recheck as races can still occur.
> +	 */
> +	if (PageWaiters(page))
> +		io_schedule_timeout(HZ);

ew.

>  	return 0;
>  }
>  
> ...
>
> +/* Returns true if the page is locked */

Comment is inaccurate.

> +static inline bool prepare_wait_bit(struct page *page, wait_queue_head_t *wqh,
> +			wait_queue_t *wq, int state, int bit_nr, bool exclusive)
> +{
> +
> +	/* Set PG_waiters so a racing unlock_page will check the waitiqueue */
> +	if (!PageWaiters(page))
> +		SetPageWaiters(page);
> +
> +	if (exclusive)
> +		prepare_to_wait_exclusive(wqh, wq, state);
> +	else
> +		prepare_to_wait(wqh, wq, state);
> +	return test_bit(bit_nr, &page->flags);
>  }
>
> ...
>
>  int wait_on_page_bit_killable(struct page *page, int bit_nr)
>  {
> +	wait_queue_head_t *wqh;
>  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> +	int ret = 0;
>  
>  	if (!test_bit(bit_nr, &page->flags))
>  		return 0;
> +	wqh = page_waitqueue(page);
> +
> +	do {
> +		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, false))
> +			ret = sleep_on_page_killable(page);
> +	} while (!ret && test_bit(bit_nr, &page->flags));
> +	finish_wait(wqh, &wait.wait);
>  
> -	return __wait_on_bit(page_waitqueue(page), &wait,
> -			     sleep_on_page_killable, TASK_KILLABLE);
> +	return ret;
>  }

Please find a way to test all this nicely when there are signals pending?
  
>  /**
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
