Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA13977
	for <linux-mm@kvack.org>; Mon, 23 Dec 2002 15:54:26 -0800 (PST)
Message-ID: <3E07A231.5E4B3015@digeo.com>
Date: Mon, 23 Dec 2002 15:54:25 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shared pagetable benchmarking
References: <3E037690.45419D64@digeo.com> <45600000.1040660127@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> --On Friday, December 20, 2002 11:59:12 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> 
> > So changing userspace to place its writeable memory on a new 4M boundary
> > would be a big win?
> >
> > It's years since I played with elf, but I think this is feasible.  Change
> > the linker and just wait for it to propagate.
> 
> Actually it'd require changes to both the linker and the kernel memory
> range allocator.  Right now ld.so maps all memory needed for an entire
> shared library, then uses mprotect and MAP_FIXED to modify parts of it to
> be writable (or at least that's what I see using strace).  If it was done
> using separate mmap calls we could redirect the writable regions to be in a
> different pmd.

Yup.

Over the weekend I got all this going.  With binutils patches from HJ,
a kernel patch from Bill and tons of rebuilding things I had everything
in /proc/pid/maps on a separate 4M segment.

I also fixed run-child-first-on-fork.

Summary:

		2.4.20		2.5-shpte	2.5-shpte+weekend_hacks

aim9 fork_test	1950		1300		1700
aim9 exec_test	700		545		572
patch-scripts	16.5		19.5		18.5


The fork test isn't very interesting.  When you toss in an exec(),
the benefits are small.


It appears that Linus's only interest in shared pagetables is that
it could reclaim the fork/exec overhead which the reverse mapping
introduced.  As far as I can tell he is not concerned about space
consumption issues.

And if that is the selection criterion, I do not believe that these
speedups are sufficient to warrant a merge.

> >> Let's also not lose sight of what I consider the primary goal of shared
> >> page tables, which is to greatly reduce the page table memory overhead of
> >> massively shared large regions.
> >
> > Well yes.  But this is optimising the (extremely) uncommon case while
> > penalising the (very) common one.
> 
> I guess I don't see wasting extra pte pages on duplicated mappings of
> shared memory as extremely uncommon.  Granted, it's not that significant
> for small applications, but it can make a machine unusable with some large
> applications.  I think being able to run applications that couldn't run
> before to be worth some consideration.
> 
> I also have a couple of ideas for ways to eliminate the penalty for small
> tasks.  Would you grant that it's a worthwhile effort if the penalty for
> small applications was zero?
> 

It's not my call, David.  I've been putting myself in the role of
helping to get the code working and tested, and providing Linus
with whatever info can help him make a decision.  I guess he works
by observing what people are talking about, asking about and hurting
over on the mailing lists.  As well as his own experience.  And the
issue of pagetable consumption just doesn't have any visibility.

I expect his position would be that it's a specialised, rare problem
and that the fix is more appropriate to a specialised vendor kernel.

I suggest that you discuss it with him.  If that ends up being thumbs-down
I can continue to maintain the patch across 2.6.x.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
