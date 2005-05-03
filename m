Date: Tue, 3 May 2005 09:21:02 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-ID: <20050503132102.GS19244@localhost>
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org> <4277259C.6000207@engr.sgi.com> <20050503010846.508bbe62.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050503010846.508bbe62.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>, mort@sgi.com, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, May 03, 2005 at 01:08:46AM -0700, Andrew Morton wrote:
> Ray Bryant <raybry@engr.sgi.com> wrote:
> >
> > ...
> > One of the common responses to changes in the VM system for optimizations
> > of this type is that we instead should devote our efforts to improving
> > the VM system algorithms and that we are taking an "easy way out" by
> > putting a hack into the VM system.
> 
> There's that plus the question which forever lurks around funky SGI patches:
> 
> 	How many machines in the world want this feature?
> 
> Because if the answer is "twelve" then gee it becomes hard to justify
> merging things into the mainline kernel.  Particularly when they add
> complexity to page reclaim.

And vendors seem hesitant because it isn't upstream.... chicken?  egg?

> 
> >  Fundamentally, the VM system cannot
> > predict the future behavior of the application in order to correctly
> > make this tradeoff.
> 
> Yup.  But we could add a knob to each zone which says, during page
> allocation "be more reluctant to advance onto the next node - do some
> direct reclaim instead"
> 
> And the good thing about that is that it is an easier merge because it's a
> simpler patch and because it's useful to more machines.  People can tune it
> and get better (or worse) performance from existing apps on NUMA.

The problem is that it really can't be a machine-wide policy.  This is
something that, at the very least, has to be limited to a cpuset.  I
chose to use the mempolicy infrastructure because this seemed like the
best method for sending hints to the allocator, based on the first discussion.

> Yes, if it's a "simple" patch then it _might_ do a bit of swapout or
> something.  But the VM does prefer to reclaim clean pagecache first (as
> well as slab, which is a bonus for this approach).
> 
> Worth trying, at least?

Well, another limitation of this is that we then only get inactive pages
reclaimed.  When the reclaim policy is in place the allocator is going
to ignore LRU and try really hard to get local memory.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
