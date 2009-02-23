Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 479186B00BA
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 11:33:27 -0500 (EST)
Date: Mon, 23 Feb 2009 16:33:23 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of
	precalculated values
Message-ID: <20090223163322.GN6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902231003090.7298@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 10:23:52AM -0500, Christoph Lameter wrote:
> On Sun, 22 Feb 2009, Mel Gorman wrote:
> 
> > Every page allocation uses gfp_zone() to calcuate what the highest zone
> > allowed by a combination of GFP flags is. This is a large number of branches
> > to have in a fast path. This patch replaces the branches with a lookup
> > table that is calculated at boot-time and stored in the read-mostly section
> > so it can be shared. This requires __GFP_MOVABLE to be redefined but it's
> > debatable as to whether it should be considered a zone modifier or not.
> 
> Are you sure that this is a benefit?

I haven't proved it, but my thinking was that this was a crapload of
branches in fast paths that will be mispredicted. I tried profiling the
RETIRED_MISPREDICTED_BRANCH_INSTRUCTIONS event and noticed there were large
numbers in this general area. However, the profile counters for this event
seem to be very difficult to isolate to a specific area of code so it's
difficult to be 100% certain.

> Jumps are forward and pretty short
> and the compiler is optimizing a branch away in the current code.
> 

I was concerned with mispredictions here rather than the actual assembly
and gfp_zone is inlined so it's lot of branches introduced in a lot of paths.

> 
> 0xffffffff8027bde8 <try_to_free_pages+95>:      mov    %esi,-0x58(%rbp)
> 0xffffffff8027bdeb <try_to_free_pages+98>:      movq   $0xffffffff80278cd0,-0x48(%rbp)
> 0xffffffff8027bdf3 <try_to_free_pages+106>:     test   $0x1,%r8b
> 0xffffffff8027bdf7 <try_to_free_pages+110>:     mov    0x620(%rax),%rax
> 0xffffffff8027bdfe <try_to_free_pages+117>:     mov    %rax,-0x88(%rbp)
> 0xffffffff8027be05 <try_to_free_pages+124>:     jne    0xffffffff8027be2c <try_to_free_pages+163>
> 0xffffffff8027be07 <try_to_free_pages+126>:     mov    $0x1,%r14d
> 0xffffffff8027be0d <try_to_free_pages+132>:     test   $0x4,%r8b
> 0xffffffff8027be11 <try_to_free_pages+136>:     jne    0xffffffff8027be2c <try_to_free_pages+163>
> 0xffffffff8027be13 <try_to_free_pages+138>:     xor    %r14d,%r14d
> 0xffffffff8027be16 <try_to_free_pages+141>:     and    $0x100002,%r8d
> 0xffffffff8027be1d <try_to_free_pages+148>:     cmp    $0x100002,%r8d
> 0xffffffff8027be24 <try_to_free_pages+155>:     sete   %r14b
> 0xffffffff8027be28 <try_to_free_pages+159>:     add    $0x2,%r14d
> 0xffffffff8027be2c <try_to_free_pages+163>:     mov    %gs:0x8,%rdx
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
