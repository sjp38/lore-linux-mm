Subject: [PATCH] 0/2 Buddy allocator with placement policy (Version 9) + prezeroing (Version 4)
Message-Id: <20050307193938.0935EE594@skynet.csn.ul.ie>
Date: Mon,  7 Mar 2005 19:39:38 +0000 (GMT)
From: mel@csn.ul.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The following two emails contain the latest version of the placement policy
for the binary buddy allocator to reduce fragmentation and the prezeroing
patch. The changelogs are with the patches.

The placement policy patch should now be more Hotplug-friendly and I would like
to hear from the Hotplug people if they have more requirements of this patch.
Of interest, rmqueue_bulk() has been taught how to allocate large blocks of
pages and split them up into the requested size. An impact of this is that
refilling the per-cpu caches will sometimes be satisfied with a single 2**4
allocation rather than 16 2**0 allocations. Lastly, the beancounters are
now a configurable option under "Kernel Hacking".

In terms of fragmentation, the placement policy still performs really well
and The placement policies raw performance for aim9 and ghostscript rendering
are comparable to the normal allocator so there should be no regressions
there. I've posted new figures with the patch.

The prezeroing patch still regresses fragmentation slightly but nowhere near
as bad as previously. However, the aim9 figures for the prezeroing patch
suck big-time. I suspect it is because zero-allocations are very common
but the lists are usually empty so there is a lot of list traversal that
yield nothing.  Figures posted with patch.  I have a solution in mind but
it'll be a while before I implement it.

In case others want to reproduce the allocation and ghostscript
benchmarks, I've included them as scripts in vmregress-0.13
(http://www.skynet.ie/~mel/projects/vmregress/vmregress-0.13.tar.gz) but
they are still not integrated with OSDL's STP tool. The scripts are in
bin/bench-gs.sh and bin/bench-stresshighalloc.sh and both take the --help
switch to explain what they do.

The patches were developed and tested heavily on 2.6.11. 

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
