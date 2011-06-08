Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B43D86B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 21:22:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9CE863EE0AE
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 10:21:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8485645DE67
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 10:21:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B19645DE4E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 10:21:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D28E1DB8040
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 10:21:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2416D1DB8038
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 10:21:59 +0900 (JST)
Date: Wed, 8 Jun 2011 10:15:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix node hotplug zonelist build
Message-Id: <20110608101506.60642149.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, dave@linux.vnet.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>


At memory hotplug, we reflesh zonelists when we online a page in a new zone.
It means that Node's zonelist is not initialized until pages are onlined. So,
for example, "nid" passed by MEM_GOING_ONLINE notifier will point to
NODE_DATA(nid) which has no zone fallback list. Moreover, if we hot-add
cpu-only nodes, alloc_pages() will do no fallback.

This patch makes zonelist when a new pgdata is available.

Note: in production, at fujitsu, memory should be onlined before cpu
      and our server didn't have any memory-less nodes and had no problems.

      But recent changes in MEM_GOING_ONLINE+page_cgroup
      will access not initialized zonelist of node.
      Anyway, there are memory-less node and we need some care.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-3.0-rc1/mm/memory_hotplug.c
===================================================================
--- linux-3.0-rc1.orig/mm/memory_hotplug.c
+++ linux-3.0-rc1/mm/memory_hotplug.c
@@ -494,6 +494,12 @@ static pg_data_t __ref *hotadd_new_pgdat
 	/* init node's zones as empty zones, we don't have any present pages.*/
 	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
 
+	/*
+	 * The node we allocated has no zone fallback lists. For avoiding
+	 * to access not-initialized zonelist, build here.
+	 */
+	build_all_zonelists(NULL);
+
 	return pgdat;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
