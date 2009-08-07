Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 533526B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 08:20:17 -0400 (EDT)
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1245839904.3210.85.camel@localhost.localdomain>
References: <1245839904.3210.85.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Aug 2009 14:20:01 +0200
Message-Id: <1249647601.32113.700.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-24 at 11:38 +0100, Richard Kennedy wrote:
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

OK, so Chris ran into this bit yesterday, complaining that he'd only get
very few write requests and couldn't saturate his IO channel.

Now, since writing out everything once there's something to do sucks for
Richard, but only writing out stuff when we're over the limit sucks for
Chris (since we can only be over the limit a little), the best thing
would be to only write out when we're over the background limit. Since
that is the low watermark we use for throttling it makes sense that we
try to write out when above that.

However, since there's a lack of bdi_background_thresh, and I don't
think introducing one just for this is really justified. How about the
below?

Chris how did this work for you? Richard, does this make things suck for
you again?

---
 mm/page-writeback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 81627eb..92f42d6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -545,7 +545,7 @@ static void balance_dirty_pages(struct address_space *mapping)
 		 * threshold otherwise wait until the disk writes catch
 		 * up.
 		 */
-		if (bdi_nr_reclaimable > bdi_thresh) {
+		if (bdi_nr_reclaimable > bdi_thresh/2) {
 			writeback_inodes(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
