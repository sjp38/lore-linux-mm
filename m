Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 181926B00FD
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:28:47 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so8251658pbc.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:28:46 -0800 (PST)
Date: Mon, 20 Feb 2012 15:28:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/10] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201526540.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Although one has to admire the skill with which it has been concealed,
scanning_global_lru(mz) is actually just an interesting way to test
mem_cgroup_disabled().  Too many developer hours have been wasted on
confusing it with global_reclaim(): just use mem_cgroup_disabled().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

--- mmotm.orig/mm/vmscan.c	2012-02-18 11:56:23.815522718 -0800
+++ mmotm/mm/vmscan.c	2012-02-18 11:56:33.395522945 -0800
@@ -164,26 +164,16 @@ static bool global_reclaim(struct scan_c
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
@@ -192,7 +182,7 @@ static struct zone_reclaim_stat *get_rec
 static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
 				       enum lru_list lru)
 {
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
 						    zone_to_nid(mz->zone),
 						    zone_idx(mz->zone),
@@ -1804,7 +1794,7 @@ static int inactive_anon_is_low(struct m
 	if (!total_swap_pages)
 		return 0;
 
-	if (!scanning_global_lru(mz))
+	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
 						       mz->zone);
 
@@ -1843,7 +1833,7 @@ static int inactive_file_is_low_global(s
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
