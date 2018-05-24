Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D155F6B000C
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18-v6so1054435wrm.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f44-v6si966016eda.334.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/5] mm, proc: add NR_RECLAIMABLE to /proc/meminfo
Date: Thu, 24 May 2018 13:00:11 +0200
Message-Id: <20180524110011.1940-6-vbabka@suse.cz>
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
References: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

The vmstat NR_RECLAIMABLE counter is a superset of NR_SLAB_RECLAIMABLE and
other non-slab allocations that can be reclaimed via shrinker. Make it visible
also in /proc/meminfo and /sys/...node info.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/base/node.c | 2 ++
 fs/proc/meminfo.c   | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a5e821d09656..b35e3627eab7 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -118,6 +118,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d NFS_Unstable:   %8lu kB\n"
 		       "Node %d Bounce:         %8lu kB\n"
 		       "Node %d WritebackTmp:   %8lu kB\n"
+		       "Node %d Reclaimable:    %8lu kB\n"
 		       "Node %d Slab:           %8lu kB\n"
 		       "Node %d SReclaimable:   %8lu kB\n"
 		       "Node %d SUnreclaim:     %8lu kB\n"
@@ -138,6 +139,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+		       nid, K(node_page_state(pgdat, NR_RECLAIMABLE)),
 		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE) +
 			      node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE)),
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 2fb04846ed11..6ca0158a9ebd 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -93,10 +93,11 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Mapped:         ",
 		    global_node_page_state(NR_FILE_MAPPED));
 	show_val_kb(m, "Shmem:          ", i.sharedram);
+	show_val_kb(m, "Reclaimable:    ",
+		    global_node_page_state(NR_RECLAIMABLE));
 	show_val_kb(m, "Slab:           ",
 		    global_node_page_state(NR_SLAB_RECLAIMABLE) +
 		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
-
 	show_val_kb(m, "SReclaimable:   ",
 		    global_node_page_state(NR_SLAB_RECLAIMABLE));
 	show_val_kb(m, "SUnreclaim:     ",
-- 
2.17.0
