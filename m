Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A9FC36B004D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:15:44 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id q16so99930bkw.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:15:44 -0800 (PST)
Subject: [PATCH 1/7] mm/memcg: scanning_global_lru means mem_cgroup_disabled
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 29 Feb 2012 13:15:39 +0400
Message-ID: <20120229091539.29236.57783.stgit@zurg>
In-Reply-To: <20120229090748.29236.35489.stgit@zurg>
References: <20120229090748.29236.35489.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Hugh Dickins <hughd@google.com>

Although one has to admire the skill with which it has been concealed,
scanning_global_lru(mz) is actually just an interesting way to test
mem_cgroup_disabled().  Too many developer hours have been wasted on
confusing it with global_reclaim(): just use mem_cgroup_disabled().

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 003b3f5..082fbc2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -164,26 +164,16 @@ static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
 }
-
-static bool scanning_global_lru(struct mem_cgroup_zone *mz)
-{
-	return !mz->mem_cgroup;
-}
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
 	return true;
 }
-
-static bool scanning_global_lru(struct mem_cgroup_zone *mz)
-{
-	return true;
-}
 #endif
 
 static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
 {
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_reclaim_stat(mz->mem_cgroup, mz->zone);
 
 	return &mz->zone->reclaim_stat;
@@ -192,7 +182,7 @@ static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
 static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
 				       enum lru_list lru)
 {
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
 						    zone_to_nid(mz->zone),
 						    zone_idx(mz->zone),
@@ -1806,7 +1796,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
 	if (!total_swap_pages)
 		return 0;
 
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
 						       mz->zone);
 
@@ -1845,7 +1835,7 @@ static int inactive_file_is_low_global(struct zone *zone)
  */
 static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
 						       mz->zone);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
