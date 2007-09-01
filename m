From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 17/26] inodes: Support generic defragmentation
Date: Fri, 31 Aug 2007 18:41:24 -0700
Message-ID: <20070901014223.225007714@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0017-slab_defrag_generic_inode_defrag.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

This implements the ability to remove inodes in a particular slab
from inode cache. In order to remove an inode we may have to write out
the pages of an inode, the inode itself and remove the dentries referring
to the node.

Provide generic functionality that can be used by filesystems that have
their own inode caches to also tie into the defragmentation functions
that are made available here.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/inode.c         |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    5 ++
 2 files changed, 100 insertions(+)

Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2007-08-28 19:48:07.000000000 -0700
+++ linux-2.6/fs/inode.c	2007-08-28 20:15:26.000000000 -0700
@@ -1351,6 +1351,100 @@ static int __init set_ihash_entries(char
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
 /*
  * Initialize the waitqueues and inode hash table.
  */
@@ -1390,6 +1484,7 @@ void __init inode_init(unsigned long mem
 					 SLAB_MEM_SPREAD),
 					 init_once);
 	register_shrinker(&icache_shrinker);
+	kmem_cache_setup_defrag(inode_cachep, get_inodes, kick_inodes);
 
 	/* Hash may have been set up in inode_init_early */
 	if (!hashdist)
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2007-08-28 19:48:07.000000000 -0700
+++ linux-2.6/include/linux/fs.h	2007-08-28 20:15:26.000000000 -0700
@@ -1644,6 +1644,11 @@ static inline void insert_inode_hash(str
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
