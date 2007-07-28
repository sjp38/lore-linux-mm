From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/2] Synchronous Lumpy Reclaim V2
Message-ID: <exportbomb.1185662485@pinky>
Date: Sat, 28 Jul 2007 23:51:29 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

As pointed out by Mel when reclaim is applied at higher orders a
significant amount of IO may be started.  As this takes finite time
to drain reclaim will consider more areas than ultimatly needed
to satisfy the request.  This leads to more reclaim than strictly
required and reduced success rates.

I was able to confirm Mel's test results on systems locally.
These show that even under light load the success rates drop off far
more than expected.  Testing with a modified version of his patch
(which follows) I was able to allocate almost all of ZONE_MOVABLE
with a near idle system.  I ran 5 test passes sequentially following
system boot (the system has 29 hugepages in ZONE_MOVABLE):

  2.6.23-rc1              11  8  6  7  7
  sync_lumpy v2           28 28 29 29 26

These show that although hugely better than the near 0% success
normally expected we can only allocate about a 1/4 of the zone.
Using synchronous reclaim for these allocations we get close to 100%
as expected.

I have also run our standard high order tests and these show no
regressions in allocation success rates at rest, and some significant
improvements under load.

Following this email are two patches, both should be considered as
bug fixes to lumpy reclaim:

ensure-we-count-pages-transitioning-inactive-via-clear_active_flags:
  this a bug fix for Lumpy Reclaim fixing up a bug in VM Event
  accounting when it marks pages inactive, and

Wait-for-page-writeback-when-directly-reclaiming-contiguous-areas:
  updates reclaim making direct reclaim synchronous when applied
  at orders above PAGE_ALLOC_COSTLY_ORDER.

Patches against 2.6.23-rc1.  Andrew please consider for -mm and
for pushing to mainline.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
