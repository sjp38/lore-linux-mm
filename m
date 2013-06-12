Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1B37A6B0037
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 18:22:20 -0400 (EDT)
Date: Wed, 12 Jun 2013 15:22:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4 v4]swap: make swap discard async
Message-Id: <20130612152218.a7a8d7900e7d66978883e772@linux-foundation.org>
In-Reply-To: <20130326053730.GB19646@kernel.org>
References: <20130326053730.GB19646@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 26 Mar 2013 13:37:30 +0800 Shaohua Li <shli@kernel.org> wrote:

> swap can do cluster discard for SSD, which is good, but there are some problems
> here:
> 1. swap do the discard just before page reclaim gets a swap entry and writes
> the disk sectors. This is useless for high end SSD, because an overwrite to a
> sector implies a discard to original nand flash too. A discard + overwrite ==
> overwrite.
> 2. the purpose of doing discard is to improve SSD firmware garbage collection.
> Doing discard just before write doesn't help, because the interval between
> discard and write is too short. Doing discard async and just after a swap entry
> is freed can make the interval longer, so SSD firmware has more time to do gc.
> 3. block discard is a sync API, which will delay scan_swap_map() significantly.
> 4. Write and discard command can be executed parallel in PCIe SSD. Making
> swap discard async can make execution more efficiently.
> 
> This patch makes swap discard async, and move discard to where swap entry is
> freed. Idealy we should do discard for any freed sectors, but some SSD discard
> is very slow. This patch still does discard for a whole cluster. 

This is rather unclear.  I see two reasons for async discard:

a) To avoid blocking userspace while the discard is in progress.

   Well OK, but it is important that measurements be provided so we
   can evaluate the usefulness of the change.

b) To give the SSD firmware time to perform GC.

   If so, this is a very poor implementation.  There is no control
   here over the duration of that delay and schedule_work() might cause
   the work to occur very very soon after schedule_work() is called.

   Relying upon the vagaries of scheduler implementation, hardware
   speed, system load etc to provide a suitable delay sounds unreliable
   and sloppy.

   If we want to put a delay in there then I do think that some
   explicit, controlled and perhaps tunable interval should be used.

> My test does a several round of 'mmap, write, unmap', which will trigger a lot
> of swap discard. In a fusionio card, with this patch, the test runtime is
> reduced to 18% of the time without it, so around 5.5x faster.
>
> ...
>
> --- linux.orig/include/linux/swap.h	2013-03-22 17:21:45.590763696 +0800
> +++ linux/include/linux/swap.h	2013-03-22 17:23:56.069125823 +0800
> @@ -194,8 +194,6 @@ struct swap_info_struct {
>  	unsigned int inuse_pages;	/* number of those currently in use */
>  	unsigned int cluster_next;	/* likely index for next allocation */
>  	unsigned int cluster_nr;	/* countdown to next cluster search */
> -	unsigned int lowest_alloc;	/* while preparing discard cluster */
> -	unsigned int highest_alloc;	/* while preparing discard cluster */
>  	struct swap_extent *curr_swap_extent;
>  	struct swap_extent first_swap_extent;
>  	struct block_device *bdev;	/* swap device or bdev of swap file */
> @@ -217,6 +215,9 @@ struct swap_info_struct {
>  					 * swap_lock. If both locks need hold,
>  					 * hold swap_lock first.
>  					 */
> +	struct work_struct discard_work;
> +	unsigned int discard_cluster_head;
> +	unsigned int discard_cluster_tail;

Please document the fields carefully.  Documentation of data structures
often turns out to be the most valuable of all.

>  };
>  
>  struct swap_list_t {
>
> ...
>
> +static void swap_discard_work(struct work_struct *work)
> +{
> +	struct swap_info_struct *si;
> +
> +	si = container_of(work, struct swap_info_struct, discard_work);
> +
> +	spin_lock(&si->lock);
> +	swap_do_scheduled_discard(si);
> +	spin_unlock(&si->lock);
> +}

What guarantees that *si still exists?  If this work was delayed 200
milliseconds and there was an intervening swapoff, what happens?

We should be careful to not overload keventd.  What is the upper bound
on the duration of this function?

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
