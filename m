Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7878A6B0138
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 04:34:47 -0400 (EDT)
Date: Thu, 13 Sep 2012 09:34:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: steering allocations to particular parts of memory
Message-ID: <20120913083443.GS11266@suse.de>
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
 <20120911093407.GH11266@suse.de>
 <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 02:28:29PM -0700, Larry Bassel wrote:
> On 11 Sep 12 10:34, Mel Gorman wrote:
> > On Fri, Sep 07, 2012 at 11:27:15AM -0700, Larry Bassel wrote:
> > > I am looking for a way to steer allocations (these may be
> > > by either userspace or the kernel) to or away from particular
> > > ranges of memory. The reason for this is that some parts of
> > > memory are different from others (i.e. some memory may be
> > > faster/slower). For instance there may be 500M of "fast"
> > > memory and 1500M of "slower" memory on a 2G platform.
> > > 
> > 
> > Hi Larry,
> > 
> > > At the memory mini-summit last week, it was mentioned
> > > that the Super-H architecture was using NUMA for this
> > > purpose, which was considered to be an very bad thing
> > > to do -- we have ported NUMA to ARM here (as an experiment)
> > > and agree that NUMA doesn't work well for solving this problem.
> > > 
> > 
> > Yes, I remember the discussion and regret it had to be cut short.
> > 
> > NUMA is almost always considered to be the first solution to this type
> > of problem but as you say it's considered to be a "very bad thing to do".
> > It's convenient in one sense because you get data structures that track all
> > the pages for you and create the management structures. It's bad because
> > page allocation uses these slow nodes when the fast nodes are full which
> > is a very poor placement policy. Similarly pages from the slow node are
> > reclaimed based on memory pressure. It comes down to luck whether the
> > optimal pages are in the slow node or not. You can try wedging your own
> > placement policy on the side but it won't be pretty.
> 
> It appears that I was too vague about this. Both userspace and
> kernel (drivers mostly) need to be able to specify either explicitly
> or implicitly (using defaults if no explicit memory type is mentioned)

This pushes responsibility for placement policy out to the edge. While it
will work to some extent, it'll depend heavily on the applications getting
the placement policy right right. If a mistake is made then potentially
every one of these applications and drivers will need to be fixed although
I would expect that you'd create a new allocator API and hopefully only
have to fix it there if the policies were suitably fine-grained. To me
this type of solution is less than ideal as the drivers and applications
may not really know if the memory is "hot" or not.

> what sort of memory is desired and what to do if this type is not
> available (either due to actual lack of such memory or because
> a low watermark would be violated, etc.) such as fall back to
> another type of memory or get an out-of-memory error
> (More sophisticated alternatives would be to trigger
> some sort of migration or even eviction in these cases).
> This seems similar to a simplified version of memory policies,
> unless I'm missing something.
> 

I do not think it's a simplified version of memory policies but it is
certainly similar to memory policies.

> Admittedly, most drivers and user processes will not explicitly ask
> for a certain type of memory.
> 

This is what I expect. It means that your solution might work for Super-H
but it will not work for any of the other use cases where applications
will be expected to work without modification. I guess it would be fine
if one was building an applicance where they knew exactly what was going
to be running and how it behaved but it's not exactly a general solution.

> We also would like to be able to create lowmem or highmem
> from any type of memory.
> 

You may be able to hack something into the architecture layer that abuses
the memory model and remaps some pages into lowmem.

> The above makes me wonder if something that keeps nodes and zones
> and some sort of simple memory policy and throws out the rest of NUMA such
> as bindings of memory to CPUs, cpusets, etc. might be useful
> (though after the memory mini-summit I have doubts about this as well)
> as node-aware allocators already exist.
> 

You can just ignore the cpuset, CPU bindings and all the rest of it
already. It is already possible to use memory policies to only allocate
from a specific node (although it is not currently possible to restrict
allocations to a zone from user space at least).

I just fear that solutions that push responsibility out to drivers and
applications will end up being very hacky, rarely used, and be unsuitable
for the other use cases where application modification is not an option.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
