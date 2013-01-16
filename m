Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 001E26B006C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:17 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:25:16 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id E64BBC9003E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:14 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PEI417432606
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:14 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PE92017527
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:14 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 00/17] mm: zone & pgdat accessors plus some cleanup
Date: Tue, 15 Jan 2013 16:24:37 -0800
Message-Id: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

Summaries:

01 - removes the use of zone_end_pfn as a local var name.
02 - adds zone_end_pfn(), zone_is_initialized(), zone_is_empty() and zone_spans_pfn()
03 - adds a VM_BUG using zone_is_initialized() in __free_one_page()

04 - add ensure_zone_is_initialized() (for memory_hotplug)
05 - use the above addition.

06 - add pgdat_end_pfn() and pgdat_is_empty()

07,08,09,10,11,12,16,17 - use the new helpers

13 - avoid repeating checks for section in page flags by adding a define.
14 - memory hotplug: factor out zone+pgdat growth.
15 - add debugging message to VM_BUG check.

As a general concern: spanned_pages & start_pfn (in pgdat & zone) are supposed
to be locked (via a seqlock) when read (due to changes to them via
memory_hotplug), but very few (only 1?) of their users appear to actually lock
them.

--

 include/linux/mm.h     |  8 ++++--
 include/linux/mmzone.h | 34 ++++++++++++++++++++++---
 mm/compaction.c        | 10 ++++----
 mm/kmemleak.c          |  5 ++--
 mm/memory_hotplug.c    | 68 ++++++++++++++++++++++++++++----------------------
 mm/page_alloc.c        | 31 +++++++++++++----------
 mm/vmstat.c            |  2 +-
 7 files changed, 100 insertions(+), 58 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
