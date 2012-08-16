Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 07EF06B0069
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:53:52 -0400 (EDT)
Received: by eabm6 with SMTP id m6so144966eab.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:53:51 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 1/6] memcg: pass priority to prune_icache_sb()
Date: Thu, 16 Aug 2012 13:53:50 -0700
Message-Id: <1345150430-30910-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

The same patch posted two years ago at:
http://permalink.gmane.org/gmane.linux.kernel.mm/55467

No change since then and re-post it now mainly because it is part of the
patchset I have internally. Also, the issue that the patch addresses would
be more problematic after the patchset.

Two changes included:
1. only remove inode with pages in its mapping when reclaim priority hits 0.

It helps the situation when shrink_slab() is being too agressive, it ends up
removing the inode as well as all the pages associated with the inode.
Especially when single inode has lots of pages points to it.

The problem was observed on a production workload we run, where it has small
number of large files. Page reclaim won't blow away the inode which is pinned
by dentry which in turn is pinned by open file descriptor. But if the
application is openning and closing the fds, it has the chance to trigger
the issue. The application will experience performance hit when that happens.

After the whole patchset, the code will call the shrinker more often by adding
shrink_slab() into target reclaim. So the performance hit will be more likely
to be observed.

2. avoid wrapping up when scanning inode lru.

The target_scan_count is calculated based on the userpage lru activity,
which could be bigger than the inode lru size. avoid scanning the same
inode twice by remembering the starting point for each scan.

Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/inode.c               |   40 +++++++++++++++++++++++++++++++++++++++-
 fs/super.c               |    2 +-
 include/linux/fs.h       |    3 ++-
 include/linux/shrinker.h |    2 ++
 mm/vmscan.c              |    6 +++++-
 5 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index c99163b..56b79c2 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -691,11 +691,12 @@ static int can_unuse(struct inode *inode)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-void prune_icache_sb(struct super_block *sb, int nr_to_scan)
+void prune_icache_sb(struct super_block *sb, int nr_to_scan, int priority)
 {
 	LIST_HEAD(freeable);
 	int nr_scanned;
 	unsigned long reap = 0;
+	struct inode *first_defer = NULL;
 
 	spin_lock(&sb->s_inode_lru_lock);
 	for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
@@ -736,6 +737,43 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 			spin_unlock(&inode->i_lock);
 			continue;
 		}
+
+		/*
+		 * Removing an inode with pages in its mapping can
+		 * inadvertantly remove large amounts of page cache,
+		 * possibly belonging to a node not in nodemask, but
+		 * may be necessary in order to free up memory in the
+		 * inode's node.
+		 *
+		 * Only do this when priority hits 0.
+		 */
+		if (priority > 0 && inode->i_data.nrpages) {
+			list_move(&inode->i_lru, &sb->s_inode_lru);
+			spin_unlock(&inode->i_lock);
+			/*
+			 * The first_defer is to guarantee to scan inode object
+			 * only once per invocation. It could happen that the
+			 * target nr_to_scan is greater than the inode lru_size
+			 * where the former one is scaled based on user page
+			 * lru_size and other heuristics. So prune_icache_sb
+			 * could be wrapping around the whole list more than
+			 * once.
+			 *
+			 * Since s_inode_lru_lock is held, the inode lru list
+			 * won't change. If a deferred inode is seen twice,
+			 * we know scanning has wrapped around. However, the
+			 * inode->i_data.nrpages might change. So the inode
+			 * could be reaped on the next invocation. And the side
+			 * effect is that we will scan nr_to_scan number of
+			 * objects before breaking out the loop.
+			 */
+			if (first_defer == NULL)
+				first_defer = inode;
+			else if (inode == first_defer)
+				break;
+			continue;
+		}
+
 		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
 			__iget(inode);
 			spin_unlock(&inode->i_lock);
diff --git a/fs/super.c b/fs/super.c
index 5af6817..21817c0 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -87,7 +87,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		 * prune the icache, followed by the filesystem specific caches
 		 */
 		prune_dcache_sb(sb, dentries);
-		prune_icache_sb(sb, inodes);
+		prune_icache_sb(sb, inodes, sc->priority);
 
 		if (fs_objects && sb->s_op->free_cached_objects) {
 			sb->s_op->free_cached_objects(sb, fs_objects);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f21da77..667b4f8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1553,7 +1553,8 @@ struct super_block {
 };
 
 /* superblock cache pruning functions */
-extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
+extern void prune_icache_sb(struct super_block *sb, int nr_to_scan,
+			    int priority);
 extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
 
 extern struct timespec current_fs_time(struct super_block *sb);
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index ac6b8ee..d7165ce 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -10,6 +10,8 @@ struct shrink_control {
 
 	/* How many slab objects shrinker() should scan and try to reclaim */
 	unsigned long nr_to_scan;
+
+	int priority;
 };
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3e0d0cd..2c7be04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2083,7 +2083,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 				lru_pages += zone_reclaimable_pages(zone);
 			}
-
+			shrink->priority = sc->priority;
 			shrink_slab(shrink, sc->nr_scanned, lru_pages);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2636,6 +2636,7 @@ loop_again:
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
+				shrink.priority = sc.priority;
 				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 				total_scanned += sc.nr_scanned;
@@ -3265,6 +3266,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
+		shrink.priority = ZONE_RECLAIM_PRIORITY;
 		for (;;) {
 			unsigned long lru_pages = zone_reclaimable_pages(zone);
 
@@ -3275,6 +3277,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 			/* Freed enough memory */
 			nr_slab_pages1 = zone_page_state(zone,
 							NR_SLAB_RECLAIMABLE);
+			if (shrink.priority > 0)
+				shrink.priority--;
 			if (nr_slab_pages1 + nr_pages <= nr_slab_pages0)
 				break;
 		}
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
