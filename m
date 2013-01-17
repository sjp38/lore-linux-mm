Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id CB24D6B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:10 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 15:54:10 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7B73019D803C
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:06 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HMs50G252496
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:06 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HMs2bj006602
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:02 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 0/9] mm: zone & pgdat accessors plus some cleanup
Date: Thu, 17 Jan 2013 14:52:52 -0800
Message-Id: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

Summaries:
1 - avoid repeating checks for section in page flags by adding a define.
2 - add & switch to zone_end_pfn() and zone_spans_pfn()
3 - adds zone_is_initialized() & zone_is_empty()
4 - adds a VM_BUG using zone_is_initialized() in __free_one_page()
5 - add pgdat_end_pfn() and pgdat_is_empty()
6 - add debugging message to VM_BUG check.
7 - add ensure_zone_is_initialized() (for memory_hotplug)
8 - use the above addition in memory_hotplug
9 - use pgdat_end_pfn()

As a general concern: spanned_pages & start_pfn (in pgdat & zone) are supposed
to be locked (via a seqlock) when read (due to changes to them via
memory_hotplug), but very few (only 1?) of their users appear to actually lock
them.

--

Since v1:
 - drop zone+pgdat growth factoring (I use this in some WIP code to resign the
   NUMA node a page belongs to, will send with that patchset)
 - merge zone_end_pfn() & zone_spans_pfn() introduction & usage
 - split zone_is_initialized() & zone_is_empty() out from the above.
 - add a missing semicolon

 include/linux/mm.h     |  8 ++++++--
 include/linux/mmzone.h | 34 +++++++++++++++++++++++++++++----
 mm/compaction.c        | 10 +++++-----
 mm/kmemleak.c          |  5 ++---
 mm/memory_hotplug.c    | 52 ++++++++++++++++++++++++++------------------------
 mm/page_alloc.c        | 31 +++++++++++++++++-------------
 mm/vmstat.c            |  2 +-
 7 files changed, 89 insertions(+), 53 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
