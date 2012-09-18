Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5F70B6B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 04:32:57 -0400 (EDT)
Date: Tue, 18 Sep 2012 09:32:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: steering allocations to particular parts of memory
Message-ID: <20120918083252.GI11266@suse.de>
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
 <20120911093407.GH11266@suse.de>
 <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
 <20120913083443.GS11266@suse.de>
 <9e3b0e01-836d-49d3-8aed-9ed9df6c1cfa@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9e3b0e01-836d-49d3-8aed-9ed9df6c1cfa@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>

On Mon, Sep 17, 2012 at 12:40:58PM -0700, Dan Magenheimer wrote:
> Hi Larry --
> 
> Sorry I missed seeing you and missed this discussion at Linuxcon!
> 
> > <SNIP>
> > At the memory mini-summit last week, it was mentioned
> > that the Super-H architecture was using NUMA for this
> > purpose, which was considered to be an very bad thing
> > to do -- we have ported NUMA to ARM here (as an experiment)
> > and agree that NUMA doesn't work well for solving this problem.
> 
> If there are any notes/slides/threads with more detail
> on this discussion (why NUMA doesn't work well), I'd be
> interested in a pointer...
> 

It was a tangent to an unrelated discussion so there were no slides.
LWN.net has an excellent summary of what happened at the meeting in general
but this particular topic was not discussed in detail. The short summary
of why NUMA was bad was in my mail when I said this "It's bad because
page allocation uses these slow nodes when the fast nodes are full which
is a very poor placement policy. Similarly pages from the slow node are
reclaimed based on memory pressure. It comes down to luck whether the
optimal pages are in the slow node or not."

> > I am looking for a way to steer allocations (these may be
> > by either userspace or the kernel) to or away from particular
> > ranges of memory. The reason for this is that some parts of
> > memory are different from others (i.e. some memory may be
> > faster/slower). For instance there may be 500M of "fast"
> > memory and 1500M of "slower" memory on a 2G platform.
> 
> In the kernel's current uses of tmem (frontswap and cleancache),
> there's no way to proactively steer the allocation.  The
> kernel effectively subdivides pages into two priority
> classes and lower priority pages end up in cleancache
> rather than being reclaimed, and frontswap rather than
> on a swap disk.
> 

In the case of frontswap, a reclaim-driven placement policy makes a lot of
sense. To some extent, it does for cleancache as well. It is not necessarily
the best placement policy for slowmem if the data being placed in there
simply had slow access requirements but was otherwise quite large. I'm
not exactly sure but I expect the policy has worse control over when a
page exits the cache either to main memory or to get discarded.

Still, it's a far better policy than plain NUMA placement and would be a
sensible starting point. If an alternative placement policy was proposed
the changelog should include why a reclaim-driven policy was not
preferred.

> A brand new in-kernel interface to tmem code to explicitly
> allocate "slow memory" is certainly possible, though I
> haven't given it much thought.   Depending on how "slow"
> is slow, it may make sense for the memory to only be used
> for tmem pages rather than for user/kernel-directly-accessible
> RAM.
> 

There is a risk as well that each new placement policy would need a
different API so tmem is not necessarily the best interface. This is why
I tried to describe a different layering. Of course, I don't have any
code or a proper design.

> > This pushes responsibility for placement policy out to the edge. While it
> > will work to some extent, it'll depend heavily on the applications getting
> > the placement policy right right. If a mistake is made then potentially
> > every one of these applications and drivers will need to be fixed although
> > I would expect that you'd create a new allocator API and hopefully only
> > have to fix it there if the policies were suitably fine-grained. To me
> > this type of solution is less than ideal as the drivers and applications
> > may not really know if the memory is "hot" or not.
> 
> I'd have to agree with Mel on this.  There are certainly a number
> of enterprise apps that subvert kernel policies and entirely
> manage their own memory. 

Indeed. In the diagram I posted there was a part that created an "Interface
to make it look like RAM". An enterprise app might decide to just expose
that to the application as a character device and mmap it.

> I'm not sure there would be much value
> to kernel participation (or using tmem) if this is what you ultimately
> need to do.
> 

Which might indicate that tmem is not the interface they are looking
for. However, if someone was to implement a general solution I expect
they would borrow heavily from tmem and at the very least, tmem should
be able to reuse any core code.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
