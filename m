Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB9F6B0070
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:20 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id z11so14834726lbi.10
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:19 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id k12si2287125laa.24.2015.01.15.10.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:17 -0800 (PST)
Subject: [PATCH 3/6] memcg: track shared inodes with dirty pages
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:14 +0300
Message-ID: <20150115184914.10450.51964.stgit@buzz>
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Inode is owned only by one memory cgroup, but if it's shared it might
contain pages from multiple cgroups. This patch detects this situation
in memory reclaiemer and marks dirty inode with flag I_DIRTY_SHARED
which is cleared only when data is completely written. Memcg writeback
always writes such inodes.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/fs-writeback.c          |    4 ++--
 include/linux/fs.h         |    3 +++
 include/linux/memcontrol.h |    4 ++++
 mm/memcontrol.c            |   20 ++++++++++++++++++++
 mm/vmscan.c                |    4 ++++
 5 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 9034768..fda6a64 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -484,7 +484,7 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	 */
 	spin_lock(&inode->i_lock);
 
-	dirty = inode->i_state & I_DIRTY;
+	dirty = inode->i_state & (I_DIRTY | I_DIRTY_SHARED);
 	inode->i_state &= ~I_DIRTY;
 
 	/*
@@ -501,7 +501,7 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	smp_mb();
 
 	if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
-		inode->i_state |= I_DIRTY_PAGES;
+		inode->i_state |= I_DIRTY_PAGES | (dirty & I_DIRTY_SHARED);
 
 	spin_unlock(&inode->i_lock);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ee2e3c0..303f0ad 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1741,6 +1741,8 @@ struct super_operations {
  *
  * I_DIO_WAKEUP		Never set.  Only used as a key for wait_on_bit().
  *
+ * I_DIRTY_SHARED	Dirty pages belong to multiple memory cgroups.
+ *
  * Q: What is the difference between I_WILL_FREE and I_FREEING?
  */
 #define I_DIRTY_SYNC		(1 << 0)
@@ -1757,6 +1759,7 @@ struct super_operations {
 #define __I_DIO_WAKEUP		9
 #define I_DIO_WAKEUP		(1 << I_DIO_WAKEUP)
 #define I_LINKABLE		(1 << 10)
+#define I_DIRTY_SHARED		(1 << 11)
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ae05563..3f89e9b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -181,6 +181,8 @@ void mem_cgroup_forget_mapping(struct address_space *mapping);
 bool mem_cgroup_dirty_limits(struct address_space *mapping, unsigned long *dirty,
 			     unsigned long *thresh, unsigned long *bg_thresh);
 bool mem_cgroup_dirty_exceeded(struct inode *inode);
+void mem_cgroup_poke_writeback(struct address_space *mapping,
+			       struct mem_cgroup *memcg);
 
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
@@ -358,6 +360,8 @@ static inline void mem_cgroup_forget_mapping(struct address_space *mapping) {}
 static inline bool mem_cgroup_dirty_limits(struct address_space *mapping, unsigned long *dirty,
 			     unsigned long *thresh, unsigned long *bg_thresh) { return false; }
 static inline bool mem_cgroup_dirty_exceeded(struct inode *inode) { return false; }
+static inline void mem_cgroup_poke_writeback(struct address_space *mapping,
+					     struct mem_cgroup *memcg) { }
 
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 17d966a3b..d9d345c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6064,6 +6064,9 @@ bool mem_cgroup_dirty_exceeded(struct inode *inode)
 	if (mapping->backing_dev_info->dirty_exceeded)
 		return true;
 
+	if (inode->i_state & I_DIRTY_SHARED)
+		return true;
+
 	rcu_read_lock();
 	memcg = rcu_dereference(mapping->i_memcg);
 	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
@@ -6084,6 +6087,23 @@ bool mem_cgroup_dirty_exceeded(struct inode *inode)
 	return memcg != NULL;
 }
 
+void mem_cgroup_poke_writeback(struct address_space *mapping,
+			       struct mem_cgroup *memcg)
+{
+	struct inode *inode = mapping->host;
+
+	if (rcu_access_pointer(mapping->i_memcg) == memcg ||
+	    !memcg->dirty_exceeded)
+		return;
+
+	if (inode->i_state & (I_DIRTY_PAGES|I_DIRTY_SHARED) == I_DIRTY_PAGES) {
+		spin_lock(&inode->i_lock);
+		if (inode->i_state & I_DIRTY_PAGES)
+			inode->i_state |= I_DIRTY_SHARED;
+		spin_unlock(&inode->i_lock);
+	}
+}
+
 /*
  * subsys_initcall() for memory controller.
  *
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ab2505c..75165fc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1013,6 +1013,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
 				SetPageReclaim(page);
 
+				if (!global_reclaim(sc))
+					mem_cgroup_poke_writeback(mapping,
+							sc->target_mem_cgroup);
+
 				goto keep_locked;
 			}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
