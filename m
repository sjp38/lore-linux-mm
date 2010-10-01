Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 507C76B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 12:44:03 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91GaEFT022391
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 10:36:14 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o91Gi0Y6249542
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 10:44:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91Gi055010205
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 10:44:00 -0600
Subject: Re: Linux swapping with MySQL/InnoDB due to NUMA architecture
 imbalanced allocations?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AANLkTikqXGvJUX1kR0XY-ug1m4O9KTS+E6Qv1Birt3mT@mail.gmail.com>
References: <AANLkTim1R7-FVwofw-otpGCcHqQHLDwaTYYWFS1ZhSoW@mail.gmail.com>
	 <1285353469.3292.14042.camel@nimitz>
	 <AANLkTikqXGvJUX1kR0XY-ug1m4O9KTS+E6Qv1Birt3mT@mail.gmail.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 01 Oct 2010 09:43:58 -0700
Message-ID: <1285951438.16716.2586.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Cole <jeremy@jcole.us>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-09-27 at 18:58 -0700, Jeremy Cole wrote:
> > As far as the decisions about running reclaim or swapping versus going
> > to another node for an allocation, take a look at the
> > "zone_reclaim_mode" bits in Documentation/sysctl/vm.txt .  It does a
> > decent job of explaining what we do.
> 
> I had read about zone_reclaim_mode, and I've also been testing
> different settings for it, but I don't think it actually completely
> solves the situation here.  It seems to be primarily concerned with
> allocations that *could* happen anywhere, whereas I think what we're
> often seeing is that memory for whatever reason (which is not
> completely obvious to me) *must* be allocated on Node X, but Node X
> has no free memory and no caches to free.

All allocations have a list of zones from which the allocation can be
satisfied.  With many nodes, some may be closer than others, so
allocations _prefer_ to be on close (rather than distant) nodes.
zone_reclaim_mode basically speaks to how hard we try to work before we
give up and move down this priority list.

> Nonetheless, I have to admit that I don't completely understand the
> documentation for zone_reclaim_mode in its current form.  Perhaps you
> could answer a few questions?  I feel that the documentation could be
> updated with some important answers, which are missing now:
> 
> 1. What "zone reclaim" actually means.  My understanding is that "zone
> reclaim" is the practice of freeing memory on a specific node where
> memory was preferentially requested (due to NUMA memory allocation
> policy, by default "local") in favor of satisfying the allocation
> using free memory from wherever it is currently available.

Reclaim is what happens when you ask for memory and we don't have any.
Zone reclaim is the process that we follow to get memory inside a
particular area.

> 2. It isn't terribly clear what the default (0) policy is, and it
> could use an explanation.  Here's my take on it:
> 
> When zone_reclaim_mode = 0, programs requesting memory to be allocated
> on a particular node will only receive memory on the requested node if
> free memory is available.If no free memory is available on the
> requested node, but free memory is available on a different node, the
> allocation will be made there unless policy forbids it.  If no free
> memory is available on any node, then the normal cache freeing and
> paging out policies will apply to make free memory available on any
> node to satisfy the allocation. [Is there any preference for which
> node caches are freed from in this case?]

I think it's simpler than that.  When it's 0, we don't try to reclaim
memory until the whole system is full.  Basically, memory allocation
acts like it would on a system which isn't NUMA.

> Is this correct?
> 
> 3. I found that the list of possible values' descriptions are a bit
> too terse to be usable by me.  Here are some efforts to refine the
> definitions:
> 
>   a. "1 = Zone reclaim on" -- This means that cache pages will be
> freed to make free memory to satisfy the request only if they are not
> dirty.

It also means that we'll try and drop some slab caches.  I think you can
more generally:  This will try to reclaim memory in ways that won't
cause extra writes to disk.  But, it might cause extra reads at some
point in the future.  

>   b. "2 = Zone reclaim writes dirty pages out" -- This means that
> dirty cache pages will be written out and then freed if no clean pages
> are available to be freed.  This incurs additional cost due to disk
> I/O.

It can also cause processes doing writes to stall sooner than they might
have otherwise.  That's kinda covered in the current documentation.

>   c. "4 = Zone reclaim swaps pages" -- This means that anonymous pages
> may be swapped out to disk and then freed if no clean pages are
> available to be freed and (if bit 2 is set) no dirty cache pages are
> available to be written out and freed.  This incurs additional cost
> due to swap I/O.

I wouldn't mention the other modes.  

I'd encourage you to try and put together a patch for the documentation.
I can't tell you how many times I've scratched my head looking at that
particular entry.  

> Do those refinements make sense and are they correct?
> 
> 4. How is it determined that "pages from remote zones will cause a
> measurable performance reduction"?  My understanding is that this is
> based on whether the node distance, as reported by "numactl
> --hardware" is > RECLAIM_DISTANCE (by default defined as 20).

Exactly.  We take the BIOS tables (or whatever they're called on
non-x86) and translate them into a reclaim distance.  If it's >20, then
we say "pages from remote zones will cause a measurable performance
reduction".  

> 5. I cannot parse/understand this statement at all: "Allowing regular
> swap effectively restricts allocations to the local node unless
> explicitly overridden by memory policies or cpuset configurations." --
> Could this be rephrased and/or explained?

Yeah, that's pretty obtuse. :)

If you ask for memory from one zone, you'll get it from that zone.  The
kernel will do everything it can to give you memory from that zone,
including swapping pages out.  You implicitly ask for memory from the
current node for every allocation, so this will effectively restrict
your memory use to the local node, unless you override it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
