Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C83906B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:19:36 -0500 (EST)
Date: Thu, 15 Jan 2009 07:19:31 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090115061931.GC17810@wotan.suse.de>
References: <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com> <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com> <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <20090114152207.GD25401@wotan.suse.de> <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com> <20090114155923.GC1616@wotan.suse.de> <Pine.LNX.4.64.0901141219140.26507@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901141219140.26507@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 12:40:12PM -0600, Christoph Lameter wrote:
> On Wed, 14 Jan 2009, Nick Piggin wrote:
> 
> > Well if you would like to consider SLQB as a fix for SLUB, that's
> > fine by me ;) Actually I guess it is a valid way to look at the problem:
> > SLQB solves the OLTP regression, so the only question is "what is the
> > downside of it?".
> 
> The downside is that it brings the SLAB stuff back that SLUB was
> designed to avoid. Queue expiration.

What's this mean? Something distinct from periodic timer?

> The use of timers to expire at
> uncontrollable intervals for user space.

I am not convinced this is a problem. I would like to see evidence
that it is a problem, but I have only seen assertions.

Definitely it is not uncontrollable. And not unchangeable. It is
about the least sensitive part of the allocator because in a serious
workload, the queues will continually be bounded by watermarks rather
than timer reaping.


> Object dispersal
> in the kernel address space.

You mean due to lower order allocations?
1. I have not seen any results showing this gives a practical performance
   increase, let alone one that offsets the downsides of using higher
   order allocations.
2. Increased internal fragmentation may also have the opposite effect and
   result in worse packing.
3. There is no reason why SLQB can't use higher order allocations if this
   is a significant win.


> Memory policy handling in the slab
> allocator.

I see no reason why this should be a problem. The SLUB merge just asserted
it would be a problem. But actually SLAB seems to handle it just fine, and
SLUB also doesn't always obey memory policies, so I consider that to be a
worse problem, at least until it is justified by performance numbers that
show otherwise.


> Even seems to include periodic moving of objects between
> queues.

The queues expire slowly. Same as SLAB's arrays. You are describing the
implementation, and not the problems it has.


> The NUMA stuff is still a bit foggy to me since it seems to assume
> a mapping between cpus and nodes. There are cpuless nodes as well as
> memoryless cpus.

That needs a little bit of work, but my primary focus is to come up
with a design that has competitive performance in the most important
cases.

There needs to be some fallback cases added to slowpaths to handle
these things, but I don't see why it would take much work.

 
> SLQB maybe a good cleanup for SLAB. Its good that it is based on the
> cleaned up code in SLUB but the fundamental design is SLAB (or rather the
> Solaris allocator from which we got the design for all the queuing stuff
> in the first place). It preserves many of the drawbacks of that code.

It is _like_ slab. It avoids the major drawbacks of large footprint of
array caches, and O(N^2) memory consumption behaviour, and corner cases
where scalability is poor. The queueing behaviour of SLAB IMO is not
a drawback and it is a big reaon why SLAB is so good.

 
> If SLQB would replace SLAB then there would be a lot of shared code
> (debugging for example). Having a generic slab allocator framework may
> then be possible within which a variety of algorithms may be implemented.

The goal is to replace SLAB and SLUB. Anything less would be a failure
on behalf of SLQB. Shared code is not a bad thing, but the major problem
is the actual core behaviour of the allocator because it affects almost
everywhere in the kernel and splitting userbase is not a good thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
