Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3192440901
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 143so8050984wmu.5
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:32 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i1si5907543wri.372.2017.07.14.01.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y5so9361896wmh.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/9] mm, memory_hotplug: remove explicit build_all_zonelists from try_online_node
Date: Fri, 14 Jul 2017 10:00:02 +0200
Message-Id: <20170714080006.7250-6-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hp.com>

From: Michal Hocko <mhocko@suse.com>

try_online_node calls hotadd_new_pgdat which already calls
build_all_zonelists. So the additional call is redundant.  Even though
hotadd_new_pgdat will only initialize zonelists of the new node this is
the right thing to do because such a node doesn't have any memory so
other zonelists would ignore all the zones from this node anyway.

Cc: Toshi Kani <toshi.kani@hp.com>
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
