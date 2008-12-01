Date: Mon, 1 Dec 2008 09:33:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081201083343.GC2529@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

Hi,
Comments?
Thanks,
Nick

--
struct dentry is one of the most critical structures in the kernel. So it's
sad to see it going neglected.

With CONFIG_PROFILING turned on (which is probably the common case at least
for distros and kernel developers), sizeof(struct dcache) == 208 here
(64-bit). This gives 19 objects per slab.

I packed d_mounted into a hole, and took another 4 bytes off the inline
name length to take the padding out from the end of the structure. This
shinks it to 200 bytes. I could have gone the other way and increased the
length to 40, but I'm aiming for a magic number, read on...

I then got rid of the d_cookie pointer. This shrinks it to 192 bytes. Rant:
why was this ever a good idea? The cookie system should increase its hash
size or use a tree or something if lookups are a problem. Also the "fast
dcookie lookups" in oprofile should be moved into the dcookie code -- how
can oprofile possibly care about the dcookie_mutex? It gets dropped after
get_dcookie() returns so it can't be providing any sort of protection.

At 192 bytes, 21 objects fit into a 4K page, saving about 3MB on my system
with ~140 000 entries allocated. 192 is also a multiple of 64, so we get
nice cacheline alignment on 64 and 32 byte line systems -- any given dentry
will now require 3 cachelines to touch all fields wheras previously it
would require 4.

I know the inline name size was chosen quite carefully, however with the
reduction in cacheline footprint, it should actually be just about as fast
to do a name lookup for a 36 character name as it was before the patch (and
faster for other sizes). The memory footprint savings for names which are
<= 32 or > 36 bytes long should more than make up for the memory cost for
33-36 byte names.

Performance is a feature...
---
 arch/powerpc/oprofile/cell/spu_task_sync.c |    2 +-
 drivers/oprofile/buffer_sync.c             |    2 +-
 fs/dcache.c                                |    4 ----
 fs/dcookies.c                              |   28 +++++++++++++++++++---------
 include/linux/dcache.h                     |   21 ++++++++++++++-------
 5 files changed, 35 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/dcache.h
===================================================================
--- linux-2.6.orig/include/linux/dcache.h
+++ linux-2.6/include/linux/dcache.h
@@ -75,14 +75,22 @@ full_name_hash(const unsigned char *name
 	return end_name_hash(hash);
 }
 
-struct dcookie_struct;
-
-#define DNAME_INLINE_LEN_MIN 36
+/*
+ * Try to keep struct dentry aligned on 64 byte cachelines (this will
+ * give reasonable cacheline footprint with larger lines without the
+ * large memory footprint increase).
+ */
+#ifdef CONFIG_64BIT
+#define DNAME_INLINE_LEN_MIN 32 /* 192 bytes */
+#else
+#define DNAME_INLINE_LEN_MIN 40 /* 128 bytes */
+#endif
 
 struct dentry {
 	atomic_t d_count;
 	unsigned int d_flags;		/* protected by d_lock */
 	spinlock_t d_lock;		/* per dentry lock */
+	int d_mounted;
 	struct inode *d_inode;		/* Where the name belongs to - NULL is
 					 * negative */
 	/*
@@ -107,10 +115,7 @@ struct dentry {
 	struct dentry_operations *d_op;
 	struct super_block *d_sb;	/* The root of the dentry tree */
 	void *d_fsdata;			/* fs-specific data */
-#ifdef CONFIG_PROFILING
-	struct dcookie_struct *d_cookie; /* cookie, if any */
-#endif
-	int d_mounted;
+
 	unsigned char d_iname[DNAME_INLINE_LEN_MIN];	/* small names */
 };
 
@@ -177,6 +182,8 @@ d_iput:		no		no		no       yes
 
 #define DCACHE_INOTIFY_PARENT_WATCHED	0x0020 /* Parent inode is watched */
 
+#define DCACHE_COOKIE		0x0040	/* For use by dcookie subsystem */
+
 extern spinlock_t dcache_lock;
 extern seqlock_t rename_lock;
 
Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c
+++ linux-2.6/fs/dcache.c
@@ -34,7 +34,6 @@
 #include <linux/bootmem.h>
 #include "internal.h"
 
-
 int sysctl_vfs_cache_pressure __read_mostly = 100;
 EXPORT_SYMBOL_GPL(sysctl_vfs_cache_pressure);
 
@@ -948,9 +947,6 @@ struct dentry *d_alloc(struct dentry * p
 	dentry->d_op = NULL;
 	dentry->d_fsdata = NULL;
 	dentry->d_mounted = 0;
-#ifdef CONFIG_PROFILING
-	dentry->d_cookie = NULL;
-#endif
 	INIT_HLIST_NODE(&dentry->d_hash);
 	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
Index: linux-2.6/fs/dcookies.c
===================================================================
--- linux-2.6.orig/fs/dcookies.c
+++ linux-2.6/fs/dcookies.c
@@ -93,10 +93,15 @@ static struct dcookie_struct *alloc_dcoo
 {
 	struct dcookie_struct *dcs = kmem_cache_alloc(dcookie_cache,
 							GFP_KERNEL);
+	struct dentry *d;
 	if (!dcs)
 		return NULL;
 
-	path->dentry->d_cookie = dcs;
+	d = path->dentry;
+	spin_lock(&d->d_lock);
+	d->d_flags |= DCACHE_COOKIE;
+	spin_unlock(&d->d_lock);
+
 	dcs->path = *path;
 	path_get(path);
 	hash_dcookie(dcs);
@@ -119,14 +124,14 @@ int get_dcookie(struct path *path, unsig
 		goto out;
 	}
 
-	dcs = path->dentry->d_cookie;
-
-	if (!dcs)
+	if (path->dentry->d_flags & DCACHE_COOKIE) {
+		dcs = find_dcookie((unsigned long)path->dentry);
+	} else {
 		dcs = alloc_dcookie(path);
-
-	if (!dcs) {
-		err = -ENOMEM;
-		goto out;
+		if (!dcs) {
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 
 	*cookie = dcookie_value(dcs);
@@ -251,7 +256,12 @@ out_kmem:
 
 static void free_dcookie(struct dcookie_struct * dcs)
 {
-	dcs->path.dentry->d_cookie = NULL;
+	struct dentry *d = dcs->path.dentry;
+
+	spin_lock(&d->d_lock);
+	d->d_flags &= ~DCACHE_COOKIE;
+	spin_unlock(&d->d_lock);
+
 	path_put(&dcs->path);
 	kmem_cache_free(dcookie_cache, dcs);
 }
Index: linux-2.6/drivers/oprofile/buffer_sync.c
===================================================================
--- linux-2.6.orig/drivers/oprofile/buffer_sync.c
+++ linux-2.6/drivers/oprofile/buffer_sync.c
@@ -200,7 +200,7 @@ static inline unsigned long fast_get_dco
 {
 	unsigned long cookie;
 
-	if (path->dentry->d_cookie)
+	if (path->dentry->d_flags & DCACHE_COOKIE)
 		return (unsigned long)path->dentry;
 	get_dcookie(path, &cookie);
 	return cookie;
Index: linux-2.6/arch/powerpc/oprofile/cell/spu_task_sync.c
===================================================================
--- linux-2.6.orig/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ linux-2.6/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -297,7 +297,7 @@ static inline unsigned long fast_get_dco
 {
 	unsigned long cookie;
 
-	if (path->dentry->d_cookie)
+	if (path->dentry->d_flags & DCACHE_COOKIE)
 		return (unsigned long)path->dentry;
 	get_dcookie(path, &cookie);
 	return cookie;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
