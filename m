Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5F060830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 08:38:30 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so113840686wmp.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 05:38:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r138si16486997wmg.30.2016.02.08.05.38.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 05:38:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/5] mm, memory hotplug: small cleanup in online_pages()
Date: Mon,  8 Feb 2016 14:38:09 +0100
Message-Id: <1454938691-2197-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

We can reuse the nid we've determined instead of repeated pfn_to_nid() usages.
Also zone_to_nid() should be a bit cheaper in general than pfn_to_nid().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/memory_hotplug.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7aa7697fedd1..66064008a489 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1082,7 +1082,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	arg.nr_pages = nr_pages;
 	node_states_check_changes_online(nr_pages, zone, &arg);
 
-	nid = pfn_to_nid(pfn);
+	nid = zone_to_nid(zone);
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -1122,7 +1122,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	if (onlined_pages) {
-		node_states_set_node(zone_to_nid(zone), &arg);
+		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, NULL);
 		else
@@ -1134,7 +1134,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
-		kswapd_run(zone_to_nid(zone));
+		kswapd_run(nid);
 		kcompactd_run(nid);
 	}
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
