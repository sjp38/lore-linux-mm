Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00C156B0085
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 12:25:44 -0500 (EST)
Date: Tue, 3 Mar 2009 17:25:36 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090303172535.GA16993@shareable.org>
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed> <20090301135057.GA26905@wotan.suse.de> <20090302081953.GK26138@disturbed> <20090302083718.GE1257@wotan.suse.de> <49ABFA9D.90801@hp.com> <20090303043338.GB3973@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303043338.GB3973@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: jim owens <jowens@hp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> > >You only ever need to reserve enough memory for a *single* page
> > >to be processed. In the worst case that there are multiple pages
> > >under writeout but can't allocate memory, only one will be allowed
> > >access to reserves and the others will block until it is finished
> > >and can unpin them all.
> > 
> > Sure, nobody will mind seeing lots of extra pinned memory ;)
> 
> 40 pages (160k) isn't a huge amount. You could always have a
> boot option to disable the memory reserve if it is a big
> deal.
>  
> > Don't forget to add the space for data transforms and raid
> > driver operations in the write stack, and whatever else we
> > may not have thought of.  With good engineering we can make
> 
> The block layer below the filesystem should be robust. Well
> actually the core block layer is (except maybe for the new
> bio integrity stuff that looks pretty nasty). Not sure about
> md/dm, but they really should be safe (they use mempools etc).

Are mempools fully safe, or just statistically safer?

> > it so "we can always make forward progress".  But it won't
> > matter because once a real user drives the system off this
> > cliff there is no difference between "hung" and "really slow
> > progress".  They are going to crash it and report a hang.
> 
> I don't think that is the case. These are situations that
> would be *really* rare and transient. It is not like thrashing
> in that your working set size exceeds physical RAM, but just
> a combination of conditions that causes an unusual spike in the
> required memory to clean some dirty pages (eg. Dave's example
> of several IOs requiring btree splits over several AGs). Could
> cause a resource deadlock.

Suppose the systems has two pages to be written.  The first must
_reserve_ 40 pages of scratch space just in case the operation will
need them.  If the second page write is initiated concurrently with
the first, the second must reserve another 40 pages concurrently.

If 10 page writes are concurrent, that's 400 pages of scratch space
needed in reserve...

Your idea that the system can serialises page writes to limit the
scratch used will limit this.  But how does it know when to serialise
page writes, if not by reserving 40 pages of memory per written page,
until it knows better?

In other words, do you need 40 pages of metadata space times the
number of concurrent page writes - until the write logic for each page
reaches the point of "unreserving" because they've worked out which
metadata they don't need to touch?

It sounds like a classic concurrency problem - how many things to
start in parallel, each having a large upper bound on the memory they
may need when they are started, even though the average is much lower.

A solution to that is each concurrent thing being able to reserve
memory "I may need X memory later" and block at reservation time, so
it doesn't have to block when it's later allocating and using memory.
Then to keep up global concurrency, each thing is able to unreserve
memory as it progresses.  Or reserve some more.  The point is
reservation can block, while later processing which may need the
memory doesn't block.

-- Jamie


> 
> 
> > >Well I'm not saying it is an immediate problem or it would be a
> > >good use of anybody's time to rush out and try to redesign their
> > >fs code to fix it ;) But at least for any new core/generic library
> > >functionality like fsblock, it would be silly not to close the hole
> > >there (not least because the problem is simpler here than in a
> > >complex fs).
> > 
> > Hey, I appreciate anything you do in VM to make the ugly
> > dance with filesystems (my area) a little less ugly.
> 
> Well thanks.
> 
> 
> > I'm sure you also appreciate that every time VM tries to
> > save 32 bytes, someone else tries to take 32 K-bytes.
> > As they say... memory is cheap :)
> 
> Well that's OK. If core vm/fs code saves a little bit of memory
> that enables something else like a filesystem to use it to cache
> a tiny bit more useful data, then I think it is a good result :)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
