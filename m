From: Andy Whitcroft <apw@shadowen.org>
Subject: [RFC PATCH 0/4] Reclaim page capture v2
Date: Wed,  3 Sep 2008 19:44:08 +0100
Message-Id: <1220467452-15794-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

For sometime we have been looking at mechanisms for improving the availability
of larger allocations under load.  One of the options we have explored is
the capturing of pages freed under direct reclaim in order to increase the
chances of free pages coelescing before they are subject to reallocation
by racing allocators.

Following this email is a patch stack implementing page capture during
direct reclaim.  It consits of four patches.  The first two simply pull
out existing code into helpers for reuse.  The third makes buddy's use
of struct page explicit.  The fourth contains the meat of the changes,
and its leader contains a much fuller description of the feature.

This update represents a rebase to -mm and incorporates feedback from
KOSAKI Motohiro.  It also incorporates an accounting fix which was
preventing some captures.

I have done a lot of comparitive testing with and without this patch
set and in broad brush I am seeing improvements in hugepage allocations
(worst case size) success on all of my test systems.  These tests consist
of placing a constant stream of high order allocations on the system,
at varying rates.  The results for these various runs are then averaged
to give an overall improvement.

		Absolute	Effective
x86-64		2.48%		 4.58%
powerpc		5.55%		25.22%

x86-64 has a relatively small huge page size and so is always much more
effective at allocating huge pages.  Even there we get a measurable
improvement.  On powerpc the huge pages are much larger and much harder
to recover.  Here we see a full 25% increase in page recovery.

It should be noted that these are worst case testing, and very agressive
taking every possible page in the system.

Against: 2.6.27-rc1-mm1

Comments?

-apw

Changes since V1:
 - Incorporates review feedback from KOSAKI Motohiro,
 - fixes up accounting when checking watermarks for captured pages,
 - rebase 2.6.27-rc1-mm1,
 - Incorporates review feedback from Mel.

Andy Whitcroft (4):
  pull out the page pre-release and sanity check logic for reuse
  pull out zone cpuset and watermark checks for reuse
  buddy: explicitly identify buddy field use in struct page
  capture pages freed during direct reclaim for allocation by the
    reclaimer

 include/linux/mm_types.h   |    4 +
 include/linux/page-flags.h |    6 +
 mm/internal.h              |    8 ++-
 mm/page_alloc.c            |  255 ++++++++++++++++++++++++++++++++++++++------
 mm/vmscan.c                |  115 ++++++++++++++++----
 5 files changed, 332 insertions(+), 56 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
