Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5067F6B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 08:13:38 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/3] vmscan, memcg: Do softlimit reclaim also for targeted reclaim
Date: Tue,  9 Apr 2013 14:13:15 +0200
Message-Id: <1365509595-665-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1365509595-665-1-git-send-email-mhocko@suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

Soft reclaim has been done only for the global reclaim (both background
and direct). Since "memcg: integrate soft reclaim tighter with zone
shrinking code" there is no reason for this limitation anymore as the
soft limit reclaim doesn't use any special code paths and it is a
part of the zone shrinking code which is used by both global and
targeted reclaims.

>From semantic point of view it is even natural to consider soft limit
before touching all groups in the hierarchy tree which is touching the
hard limit because soft limit tells us where to push back when there is
a memory pressure. It is not important whether the pressure comes from
the limit or imbalanced zones.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ae3a387..cf729ca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -141,7 +141,7 @@ static bool global_reclaim(struct scan_control *sc)
 
 static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
 {
-	return global_reclaim(sc);
+	return true;
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
