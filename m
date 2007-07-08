From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 08/12] Slab defragmentation: Support generic defragmentation for inode slab caches
Date: Sat, 07 Jul 2007 20:05:46 -0700
Message-ID: <20070708030845.265903427@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756829AbXGHDLB@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_inode_generic
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

This implements the ability to remove inodes in a particular slab
from the inode cache. In order to remove an inode we may have to write out
the pages of an inode, the inode itself and remove the dentries referring
to the node.

Provide generic functionality that can be used by filesystems that have
their own inode caches to also tie into the defragmentation functions
that are made available here.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/inode.c         |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    5 ++
 2 files changed, 105 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc6-mm1/fs/inode.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/fs/inode.c	2007-07-03 17:19:26.000000000 -0700
+++ linux-2.6.22-rc6-mm1/fs/inode.c	2007-07-03 17:28:46.000000000 -0700
@@ -1351,6 +1351,105 @@ static int __init set_ihash_entries(char
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
+void *fs_get_inodes(struct kmem_cache *s, int nr, void **v,
+						unsigned long offset)
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
+		/* Invalidate children and dentry */
+		if (S_ISDIR(inode->i_mode)) {
+			struct dentry *d = d_find_alias(inode);
+
+			if (d) {
+				d_invalidate(d);
+				dput(d);
+			}
+		}
+
+		if (inode->i_state & I_DIRTY)
+			write_inode_now(inode, 1);
+
+		d_prune_aliases(inode);
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
+		abort =  !can_unuse(inode);
+
+		if (!abort) {
+			list_move(&inode->i_list, &freeable);
+			inode->i_state |= I_FREEING;
+			inodes_stat.nr_unused--;
+		}
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
@@ -1389,7 +1488,7 @@ void __init inode_init(unsigned long mem
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 					 SLAB_MEM_SPREAD),
 					 init_once,
-					 NULL);
+					 &inode_kmem_cache_ops);
 	register_shrinker(&icache_shrinker);
 
 	/* Hash may have been set up in inode_init_early */
Index: linux-2.6.22-rc6-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/fs.h	2007-07-03 17:19:27.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/fs.h	2007-07-03 17:28:46.000000000 -0700
@@ -1769,6 +1769,11 @@ static inline void insert_inode_hash(str
 	__insert_inode_hash(inode, inode->i_ino);
 }
 
+/* Helper functions for inode defragmentation support in filesystems */
+extern void kick_inodes(struct kmem_cache *, int, void **, void *);
+extern void *fs_get_inodes(struct kmem_cache *, int nr, void **,
+						unsigned long offset);
+
 extern struct file * get_empty_filp(void);
 extern void file_move(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);

-- 
