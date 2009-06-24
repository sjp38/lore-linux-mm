Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E16716B0055
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 18:26:52 -0400 (EDT)
Date: Wed, 24 Jun 2009 15:27:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
Message-Id: <20090624152732.d6352f4f.akpm@linux-foundation.org>
In-Reply-To: <1245839904.3210.85.camel@localhost.localdomain>
References: <1245839904.3210.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009 11:38:24 +0100
Richard Kennedy <richard@rsk.demon.co.uk> wrote:

> When writing to 2 (or more) devices at the same time, stop
> balance_dirty_pages moving dirty pages to writeback when it has reached
> the bdi threshold. This prevents balance_dirty_pages overshooting its
> limits and moving all dirty pages to writeback.     
> 
>     
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> ---
> balance_dirty_pages can overreact and move all of the dirty pages to
> writeback unnecessarily.
> 
> balance_dirty_pages makes its decision to throttle based on the number
> of dirty plus writeback pages that are over the calculated limit,so it
> will continue to move pages even when there are plenty of pages in
> writeback and less than the threshold still dirty.
> 
> This allows it to overshoot its limits and move all the dirty pages to
> writeback while waiting for the drives to catch up and empty the
> writeback list. 
> 
> A simple fio test easily demonstrates this problem.  
> 
> fio --name=f1 --directory=/disk1 --size=2G -rw=write
> 	--name=f2 --directory=/disk2 --size=1G --rw=write 		--startdelay=10
> 
> The attached graph before.png shows how all pages are moved to writeback
> as the second write starts and the throttling kicks in.
> 
> after.png is the same test with the patch applied, which clearly shows
> that it keeps dirty_background_ratio dirty pages in the buffer.
> The values and timings of the graphs are only approximate but are good
> enough to show the behaviour.  
> 
> This is the simplest fix I could find, but I'm not entirely sure that it
> alone will be enough for all cases. But it certainly is an improvement
> on my desktop machine writing to 2 disks.
> 
> Do we need something more for machines with large arrays where
> bdi_threshold * number_of_drives is greater than the dirty_ratio ?
> 

um.  Interesting find.  Jens, was any of your performance testing using
multiple devices?  If so, it looks like the results just got invalidated :)

> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 7b0dcea..7687879 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -541,8 +541,11 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		 * filesystems (i.e. NFS) in which data may have been
>  		 * written to the server's write cache, but has not yet
>  		 * been flushed to permanent storage.
> +		 * Only move pages to writeback if this bdi is over its
> +		 * threshold otherwise wait until the disk writes catch
> +		 * up.
>  		 */
> -		if (bdi_nr_reclaimable) {
> +		if (bdi_nr_reclaimable > bdi_thresh) {
>  			writeback_inodes(&wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			get_dirty_limits(&background_thresh, &dirty_thresh,

yup, we need to think about the effect with zillions of disks.  Peter,
could you please take a look?

Also...  get_dirty_limits() is rather hard to grok.  The callers of
get_dirty_limits() treat its three return values as "thresholds", but
they're not named as thresholds within get_dirty_limits() itself, which
is a bit confusing.  And the meaning of each of those return values is
pretty obscure from the code - could we document them please?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
