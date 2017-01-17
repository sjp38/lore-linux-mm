Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A463A6B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:15:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r144so32167147wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:53 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x204si15251943wmx.24.2017.01.17.01.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 01:15:52 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r144so36916161wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/4] mm, page_alloc: do not report all nodes in show_mem
Date: Tue, 17 Jan 2017 10:15:40 +0100
Message-Id: <20170117091543.25850-2-mhocko@kernel.org>
In-Reply-To: <20170117091543.25850-1-mhocko@kernel.org>
References: <20170117091543.25850-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

599d0c954f91 ("mm, vmscan: move LRU lists to node") has added per numa
node statistics to show_mem but it forgot to add skip_free_areas_node
to fileter out nodes which are outside of the allocating task numa
policy. Add this check to not pollute the output with the pointless
information.

Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8ff25883c172..8f4f306d804c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4345,6 +4345,9 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_online_pgdat(pgdat) {
+		if (skip_free_areas_node(filter, pgdat->node_id))
+			continue;
+
 		printk("Node %d"
 			" active_anon:%lukB"
 			" inactive_anon:%lukB"
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
