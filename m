Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5DB6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 07:54:09 -0400 (EDT)
Date: Thu, 19 Aug 2010 13:51:06 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100819115106.GG1779@cmpxchg.org>
References: <20100809133000.GB6981@wil.cx> <20100817195001.GA18817@linux.intel.com> <20100818141308.GD1779@cmpxchg.org> <20100818160613.GE9431@localhost> <20100818160731.GA15002@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818160731.GA15002@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 12:07:31AM +0800, Wu Fengguang wrote:
> On Thu, Aug 19, 2010 at 12:06:13AM +0800, Wu Fengguang wrote:
> > On Wed, Aug 18, 2010 at 04:13:08PM +0200, Johannes Weiner wrote:
> > > Hi Matthew,
> > > 
> > > On Tue, Aug 17, 2010 at 03:50:01PM -0400, Matthew Wilcox wrote:
> > > > 
> > > > No comment on this?  Was it just that I posted it during the VM summit?
> > > 
> > > I have not forgotten about it.  I just have a hard time reproducing
> > > those extreme stalls you observed.
> > > 
> > > Running that test on a 2.5GHz machine with 2G of memory gives me
> > > stalls of up to half a second.  The patchset I am experimenting with
> > > gets me down to peaks of 70ms, but it needs further work.
> > > 
> > > Mapped file pages get two rounds on the LRU list, so once the VM
> > > starts scanning, it has to go through all of them twice and can only
> > > reclaim them on the second encounter.
> > > 
> > > At that point, since we scan without making progress, we start waiting
> > > for IO, which is not happening in this case, so we sit there until a
> > > timeout expires.
> > 
> > Right, this could lead to some 1s stall. Shaohua and me also noticed
> > this when investigating the responsiveness issues. And we are wondering
> > if it makes sense to do congestion_wait() only when the bdi is really
> > congested? There are no IO underway anyway in this case.

I am currently trying to get rid of all the congestion_wait() in the VM.
They are used for different purposes, so they need different replacement
mechanisms.

I saw Shaohua's patch to make congestion_wait() cleverer.  But I really
think that congestion is not a good predicate in the first place.  Why
would the VM care about IO _congestion_?  It needs a bunch of pages to
complete IO, whether the writing device is congested is not really
useful information at this point, I think.

> > > since I can not reproduce your observations, I don't know if this is
> > > the (sole) source of the problem.  Can I send you patches?
> > 
> > Sure.

Cool!

> > > > On Mon, Aug 09, 2010 at 09:30:00AM -0400, Matthew Wilcox wrote:
> > > > > 
> > > > > This testcase shows some odd behaviour from the Linux VM.
> > > > > 
> > > > > It creates a 1TB sparse file, mmaps it, and randomly reads locations 
> > > > > in it.  Due to the file being entirely sparse, the VM allocates new pages
> > > > > and zeroes them.  Initially, it runs very fast, taking on the order of
> > > > > 2.7 to 4us per page fault.  Eventually, the VM runs out of free pages,
> > > > > and starts doing huge amounts of work trying to figure out which of
> > > > > these clean pages to throw away.
> > > 
> > > This is similar to one of my test cases for:
> > > 
> > > 	6457474 vmscan: detect mapped file pages used only once
> > > 	31c0569 vmscan: drop page_mapping_inuse()
> > > 	dfc8d63 vmscan: factor out page reference checks
> > > 
> > > because the situation was even worse before (see the series
> > > description in dfc8d63).  Maybe asking the obvious, but the kernel you
> > > tested on did include those commits, right?
> > > 
> > > And just to be sure, I sent you a test-patch to disable the used-once
> > > detection on IRC the other day.  Did you have time to run it yet?
> > > Here it is again:
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 9c7e57c..c757bba 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -584,6 +584,7 @@ static enum page_references page_check_references(struct page *page,
> > >  		return PAGEREF_RECLAIM;
> > >  
> > >  	if (referenced_ptes) {
> > > +		return PAGEREF_ACTIVATE;
> > 
> > How come page activation helps?

This is effectively disabling used-once detection and going back to the old
VM behaviour.  I don't think it helps, but this code is recent and directly
related to the test-case.  Maybe I/we missed something, it can't hurt to
make sure, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
