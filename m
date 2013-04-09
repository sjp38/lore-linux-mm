Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DA4B86B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:46 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 17:28:46 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0147B3E40040
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:28:28 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39NSes6164930
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:40 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39NSeNk006627
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:40 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 00/10] mm: fixup changers of per cpu pageset's ->high and ->batch
Date: Tue,  9 Apr 2013 16:28:09 -0700
Message-Id: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

"Problems" with the current code:
 1. there is a lack of synchronization in setting ->high and ->batch in percpu_pagelist_fraction_sysctl_handler()
 2. stop_machine() in zone_pcp_update() is unnecissary.
 3. zone_pcp_update() does not consider the case where percpu_pagelist_fraction is non-zero

To fix:
 1. add memory barriers, a safe ->batch value, and an update side mutex when updating ->high and ->batch
 2. avoid draining pages in zone_pcp_update(), rely upon the memory barriers added to fix #1
 3. factor out quite a few functions, and then call the appropriate one.

Note that it results in a change to the behavior of zone_pcp_update(), which is
used by memory_hotplug. I'm rather certain that I've diserned (and preserved)
the essential behavior (changing ->high and ->batch), and only eliminated
unneeded actions (draining the per cpu pages), but this may not be the case.

Further note that the draining of pages that previously took place in
zone_pcp_update() occured after repeated draining when attempting to offline a
page, and after the offline has "succeeded". It appears that the draining was
added to zone_pcp_update() to avoid refactoring setup_pageset() into 2
funtions.

--
Changes since v1:

 - instead of using on_each_cpu(), use memory barriers (Gilad) and an update side mutex.
 - add "Problem" #3 above, and fix.
 - rename function to match naming style of similar function
 - move unrelated comment

Cody P Schafer (10):
  mm/page_alloc: factor out setting of pcp->high and pcp->batch.
  mm/page_alloc: prevent concurrent updaters of pcp ->batch and ->high
  mm/page_alloc: insert memory barriers to allow async update of pcp
    batch and high
  mm/page_alloc: convert zone_pcp_update() to rely on memory barriers
    instead of stop_machine()
  mm/page_alloc: when handling percpu_pagelist_fraction, don't unneedly
    recalulate high
  mm/page_alloc: factor setup_pageset() into pageset_init() and
    pageset_set_batch()
  mm/page_alloc: relocate comment to be directly above code it refers
    to.
  mm/page_alloc: factor zone_pageset_init() out of setup_zone_pageset()
  mm/page_alloc: in zone_pcp_update(), uze zone_pageset_init()
  mm/page_alloc: rename setup_pagelist_highmark() to match naming of
    pageset_set_batch()

 mm/page_alloc.c | 124 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 73 insertions(+), 51 deletions(-)

-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
