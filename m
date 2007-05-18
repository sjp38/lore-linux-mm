From: clameter@sgi.com
Subject: [patch 04/10] Generic inode defragmentation
Date: Fri, 18 May 2007 11:10:44 -0700
Message-ID: <20070518181119.534255343@sgi.com>
References: <20070518181040.465335396@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763077AbXERSLd@vger.kernel.org>
Content-Disposition: inline; filename=inode_targeted_reclaim
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

This implements the ability to remove a list of inodes from the inode
cache. In order to remove an inode we may have to write out the pages
of an inode, the inode itself and remove the dentries referring to the
node.

Provide generic functionality that can be used by filesystems that have
their own inode caches to also tie into the defragmentation functions
that are made available here.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/inode.c         |   92 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    5 ++
 2 files changed, 96 insertions(+), 1 deletion(-)

Index: slub/fs/inode.c
===================================================================
--- slub.orig/fs/inode.c	2007-05-18 00:50:36.000000000 -0700
+++ slub/fs/inode.c	2007-05-18 00:55:40.000000000 -0700
@@ -1361,6 +1361,96 @@ static int __init set_ihash_entries(char
 }
 __setup("ihash_entries=", set_ihash_entries);
 
+static void *get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	int i;
+
+	spin_lock(&inode_lock);
+	for (i = 0; i < nr; i++) {
+		struct inode *inode = v[i];
+
+		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE))
+			v[i] = NULL;
+		else
+			__iget(inode);
+	}
+	spin_unlock(&inode_lock);
+	return NULL;
+}
+
+/*
+ * Function for filesystems that embedd struct inode into their own
+ * structures. The offset is the offset of the struct inode in the fs inode.
+ */
+void *fs_get_inodes(struct kmem_cache *s, int nr, void **v, unsigned long offset)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		v[i] += offset;
+
+	return get_inodes(s, nr, v);
+}
+EXPORT_SYMBOL(fs_get_inodes);
+
+void kick_inodes(struct kmem_cache *s, int nr, void **v, void *private)
+{
+	struct inode *inode;
+	int i;
+	int abort = 0;
+	LIST_HEAD(freeable);
+	struct super_block *sb;
+
+	for (i = 0; i < nr; i++) {
+		inode = v[i];
+		if (!inode)
+			continue;
+
+		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+			if (remove_inode_buffers(inode))
+				invalidate_mapping_pages(&inode->i_data,
+								0, -1);
+		}
+
+		if (inode->i_state & I_DIRTY)
+			write_inode_now(inode, 1);
+
+		if (atomic_read(&inode->i_count) > 1)
+			d_prune_aliases(inode);
+	}
+
+	mutex_lock(&iprune_mutex);
+	for (i = 0; i < nr; i++) {
+		inode = v[i];
+		if (!inode)
+			continue;
+
+		sb = inode->i_sb;
+		iput(inode);
+		if (abort || !(sb->s_flags & MS_ACTIVE))
+			continue;
+
+		spin_lock(&inode_lock);
+		if (!can_unuse(inode)) {
+			abort = 1;
+			spin_unlock(&inode_lock);
+			continue;
+		}
+		list_move(&inode->i_list, &freeable);
+		inode->i_state |= I_FREEING;
+		inodes_stat.nr_unused--;
+		spin_unlock(&inode_lock);
+	}
+	dispose_list(&freeable);
+	mutex_unlock(&iprune_mutex);
+}
+EXPORT_SYMBOL(kick_inodes);
+
+static struct kmem_cache_ops inode_kmem_cache_ops = {
+	.get = get_inodes,
+	.kick = kick_inodes
+};
+
 /*
  * Initialize the waitqueues and inode hash table.
  */
@@ -1399,7 +1489,7 @@ void __init inode_init(unsigned long mem
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 					 SLAB_MEM_SPREAD),
 					 init_once,
-					 NULL);
+					 &inode_kmem_cache_ops);
 	register_shrinker(&icache_shrinker);
 
 	/* Hash may have been set up in inode_init_early */
Index: slub/include/linux/fs.h
===================================================================
--- slub.orig/include/linux/fs.h	2007-05-18 00:50:36.000000000 -0700
+++ slub/include/linux/fs.h	2007-05-18 00:54:33.000000000 -0700
@@ -1608,6 +1608,11 @@ static inline void insert_inode_hash(str
 	__insert_inode_hash(inode, inode->i_ino);
 }
 
+/* Helpers to realize inode defrag support in filesystems */
+extern void kick_inodes(struct kmem_cache *, int, void **, void *);
+extern void *fs_get_inodes(struct kmem_cache *, int nr, void **,
+						unsigned long offset);
+
 extern struct file * get_empty_filp(void);
 extern void file_move(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);

-- 
