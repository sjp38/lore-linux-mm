Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBA36B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 17:02:59 -0400 (EDT)
Date: Fri, 7 Aug 2009 17:02:49 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
Message-ID: <20090807210249.GA3710@think>
References: <1245839904.3210.85.camel@localhost.localdomain>
 <1249647601.32113.700.camel@twins>
 <1249655761.2719.11.camel@localhost.localdomain>
 <20090807152210.GH17129@think>
 <1249661361.2719.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1249661361.2719.36.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 05:09:21PM +0100, Richard Kennedy wrote:
> On Fri, 2009-08-07 at 11:22 -0400, Chris Mason wrote:
> > On Fri, Aug 07, 2009 at 03:36:01PM +0100, Richard Kennedy wrote:
> > > On Fri, 2009-08-07 at 14:20 +0200, Peter Zijlstra wrote:
> > > > On Wed, 2009-06-24 at 11:38 +0100, Richard Kennedy wrote:
> > > ...
> > > > OK, so Chris ran into this bit yesterday, complaining that he'd only get
> > > > very few write requests and couldn't saturate his IO channel.
> > > > 
> > > > Now, since writing out everything once there's something to do sucks for
> > > > Richard, but only writing out stuff when we're over the limit sucks for
> > > > Chris (since we can only be over the limit a little), the best thing
> > > > would be to only write out when we're over the background limit. Since
> > > > that is the low watermark we use for throttling it makes sense that we
> > > > try to write out when above that.
> > > > 
> > > > However, since there's a lack of bdi_background_thresh, and I don't
> > > > think introducing one just for this is really justified. How about the
> > > > below?
> > > > 
> > > > Chris how did this work for you? Richard, does this make things suck for
> > > > you again?
> > > > 
> > > > ---
> > > >  mm/page-writeback.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > > index 81627eb..92f42d6 100644
> > > > --- a/mm/page-writeback.c
> > > > +++ b/mm/page-writeback.c
> > > > @@ -545,7 +545,7 @@ static void balance_dirty_pages(struct address_space *mapping)
> > > >  		 * threshold otherwise wait until the disk writes catch
> > > >  		 * up.
> > > >  		 */
> > > > -		if (bdi_nr_reclaimable > bdi_thresh) {
> > > > +		if (bdi_nr_reclaimable > bdi_thresh/2) {
> > 
> > My patch had two extra spaces ;)
> > 
> > > >  			writeback_inodes(&wbc);
> > > >  			pages_written += write_chunk - wbc.nr_to_write;
> > > >  			get_dirty_limits(&background_thresh, &dirty_thresh,
> > > > 
> > > > 
> > > I'll run some tests and let you know :)
> > > 
> > > But what if someone has changed the vm settings?
> > > Maybe something like 
> > > 	(bdi_thresh * dirty_background_ratio / dirty_ratio)
> > > might be better ?
> > > 
> > > Chris, what sort of workload are you having problems with?
> > 
> > So, buffered writeback in general has a bunch of interesting features
> > right now, and to be honest I'm having a hard time untangling all of it.
> > It doesn't help that each of our filesystems is reacting differently.
> > 
> > Btrfs and XFS both use helper threads to process IO completion.  This
> > means that we tend to collect more writeback pages than the other
> > filesystems do.
> > 
> > The end result of this is that O_DIRECT is dramatically faster than
> > buffered on every streaming write workload I've tried.  I'm still trying
> > to sort out exactly where buffered IO is going wrong.
> > 
> > -chris
> > 
> Yes, it's all pretty complex.
> With a large number of pages in writeback do you think that the total
> dirty pages goes over the threshold ?
> I do wonder how long we get stuck in congestion_wait, it may be
> interesting to see if reducing its timeout has any effect. 

I've done a few more tests here, and running with Peter's patch doesn't
really change the results for either XFS or Btrfs.  The real reason his
patch was helping me at first was because it was forcing the btrfs code
into writepages more often.

I also did a run with congestion_wait(1) instead of HZ/10, and it also
didn't make much difference at all.

The only way I've been able to get buffered writeback closer to to
O_DIRECT writeback is just by increasing the number of pages that get
written (wbc.nr_to_write).

On Btrfs I'm testing with a patch that extends nr_to_write to cover the
full extent if delalloc is done (up to a limit of 32MB), which is
another way of saying it is covering a larger range of pages the FS
knows to be contiguous on disk.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
