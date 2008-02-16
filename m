Message-Id: <20080216004633.988315225@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:36 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/17] inodes: Support generic defragmentation
Content-Disposition: inline; filename=0055-inodes-Support-generic-defragmentation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

This implements the ability to remove inodes in a particular slab
from inode caches. In order to remove an inode we may have to write out
the pages of an inode, the inode itself and remove the dentries referring
to the node.

Provide generic functionality that can be used by filesystems that have
their own inode caches to also tie into the defragmentation functions
that are made available here.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/inode.c         |   96 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    6 +++
 2 files changed, 102 insertions(+)

Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2008-02-14 15:19:12.457507589 -0800
+++ linux-2.6/fs/inode.c	2008-02-15 15:49:22.309268623 -0800
@@ -1370,6 +1370,101 @@ static int __init set_ihash_entries(char
 }
 __setup("ihash_entries=", set_ihash_entries);
 
+void *get_inodes(struct kmem_cache *s, int nr, void **v)
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
+EXPORT_SYMBOL(get_inodes);
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
 /*
  * Initialize the waitqueues and inode hash table.
  */
@@ -1409,6 +1504,7 @@ void __init inode_init(void)
 					 SLAB_MEM_SPREAD),
 					 init_once);
 	register_shrinker(&icache_shrinker);
+	kmem_cache_setup_defrag(inode_cachep, get_inodes, kick_inodes);
 
 	/* Hash may have been set up in inode_init_early */
 	if (!hashdist)
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2008-02-15 10:48:35.463846699 -0800
+++ linux-2.6/include/linux/fs.h	2008-02-15 15:49:22.309268623 -0800
@@ -1787,6 +1787,12 @@ static inline void insert_inode_hash(str
 	__insert_inode_hash(inode, inode->i_ino);
 }
 
+/* Helper functions for inode defragmentation support in filesystems */
+extern void kick_inodes(struct kmem_cache *, int, void **, void *);
+extern void *get_inodes(struct kmem_cache *, int nr, void **);
+extern void *fs_get_inodes(struct kmem_cache *, int nr, void **,
+						unsigned long offset);
+
 extern struct file * get_empty_filp(void);
 extern void file_move(struct file *f, struct list_head *list);
 extern void file_kill(struct file *f);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
