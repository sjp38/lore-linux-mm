Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0C2F6B005A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 03:58:36 -0400 (EDT)
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20090624152732.d6352f4f.akpm@linux-foundation.org>
References: <1245839904.3210.85.camel@localhost.localdomain>
	 <20090624152732.d6352f4f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 25 Jun 2009 10:00:33 +0200
Message-Id: <1245916833.31755.78.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-24 at 15:27 -0700, Andrew Morton wrote:
> On Wed, 24 Jun 2009 11:38:24 +0100
> Richard Kennedy <richard@rsk.demon.co.uk> wrote:
> 
> > When writing to 2 (or more) devices at the same time, stop
> > balance_dirty_pages moving dirty pages to writeback when it has reached
> > the bdi threshold. This prevents balance_dirty_pages overshooting its
> > limits and moving all dirty pages to writeback.     
> > 
> >     
> > Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> > ---

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


[ moved explanation below ]

> > 
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 7b0dcea..7687879 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -541,8 +541,11 @@ static void balance_dirty_pages(struct address_space *mapping)
> >  		 * filesystems (i.e. NFS) in which data may have been
> >  		 * written to the server's write cache, but has not yet
> >  		 * been flushed to permanent storage.
> > +		 * Only move pages to writeback if this bdi is over its
> > +		 * threshold otherwise wait until the disk writes catch
> > +		 * up.
> >  		 */
> > -		if (bdi_nr_reclaimable) {
> > +		if (bdi_nr_reclaimable > bdi_thresh) {
> >  			writeback_inodes(&wbc);
> >  			pages_written += write_chunk - wbc.nr_to_write;
> >  			get_dirty_limits(&background_thresh, &dirty_thresh,
> 
> yup, we need to think about the effect with zillions of disks.  Peter,
> could you please take a look?

Looks to have been in that form forever (immediate git history).

When reading the code I read it like:

		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
			break;

		if (nr_reclaimable + nr_writeback <
				(background_thresh + dirty_thresh) / 2)
			break;

		if (bdi_nr_reclaimable) {
			writeback_inodes(&wbc);

Which to me reads:

  - if there's not enough to do, drop out
  - see if background write-out can catch up, drop out
  - is there anything to do, yay! work.

/me goes read the changelog, maybe there's a clue in there :-)

> > balance_dirty_pages can overreact and move all of the dirty pages to
> > writeback unnecessarily.
> > 
> > balance_dirty_pages makes its decision to throttle based on the number
> > of dirty plus writeback pages that are over the calculated limit,so it
> > will continue to move pages even when there are plenty of pages in
> > writeback and less than the threshold still dirty.
> > 
> > This allows it to overshoot its limits and move all the dirty pages to
> > writeback while waiting for the drives to catch up and empty the
> > writeback list. 

Ahhh, indeed, how silly of me not to notice that before!
 
> > This is the simplest fix I could find, but I'm not entirely sure that it
> > alone will be enough for all cases. But it certainly is an improvement
> > on my desktop machine writing to 2 disks.

Seems good to me.

> > Do we need something more for machines with large arrays where
> > bdi_threshold * number_of_drives is greater than the dirty_ratio ?

[ I assumed s/dirty_ratio/dirty_thresh/, since dirty_ratio is a ratio
  and bdi_threshold is an actual value, therefore the inequality above
  doesn't make sense ]

That cannot actually happen (aside from small numerical glitches).

bdi_threshold = P_i * dirty_thresh, where \Sum P_i = 1

The proportion is relative to the recent writeout speed of the device.


On Wed, 2009-06-24 at 15:27 -0700, Andrew Morton wrote:
> Also...  get_dirty_limits() is rather hard to grok.  The callers of
> get_dirty_limits() treat its three return values as "thresholds", but
> they're not named as thresholds within get_dirty_limits() itself, which
> is a bit confusing.  And the meaning of each of those return values is
> pretty obscure from the code - could we document them please?

Does something like this help?

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7b0dcea..dc2cee1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -426,6 +426,13 @@ unsigned long determine_dirtyable_memory(void)
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+/*
+ * get_dirty_limits() - compute the various dirty limits
+ *
+ * @pbackground - dirty limit at which we want to start background write-out
+ * @pdirty	- total dirty limit, we should not have more dirty than this
+ * @pdbi_dirty	- the share of @pdirty available to @bdi
+ */
 void
 get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
 		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
