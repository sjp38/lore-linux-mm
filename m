Date: Wed, 1 Jun 2005 10:22:29 -0400
From: Martin Hicks <mort@sgi.com>
Subject: [PATCH 0/4] VM: Automatic page cache reclaim (take 3)
Message-ID: <20050601142229.GS14894@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

Here's the next round of these patches.  These are totally different in
an attempt to meet the "simpler" request after the last patches.  For
reference the earlier threads are:

http://marc.theaimsgroup.com/?l=linux-kernel&m=110839604924587&w=2
http://marc.theaimsgroup.com/?l=linux-mm&m=111461480721249&w=2

This set of patches replaces my other vm- patches that are currently in
-mm.  So they're against 2.6.12-rc5-mm1 about half way through the -mm
patchset.

As I said already this patch is a lot simpler.  The reclaim is turned on
or off on a per-zone basis using a syscall.  I haven't tested the x86
syscall, so it might be wrong.  It uses the existing reclaim/pageout
code with the small addition of a may_swap flag to scan_control
(patch 1/4).

I also added __GFP_NORECLAIM (patch 3/4) so that certain allocation
types can be flagged to never cause reclaim.  This was a deficiency
that was in all of my earlier patch sets.  Previously, doing a big
buffered read would fill one zone with page cache and then start to
reclaim from that same zone, leaving the other zones untouched.

Adding some extra throttling on the reclaim was also required (patch
4/4).  Without the machine would grind to a crawl when doing a "make -j"
kernel build.  Even with this patch the System Time is higher on
average, but it seems tolerable.  Here are some numbers for kernbench
runs on a 2-node, 4cpu, 8Gig RAM Altix in the "make -j" run:

			wall  user   sys   %cpu  ctx sw.  sleeps
			----  ----   ---   ----   ------  ------
No patch		1009  1384   847   258   298170   504402
w/patch, no reclaim     880   1376   667   288   254064   396745
w/patch & reclaim       1079  1385   926   252   291625   548873

These numbers are the average of 2 runs of 3 "make -j" runs done right
after system boot.  Run-to-run variability for "make -j" is huge, so
these numbers aren't terribly useful except to seee that with reclaim
the benchmark still finishes in a reasonable amount of time.

I also looked at the NUMA hit/miss stats for the "make -j" runs and the
reclaim doesn't make any difference when the machine is thrashing away.

Doing a "make -j8" on a single node that is filled with page cache pages
takes 700 seconds with reclaim turned on and 735 seconds without reclaim
(due to remote memory accesses).

The simple zone_reclaim syscall program is at
http://www.bork.org/~mort/sgi/zone_reclaim.c

Please test or comment!
mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
