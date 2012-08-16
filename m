Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DAFBD6B0070
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:54:14 -0400 (EDT)
Received: by mail-wi0-f201.google.com with SMTP id hm2so54290wib.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:54:14 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 5/6] memcg: move dcache slabs to root lru when memcg exits
Date: Thu, 16 Aug 2012 13:54:13 -0700
Message-Id: <1345150453-31122-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

Move dcache slabs to root cgroup's lru bucket when the memcg is deleted. This
allows further memory pressure to apply on those dcache objects.

This is based on our internal kernel slab accounting patch which the kmem_cache
owner is reset to root cgroup after the memcg is removed. I am aware of the
inconsistancy of the patch proposed upstream by far, and the corresponding
adjustment are needed later.

A bit off-topicIdeally, it would make more sense to still *charge* the
left-over kmem_cache to *a* memcg (either the removed memcg or its parent).
And whenever there is a memory pressure, the pressure will still apply to
those objects.

Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/dcache.c            |   29 +++++++++++++++++++++++++++++
 include/linux/dcache.h |    4 ++++
 mm/memcontrol.c        |    9 +++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 278b4e5..cc1c5b3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1072,6 +1072,35 @@ restart:
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * Caller must hold dcache_lru_lock.
+ */
+static void dcache_lru_move_sb(struct super_block *sb, void *arg)
+{
+	struct list_head put_back;
+	struct mem_cgroup *src = arg;
+
+	INIT_LIST_HEAD(&put_back);
+
+	list_splice_init(&sb->s_dentry_lru[hash_mem_cgroup(src)], &put_back);
+
+	dcache_put_back_lru(sb, &put_back);
+}
+
+/*
+ * This removes and re-inserts all lru dentries previously indexed for @src
+ * memcg.  The re-insertion uses dentry->page->cachep->memcg to index the
+ * dentries to a new memcg.
+ */
+void dcache_lru_move(struct mem_cgroup *src)
+{
+	spin_lock(&dcache_lru_lock);
+	iterate_supers(dcache_lru_move_sb, src);
+	spin_unlock(&dcache_lru_lock);
+}
+#endif
+
 /*
  * destroy a single subtree of dentries for unmount
  * - see the comments on shrink_dcache_for_umount() for a description of the
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 624c079..6387eea 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -419,4 +419,8 @@ extern void d_clear_need_lookup(struct dentry *dentry);
 
 extern int sysctl_vfs_cache_pressure;
 
+struct mem_cgroup;
+
+extern void dcache_lru_move(struct mem_cgroup *src);
+
 #endif	/* __LINUX_DCACHE_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95162c9..f86a763 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4663,6 +4663,15 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 {
+	/*
+	 * Now this memcg's dcache kmem_cache->memcg is set to root_mem_cgroup.
+	 * Move all lru dentries to root memcg's lru.  It is possible that there
+	 * are processes holding reference to off-lru dentries.  When closed,
+	 * these off-lru dentries will be added to the root_mem_cgroup because
+	 * they will see the updated page->cachep->memcg, which will point to
+	 * root_mem_cgroup as set above.
+	 */
+	dcache_lru_move(memcg);
 	mem_cgroup_sockets_destroy(memcg);
 }
 #else
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
