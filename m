From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/7] Reduce GFP_ATOMIC allocation failures, candidate
	fix V3
Date: Fri, 13 Nov 2009 13:44:01 +0000
Message-ID: <20091113134401.GE29804__23282.8964050443$1258119861$gmane$org@csn.ul.ie>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie> <20091112202748.GC2811@think> <20091112220005.GD2811@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D68946B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 08:44:07 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20091112220005.GD2811@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>
List-Id: linux-mm.kvack.org

On Thu, Nov 12, 2009 at 05:00:05PM -0500, Chris Mason wrote:
> On Thu, Nov 12, 2009 at 03:27:48PM -0500, Chris Mason wrote:
> > On Thu, Nov 12, 2009 at 07:30:06PM +0000, Mel Gorman wrote:
> > > Sorry for the long delay in posting another version. Testing is extremely
> > > time-consuming and I wasn't getting to work on this as much as I'd have liked.
> > > 
> > > Changelog since V2
> > >   o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
> > >     testing, it made latencies even worse as kswapd slept more on high-order
> > >     congestion causing order-0 direct reclaims.
> > >   o Added changes to how congestion_wait() works
> > >   o Added a number of new patches altering the behaviour of reclaim
> > > 
> > > Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
> > > failures. A significant number of these have been high-order GFP_ATOMIC
> > > failures and while they are generally brushed away, there has been a large
> > > increase in them recently and there are a number of possible areas the
> > > problem could be in - core vm, page writeback and a specific driver. The
> > > bugs affected by this that I am aware of are;
> > 
> > Thanks for all the time you've spent on this one.  Let me start with
> > some more questions about the workload ;)
> > 
> > So the workload is gitk reading a git repo and a program reading data
> > over the network.  Which part of the workload writes to disk?
> 
> Sorry for the self reply, I started digging through your data (man,
> that's a lot of data ;). 

Yeah, sorry about that. Because I lacked a credible explanation as to
why waiting on sync really made such a difference, I had little choice
but to punt everything I had for people to dig through.

To be clear, I'm not actually running gitk. The fake-gitk is reading the
commits into memory and building a tree in a similar fashion to what gitk
does. I didn't want to use gitk itself because there wasn't a way of measuring
whether it was stalling or just other than looking at it and making a guess.

> I took another tour through dm-crypt and
> things make more sense now.
> 
> dm-crypt has two different single threaded workqueues for each dm-crypt
> device.  The first one is meant to deal with the actual encryption and
> decryption, and the second one is meant to do the IO.
> 
> So the path for a write looks something like this:
> 
> filesystem -> crypt thread -> encrypt the data -> io thread -> disk
> 
> And the path for read looks something like this:
> 
> filesystem -> io thread -> disk -> crypt thread -> decrypt data -> FS
> 
> One thread does encryption and one thread does IO, and these threads are
> shared for reads and writes.  The end result is that all of the sync
> reads get stuck behind any async write congestion and all of the async
> writes get stuck behind any sync read congestion.
> 
> It's almost like you need to check for both sync and async congestion
> before you have any hopes of a new IO making progress.
> 
> The confusing part is that dm hasn't gotten any worse in this regard
> since 2.6.30 but the workload here is generating more sync reads
> (hopefully from gitk and swapin) than async writes (from the low
> bandwidth rsync).  So in general if you were to change mm/*.c wait
> for sync congestion instead of async, things should appear better.
> 

Thanks very much for that explanation. It makes a lot of sense and
explains why waiting on sync-congestion made such a difference on the
test setup.

> The punch line is that the btrfs guy thinks we can solve all of this with
> just one more thread.  If we change dm-crypt to have a thread dedicated
> to sync IO and a thread dedicated to async IO the system should smooth
> out.
> 

I see you have posted another patch so I'll test that out first before
looking into that.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
