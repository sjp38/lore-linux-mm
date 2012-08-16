Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 834246B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:53:56 -0400 (EDT)
Received: by obbun3 with SMTP id un3so2143837obb.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:53:55 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 2/6] memcg: add target_mem_cgroup, mem_cgroup fields to shrink_control
Date: Thu, 16 Aug 2012 13:53:54 -0700
Message-Id: <1345150434-30957-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

Add target_mem_cgroup and mem_cgroup to shrink_control. The former one is the
"root" memcg under pressure, and the latter one is the "current" memcg under
pressure.

The target_mem_cgroup is initialized with the scan_control's target_mem_cgroup
under target reclaim and default to NULL for rest of the places including
global reclaim.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/shrinker.h |   10 ++++++++++
 mm/vmscan.c              |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index d7165ce..d3732d0 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -12,6 +12,16 @@ struct shrink_control {
 	unsigned long nr_to_scan;
 
 	int priority;
+	/*
+	 * The memory cgroup that is the primary target of this reclaim. Set to
+	 * NULL during a global reclaim.
+	 */
+	struct mem_cgroup *target_mem_cgroup;
+	/*
+	 * The memory cgroup that is current being scanned in order to reclaim
+	 * from the hierarchy of mem_cgroup.
+	 */
+	struct mem_cgroup *mem_cgroup;
 };
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2c7be04..6ffdff6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2323,6 +2323,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
+		.target_mem_cgroup = sc.target_mem_cgroup,
 	};
 
 	/*
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
