Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A049D6B0039
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:08:42 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 13:08:41 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3A0F838C804A
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:08:39 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DJ8dG0307246
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:08:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DJ8cYI016559
	for <linux-mm@kvack.org>; Mon, 13 May 2013 16:08:39 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH RESEND v3 00/11] mm: fixup changers of per cpu pageset's ->high and ->batch
Date: Mon, 13 May 2013 12:08:12 -0700
Message-Id: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

"Problems" with the current code:
 1. there is a lack of synchronization in setting ->high and ->batch in
    percpu_pagelist_fraction_sysctl_handler()
 2. stop_machine() in zone_pcp_update() is unnecissary.
 3. zone_pcp_update() does not consider the case where percpu_pagelist_fraction is non-zero

To fix:
 1. add memory barriers, a safe ->batch value, an update side mutex when
    updating ->high and ->batch, and use ACCESS_ONCE() for ->batch users that
    expect a stable value.
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

Since v2: https://lkml.org/lkml/2013/4/9/718

 - note ACCESS_ONCE() in fix #1 above.
 - consolidate ->batch & ->high update protocol into a single funtion (Gilad).
 - add missing ACCESS_ONCE() on ->batch

Since v1: https://lkml.org/lkml/2013/4/5/444

 - instead of using on_each_cpu(), use memory barriers (Gilad) and an update side mutex.
 - add "Problem" #3 above, and fix.
 - rename function to match naming style of similar function
 - move unrelated comment

--

Cody P Schafer (11):
  mm/page_alloc: factor out setting of pcp->high and pcp->batch.
  mm/page_alloc: prevent concurrent updaters of pcp ->batch and ->high
  mm/page_alloc: insert memory barriers to allow async update of pcp
    batch and high
  mm/page_alloc: protect pcp->batch accesses with ACCESS_ONCE
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

 mm/page_alloc.c | 151 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 90 insertions(+), 61 deletions(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
