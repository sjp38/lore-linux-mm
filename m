Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3C906B0062
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:38:31 -0500 (EST)
MIME-Version: 1.0
Message-ID: <dee07055-5763-4e91-b6a2-964bbc8217aa@default>
Date: Thu, 17 Dec 2009 16:37:55 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Tmem [PATCH 2/5] (Take 3): Implement cleancache on top of tmem layer
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 2/5] (Take 3): Implement cleancache on top of tmem layer.

Hooks added to existing page cache, VFS, and FS (ext3, ocfs2, btrfs,
and ext4 supported as of now) routines to:
1) create a tmem pool when filesystem is mounted and record its id
2) "put" clean pages that are being evicted
3) attempt to "get" pages prior to reading from a mounted FS and
   fallback to reading from the FS if "get" fails
4) "flush" as necessary to ensure coherency btwn page cache & cleancache
5) destroy the tmem pool when the FS is unmounted

Hooks for page cache and VFS placed by Chris Mason

The term "cleancache" is used because only clean data
can be cached using this interface.  The previous term
("precache") was deemed too generic and overloaded.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


 fs/btrfs/extent_io.c                     |    9 +
 fs/btrfs/super.c                         |    2=20
 fs/buffer.c                              |    5=20
 fs/ext3/super.c                          |    2=20
 fs/ext4/super.c                          |    2=20
 fs/mpage.c                               |    8=20
 fs/ocfs2/super.c                         |    2=20
 fs/super.c                               |    6=20
 include/linux/cleancache.h               |   55 ++++++
 include/linux/fs.h                       |    7=20
 mm/cleancache.c                          |  184 +++++++++++++++++++++
 mm/filemap.c                             |   11 +
 mm/truncate.c                            |   10 +
 13 files changed, 303 insertions(+)

--- linux-2.6.32/fs/super.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/super.c=092009-12-17 13:51:04.000000000 -0700
@@ -37,6 +37,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/cleancache.h>
 #include <asm/uaccess.h>
 #include "internal.h"
=20
@@ -104,6 +105,9 @@ static struct super_block *alloc_super(s
 =09=09s->s_qcop =3D sb_quotactl_ops;
 =09=09s->s_op =3D &default_op;
 =09=09s->s_time_gran =3D 1000000000;
+#ifdef CONFIG_CLEANCACHE
+=09=09s->cleancache_poolid =3D -1;
+#endif
 =09}
 out:
 =09return s;
@@ -194,6 +198,7 @@ void deactivate_super(struct super_block
 =09=09vfs_dq_off(s, 0);
 =09=09down_write(&s->s_umount);
 =09=09fs->kill_sb(s);
+=09=09cleancache_flush_filesystem(s);
 =09=09put_filesystem(fs);
 =09=09put_super(s);
 =09}
@@ -220,6 +225,7 @@ void deactivate_locked_super(struct supe
 =09=09spin_unlock(&sb_lock);
 =09=09vfs_dq_off(s, 0);
 =09=09fs->kill_sb(s);
+=09=09cleancache_flush_filesystem(s);
 =09=09put_filesystem(fs);
 =09=09put_super(s);
 =09} else {
--- linux-2.6.32/fs/ext3/super.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/ext3/super.c=092009-12-17 13:51:24.000000000 -0700
@@ -37,6 +37,7 @@
 #include <linux/quotaops.h>
 #include <linux/seq_file.h>
 #include <linux/log2.h>
+#include <linux/cleancache.h>
=20
 #include <asm/uaccess.h>
=20
@@ -1307,6 +1308,7 @@ static int ext3_setup_super(struct super
 =09} else {
 =09=09printk("internal journal\n");
 =09}
+=09cleancache_init(sb);
 =09return res;
 }
=20
--- linux-2.6.32/include/linux/fs.h=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/include/linux/fs.h=092009-12-17 15:29:35.000000000 -0=
700
@@ -1380,6 +1380,13 @@ struct super_block {
 =09 * generic_show_options()
 =09 */
 =09char *s_options;
+
+#ifdef CONFIG_CLEANCACHE
+=09/*
+=09 * Saved pool identifier for cleancache (-1 means none)
+=09 */
+=09u32 cleancache_poolid;
+#endif
 };
=20
 extern struct timespec current_fs_time(struct super_block *sb);
--- linux-2.6.32/fs/buffer.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/buffer.c=092009-12-17 13:50:32.000000000 -0700
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/cleancache.h>
=20
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
=20
@@ -276,6 +277,10 @@ void invalidate_bdev(struct block_device
=20
 =09invalidate_bh_lrus();
 =09invalidate_mapping_pages(mapping, 0, -1);
+=09/* 99% of the time, we don't need to flush the cleancache on the bdev.
+=09 * But, for the strange corners, lets be cautious
+=09 */
+=09cleancache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(invalidate_bdev);
=20
--- linux-2.6.32/fs/mpage.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/mpage.c=092009-12-17 13:50:37.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/cleancache.h>
=20
 /*
  * I/O completion handler for multipage BIOs.
@@ -285,6 +286,13 @@ do_mpage_readpage(struct bio *bio, struc
 =09=09SetPageMappedToDisk(page);
 =09}
=20
+=09if (fully_mapped &&
+=09    blocks_per_page =3D=3D 1 && !PageUptodate(page) &&
+=09    cleancache_get(page->mapping, page->index, page) =3D=3D 1) {
+=09=09SetPageUptodate(page);
+=09=09goto confused;
+=09}
+
 =09/*
 =09 * This page will go to BIO.  Do we need to send this BIO off first?
 =09 */
--- linux-2.6.32/fs/btrfs/super.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/btrfs/super.c=092009-12-17 13:50:16.000000000 -070=
0
@@ -38,6 +38,7 @@
 #include <linux/namei.h>
 #include <linux/miscdevice.h>
 #include <linux/magic.h>
+#include <linux/cleancache.h>
 #include "compat.h"
 #include "ctree.h"
 #include "disk-io.h"
@@ -387,6 +388,7 @@ static int btrfs_fill_super(struct super
 =09sb->s_root =3D root_dentry;
=20
 =09save_mount_options(sb, data);
+=09cleancache_init(sb);
 =09return 0;
=20
 fail_close:
--- linux-2.6.32/fs/btrfs/extent_io.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/btrfs/extent_io.c=092009-12-17 15:28:33.000000000 =
-0700
@@ -11,6 +11,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
+#include <linux/cleancache.h>
 #include "extent_io.h"
 #include "extent_map.h"
 #include "compat.h"
@@ -2015,6 +2016,13 @@ static int __extent_read_full_page(struc
=20
 =09set_page_extent_mapped(page);
=20
+=09if (!PageUptodate(page)) {
+=09=09if (cleancache_get(page->mapping, page->index, page) =3D=3D 1) {
+=09=09=09BUG_ON(blocksize !=3D PAGE_SIZE);
+=09=09=09goto out;
+=09=09}
+=09}
+
 =09end =3D page_end;
 =09lock_extent(tree, start, end, GFP_NOFS);
=20
@@ -2131,6 +2139,7 @@ static int __extent_read_full_page(struc
 =09=09cur =3D cur + iosize;
 =09=09page_offset +=3D iosize;
 =09}
+out:
 =09if (!nr) {
 =09=09if (!PageError(page))
 =09=09=09SetPageUptodate(page);
--- linux-2.6.32/fs/ocfs2/super.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/ocfs2/super.c=092009-12-17 13:51:11.000000000 -070=
0
@@ -42,6 +42,7 @@
 #include <linux/seq_file.h>
 #include <linux/quotaops.h>
 #include <linux/smp_lock.h>
+#include <linux/cleancache.h>
=20
 #define MLOG_MASK_PREFIX ML_SUPER
 #include <cluster/masklog.h>
@@ -2228,6 +2229,7 @@ static int ocfs2_initialize_super(struct
 =09=09mlog_errno(status);
 =09=09goto bail;
 =09}
+=09shared_cleancache_init(sb, &di->id2.i_super.s_uuid[0]);
=20
 bail:
 =09mlog_exit(status);
--- linux-2.6.32/fs/ext4/super.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/fs/ext4/super.c=092009-12-17 13:51:17.000000000 -0700
@@ -39,6 +39,7 @@
 #include <linux/ctype.h>
 #include <linux/log2.h>
 #include <linux/crc16.h>
+#include <linux/cleancache.h>
 #include <asm/uaccess.h>
=20
 #include "ext4.h"
@@ -1660,6 +1661,7 @@ static int ext4_setup_super(struct super
 =09=09=09EXT4_INODES_PER_GROUP(sb),
 =09=09=09sbi->s_mount_opt);
=20
+=09cleancache_init(sb);
 =09return res;
 }
=20
--- linux-2.6.32/mm/truncate.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/truncate.c=092009-12-17 13:56:31.000000000 -0700
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>=09/* grr. try_to_release_page,
 =09=09=09=09   do_invalidatepage */
+#include <linux/cleancache.h>
 #include "internal.h"
=20
=20
@@ -50,6 +51,7 @@ void do_invalidatepage(struct page *page
 static inline void truncate_partial_page(struct page *page, unsigned parti=
al)
 {
 =09zero_user_segment(page, partial, PAGE_CACHE_SIZE);
+=09cleancache_flush(page->mapping, page->index);
 =09if (page_has_private(page))
 =09=09do_invalidatepage(page, partial);
 }
@@ -107,6 +109,10 @@ truncate_complete_page(struct address_sp
 =09clear_page_mlock(page);
 =09remove_from_page_cache(page);
 =09ClearPageMappedToDisk(page);
+=09/* this must be after the remove_from_page_cache which
+=09 * calls cleancache_put
+=09 */
+=09cleancache_flush(mapping, page->index);
 =09page_cache_release(page);=09/* pagecache ref */
 =09return 0;
 }
@@ -214,6 +220,7 @@ void truncate_inode_pages_range(struct a
 =09pgoff_t next;
 =09int i;
=20
+=09cleancache_flush_inode(mapping);
 =09if (mapping->nrpages =3D=3D 0)
 =09=09return;
=20
@@ -287,6 +294,7 @@ void truncate_inode_pages_range(struct a
 =09=09}
 =09=09pagevec_release(&pvec);
 =09}
+=09cleancache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
=20
@@ -423,6 +431,7 @@ int invalidate_inode_pages2_range(struct
 =09int did_range_unmap =3D 0;
 =09int wrapped =3D 0;
=20
+=09cleancache_flush_inode(mapping);
 =09pagevec_init(&pvec, 0);
 =09next =3D start;
 =09while (next <=3D end && !wrapped &&
@@ -479,6 +488,7 @@ int invalidate_inode_pages2_range(struct
 =09=09pagevec_release(&pvec);
 =09=09cond_resched();
 =09}
+=09cleancache_flush_inode(mapping);
 =09return ret;
 }
 EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);
--- linux-2.6.32/mm/filemap.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/filemap.c=092009-12-17 13:56:55.000000000 -0700
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/cleancache.h>
 #include "internal.h"
=20
 /*
@@ -119,6 +120,16 @@ void __remove_from_page_cache(struct pag
 {
 =09struct address_space *mapping =3D page->mapping;
=20
+=09/*
+=09 * if we're uptodate, flush out into the cleancache, otherwise
+=09 * invalidate any existing cleancache entries.  We can't leave
+=09 * stale data around in the cleancache once our page is gone
+=09 */
+=09if (PageUptodate(page))
+=09=09cleancache_put(page->mapping, page->index, page);
+=09else
+=09=09cleancache_flush(page->mapping, page->index);
+
 =09radix_tree_delete(&mapping->page_tree, page->index);
 =09page->mapping =3D NULL;
 =09mapping->nrpages--;
--- linux-2.6.32/include/linux/cleancache.h=091969-12-31 17:00:00.000000000=
 -0700
+++ linux-2.6.32-tmem/include/linux/cleancache.h=092009-12-17 13:41:04.0000=
00000 -0700
@@ -0,0 +1,55 @@
+#ifndef _LINUX_CLEANCACHE_H
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#ifdef CONFIG_CLEANCACHE
+extern void cleancache_init(struct super_block *sb);
+extern void shared_cleancache_init(struct super_block *sb, char *uuid);
+extern int cleancache_get(struct address_space *mapping, unsigned long ind=
ex,
+=09       struct page *empty_page);
+extern int cleancache_put(struct address_space *mapping, unsigned long ind=
ex,
+=09=09struct page *page);
+extern int cleancache_flush(struct address_space *mapping, unsigned long i=
ndex);
+extern int cleancache_flush_inode(struct address_space *mapping);
+extern int cleancache_flush_filesystem(struct super_block *s);
+#else
+static inline void cleancache_init(struct super_block *sb)
+{
+}
+
+static inline void shared_cleancache_init(struct super_block *sb, char *uu=
id)
+{
+}
+
+static inline int cleancache_get(struct address_space *mapping,
+=09=09unsigned long index, struct page *empty_page)
+{
+=09return 0;
+}
+
+static inline int cleancache_put(struct address_space *mapping,
+=09=09unsigned long index, struct page *page)
+{
+=09return 0;
+}
+
+static inline int cleancache_flush(struct address_space *mapping,
+=09=09unsigned long index)
+{
+=09return 0;
+}
+
+static inline int cleancache_flush_inode(struct address_space *mapping)
+{
+=09return 0;
+}
+
+static inline int cleancache_flush_filesystem(struct super_block *s)
+{
+=09return 0;
+}
+#endif
+
+#define _LINUX_CLEANCACHE_H
+#endif /* _LINUX_CLEANCACHE_H */
--- linux-2.6.32/mm/cleancache.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32-tmem/mm/cleancache.c=092009-12-17 15:30:59.000000000 -0700
@@ -0,0 +1,184 @@
+/*
+ * linux/mm/cleancache.c
+ *
+ * Implements a page-granularity clean cache for filesystems/pagecache on =
the
+ * transcendent * memory ("tmem") API.  A filesystem creates an "ephemeral
+ * tmem pool" and retains the returned pool_id in its superblock.  Clean p=
ages
+ * evicted from pagecache may be "put" into the pool and associated with a
+ * "handle" consisting of the pool_id, an object (inode) id, and an index =
(page
+ * offset).  Note that the page is copied to tmem; no kernel mappings are
+ * changed. If the page is later needed, the filesystem (or VFS) issues a =
"get",
+ * passing the same handle and an empty pageframe.  If successful, the pag=
e is
+ * copied into the pageframe and a disk read is avoided.  But since the tm=
em
+ * pool is of indeterminate size, a "put" page has indeterminate longevity
+ * ("ephemeral"), and the "get" may fail, in which case the filesystem mus=
t
+ * read the page from disk as before.  Note that the filesystem/pagecache =
are
+ * responsible for maintaining coherency between the pagecache, tmem's cle=
an
+ * cache and the disk, for which "flush page" and "flush object" actions
+ * are provided.  And when a filesystem is unmounted, it must "destroy"
+ * the pool.
+ *
+ * Tmem supports two different modes for a cleancache: "private" or "share=
d".
+ * Shared pools are still under development. For a private pool, a success=
ful
+ * "get" always flushes, implementing "exclusive cache" semantics.  Note
+ * that a failed "duplicate" put (overwrite) always guarantees the old dat=
a
+ * is flushed.
+ *
+ * Note also that multiple accesses to a tmem pool may be concurrent and a=
ny
+ * ordering must be guaranteed by the caller.
+ *
+ * Copyright (C) 2008,2009 Dan Magenheimer, Oracle Corp.
+ */
+
+#include <linux/cleancache.h>
+#include <linux/module.h>
+#include <linux/tmem.h>
+
+static int cleancache_auto_allocate; /* set to 1 to auto_allocate */
+static unsigned long cleancache_puts;
+static unsigned long cleancache_succ_gets;
+static unsigned long cleancache_failed_gets;
+
+int cleancache_put(struct address_space *mapping, unsigned long index,
+ struct page *page)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->cleancache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+=09u32 ind =3D (u32) index;
+=09unsigned long pfn =3D page_to_pfn(page);
+=09struct tmem_pool_uuid uuid_private =3D TMEM_POOL_PRIVATE_UUID;
+=09int ret;
+
+=09if ((s32)tmem_pool < 0) {
+=09=09if (!cleancache_auto_allocate)
+=09=09=09return 0;
+=09=09/* a put on a non-existent cleancache may auto-allocate one */
+=09=09ret =3D tmem_new_pool(uuid_private, 0);
+=09=09if (ret < 0)
+=09=09=09return 0;
+=09=09printk(KERN_INFO
+=09=09=09"Mapping superblock for s_id=3D%s to cleancache_id=3D%d\n",
+=09=09=09mapping->host->i_sb->s_id, tmem_pool);
+=09=09mapping->host->i_sb->cleancache_poolid =3D tmem_pool;
+=09}
+=09if (ind !=3D index)
+=09=09return 0;
+=09mb(); /* ensure page is quiescent; tmem may address it with an alias */
+=09cleancache_puts++;
+=09return tmem_put_page(tmem_pool, obj, ind, pfn);
+}
+
+int cleancache_get(struct address_space *mapping, unsigned long index,
+ struct page *empty_page)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->cleancache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+=09u32 ind =3D (u32) index;
+=09unsigned long pfn =3D page_to_pfn(empty_page);
+=09int ret;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+=09if (ind !=3D index)
+=09=09return 0;
+
+=09ret =3D tmem_get_page(tmem_pool, obj, ind, pfn);
+=09if (ret =3D=3D 1)
+=09=09cleancache_succ_gets++;
+=09else
+=09=09cleancache_failed_gets++;
+=09return ret;
+}
+EXPORT_SYMBOL(cleancache_get);
+
+int cleancache_flush(struct address_space *mapping, unsigned long index)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->cleancache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+=09u32 ind =3D (u32) index;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+=09if (ind !=3D index)
+=09=09return 0;
+
+=09return tmem_flush_page(tmem_pool, obj, ind);
+}
+EXPORT_SYMBOL(cleancache_flush);
+
+int cleancache_flush_inode(struct address_space *mapping)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->cleancache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+
+=09return tmem_flush_object(tmem_pool, obj);
+}
+EXPORT_SYMBOL(cleancache_flush_inode);
+
+int cleancache_flush_filesystem(struct super_block *sb)
+{
+=09u32 tmem_pool =3D sb->cleancache_poolid;
+=09int ret;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+=09ret =3D tmem_destroy_pool(tmem_pool);
+=09if (!ret)
+=09=09return 0;
+=09printk(KERN_INFO
+=09=09"Unmapping superblock for s_id=3D%s from cleancache_id=3D%d\n",
+=09=09sb->s_id, ret);
+=09sb->cleancache_poolid =3D 0;
+=09return 1;
+}
+EXPORT_SYMBOL(cleancache_flush_filesystem);
+
+void cleancache_init(struct super_block *sb)
+{
+=09struct tmem_pool_uuid uuid_private =3D TMEM_POOL_PRIVATE_UUID;
+
+=09sb->cleancache_poolid =3D tmem_new_pool(uuid_private, 0);
+}
+EXPORT_SYMBOL(cleancache_init);
+
+void shared_cleancache_init(struct super_block *sb, char *uuid)
+{
+=09struct tmem_pool_uuid shared_uuid;
+
+=09shared_uuid.uuid_lo =3D *(u64 *)uuid;
+=09shared_uuid.uuid_hi =3D *(u64 *)(&uuid[8]);
+=09sb->cleancache_poolid =3D tmem_new_pool(shared_uuid, TMEM_POOL_SHARED);
+}
+EXPORT_SYMBOL(shared_cleancache_init);
+
+#ifdef CONFIG_SYSCTL
+#include <linux/sysctl.h>
+
+ctl_table cleancache_table[] =3D {
+=09{
+=09=09.procname=09=3D "puts",
+=09=09.data=09=09=3D &cleancache_puts,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{
+=09=09.procname=09=3D "succ_gets",
+=09=09.data=09=09=3D &cleancache_succ_gets,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{
+=09=09.procname=09=3D "failed_gets",
+=09=09.data=09=09=3D &cleancache_failed_gets,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{ .ctl_name =3D 0 }
+};
+#endif /* CONFIG_SYSCTL */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
