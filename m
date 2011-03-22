Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6A38D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:31:27 -0400 (EDT)
Date: Tue, 22 Mar 2011 22:30:45 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] mm: page allocator: Silence build_all_zonelists() section mismatch.
Message-ID: <20110322133045.GA24498@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The memory hotplug case involves calling to build_all_zonelists() which
in turns calls in to setup_zone_pageset(). The latter is marked
__meminit while build_all_zonelists() itself has no particular
annotation. build_all_zonelists() is only handed a non-NULL pointer in
the case of memory hotplug through an existing __meminit path, so the
setup_zone_pageset() reference is always safe.

The options as such are either to flag build_all_zonelists() as __ref (as
per __build_all_zonelists()), or to simply discard the __meminit
annotation from setup_zone_pageset().

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

---

While discarding the __meminit annotation from setup_zone_pageset() is
probably cleanest I expected some people would take issue with this so
opted for the more visually offensive __ref route. I can resend for the
other way if people prefer, or someone else can do it given that it's a
trivial change.

 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7945247..134e0b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3110,7 +3110,7 @@ static __init_refok int __build_all_zonelists(void *data)
  * Called with zonelists_mutex held always
  * unless system_state == SYSTEM_BOOTING.
  */
-void build_all_zonelists(void *data)
+void __ref build_all_zonelists(void *data)
 {
 	set_zonelist_order();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
