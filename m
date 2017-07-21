Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5533B6B02FA
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so5704970wmg.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n52si5229634wrn.239.2017.07.21.07.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m4so7209686wmi.4
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/9] mm, memory_hotplug: remove explicit build_all_zonelists from try_online_node
Date: Fri, 21 Jul 2017 16:39:11 +0200
Message-Id: <20170721143915.14161-6-mhocko@kernel.org>
In-Reply-To: <20170721143915.14161-1-mhocko@kernel.org>
References: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>

From: Michal Hocko <mhocko@suse.com>

try_online_node calls hotadd_new_pgdat which already calls
build_all_zonelists. So the additional call is redundant.  Even though
hotadd_new_pgdat will only initialize zonelists of the new node this is
the right thing to do because such a node doesn't have any memory so
other zonelists would ignore all the zones from this node anyway.

Cc: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 639b8af37c45..0d2f6a11075c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1104,13 +1104,6 @@ int try_online_node(int nid)
 	node_set_online(nid);
 	ret = register_one_node(nid);
 	BUG_ON(ret);
-
-	if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
-		mutex_lock(&zonelists_mutex);
-		build_all_zonelists(NULL);
-		mutex_unlock(&zonelists_mutex);
-	}
-
 out:
 	mem_hotplug_done();
 	return ret;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
