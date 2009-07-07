Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD6546B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:17:34 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8fac37f5-450b-439e-a597-99ae02e3056d@default>
Date: Tue, 7 Jul 2009 09:18:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 2/4] (Take 2): tmem: Implement precache on top of tmem
 layer
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 2/4] (Take 2): Implement precache on top of tmem layer

Hooks added to existing page cache, VFS, and FS (ext3 only for now)
routines to:
1) create a tmem pool when filesystem is mounted and record its id
2) "put" clean pages that are being evicted
3) attempt to "get" pages prior to reading from a mounted FS and
   fallback to reading from the FS if "get" fails
4) "flush" as necessary to ensure coherency btwn page cache & precache
5) destroy the tmem pool when the FS is unmounted

Hooks for page cache and VFS placed by Chris Mason

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


 fs/buffer.c                              |    5=20
 fs/ext3/super.c                          |    2=20
 fs/mpage.c                               |    8 +
 fs/super.c                               |    5=20
 include/linux/fs.h                       |    7 +
 include/linux/precache.h                 |   50 +++++++
 mm/Kconfig                               |    8 +
 mm/Makefile                              |    1=20
 mm/filemap.c                             |   11 +
 mm/precache.c                            |  134 +++++++++++++++++++++
 mm/truncate.c                            |   10 +
 11 files changed, 241 insertions(+)

--- linux-2.6.30/fs/super.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/fs/super.c=092009-06-19 09:33:59.000000000 -0600
@@ -39,6 +39,7 @@
 #include <linux/mutex.h>
 #include <linux/file.h>
 #include <linux/async.h>
+#include <linux/precache.h>
 #include <asm/uaccess.h>
 #include "internal.h"
=20
@@ -110,6 +111,9 @@ static struct super_block *alloc_super(s
 =09=09s->s_qcop =3D sb_quotactl_ops;
 =09=09s->s_op =3D &default_op;
 =09=09s->s_time_gran =3D 1000000000;
+#ifdef CONFIG_PRECACHE
+=09=09s->precache_poolid =3D -1;
+#endif
 =09}
 out:
 =09return s;
@@ -200,6 +204,7 @@ void deactivate_super(struct super_block
 =09=09vfs_dq_off(s, 0);
 =09=09down_write(&s->s_umount);
 =09=09fs->kill_sb(s);
+=09=09precache_flush_filesystem(s);
 =09=09put_filesystem(fs);
 =09=09put_super(s);
 =09}
--- linux-2.6.30/fs/ext3/super.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/fs/ext3/super.c=092009-06-19 09:33:59.000000000 -0600
@@ -37,6 +37,7 @@
 #include <linux/quotaops.h>
 #include <linux/seq_file.h>
 #include <linux/log2.h>
+#include <linux/precache.h>
=20
 #include <asm/uaccess.h>
=20
@@ -1306,6 +1307,7 @@ static int ext3_setup_super(struct super
 =09} else {
 =09=09printk("internal journal\n");
 =09}
+=09precache_init(sb);
 =09return res;
 }
=20
--- linux-2.6.30/include/linux/fs.h=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/include/linux/fs.h=092009-06-19 09:33:59.000000000 -0=
600
@@ -1377,6 +1377,13 @@ struct super_block {
 =09 * storage for asynchronous operations
 =09 */
 =09struct list_head s_async_list;
+
+#ifdef CONFIG_PRECACHE
+=09/*
+=09 * saved pool identifier for precache (-1 means none)
+=09 */
+=09u32 precache_poolid;
+#endif
 };
=20
 extern struct timespec current_fs_time(struct super_block *sb);
--- linux-2.6.30/fs/buffer.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/fs/buffer.c=092009-06-19 09:33:59.000000000 -0600
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/precache.h>
=20
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
=20
@@ -271,6 +272,10 @@ void invalidate_bdev(struct block_device
=20
 =09invalidate_bh_lrus();
 =09invalidate_mapping_pages(mapping, 0, -1);
+=09/* 99% of the time, we don't need to flush the precache on the bdev.
+=09 * But, for the strange corners, lets be cautious
+=09 */
+=09precache_flush_inode(mapping);
 }
=20
 /*
--- linux-2.6.30/fs/mpage.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/fs/mpage.c=092009-06-19 09:33:59.000000000 -0600
@@ -26,6 +26,7 @@
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/precache.h>
=20
 /*
  * I/O completion handler for multipage BIOs.
@@ -285,6 +286,13 @@ do_mpage_readpage(struct bio *bio, struc
 =09=09SetPageMappedToDisk(page);
 =09}
=20
+=09if (fully_mapped &&
+=09    blocks_per_page =3D=3D 1 && !PageUptodate(page) &&
+=09    precache_get(page->mapping, page->index, page) =3D=3D 1) {
+=09=09SetPageUptodate(page);
+=09=09goto confused;
+=09}
+
 =09/*
 =09 * This page will go to BIO.  Do we need to send this BIO off first?
 =09 */
--- linux-2.6.30/mm/truncate.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/truncate.c=092009-06-19 09:37:42.000000000 -0600
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>=09/* grr. try_to_release_page,
 =09=09=09=09   do_invalidatepage */
+#include <linux/precache.h>
 #include "internal.h"
=20
=20
@@ -50,6 +51,7 @@ void do_invalidatepage(struct page *page
 static inline void truncate_partial_page(struct page *page, unsigned parti=
al)
 {
 =09zero_user_segment(page, partial, PAGE_CACHE_SIZE);
+=09precache_flush(page->mapping, page->index);
 =09if (page_has_private(page))
 =09=09do_invalidatepage(page, partial);
 }
@@ -107,6 +109,10 @@ truncate_complete_page(struct address_sp
 =09clear_page_mlock(page);
 =09remove_from_page_cache(page);
 =09ClearPageMappedToDisk(page);
+=09/* this must be after the remove_from_page_cache which
+=09 * calls precache_put
+=09 */
+=09precache_flush(mapping, page->index);
 =09page_cache_release(page);=09/* pagecache ref */
 }
=20
@@ -168,6 +174,7 @@ void truncate_inode_pages_range(struct a
 =09pgoff_t next;
 =09int i;
=20
+=09precache_flush_inode(mapping);
 =09if (mapping->nrpages =3D=3D 0)
 =09=09return;
=20
@@ -251,6 +258,7 @@ void truncate_inode_pages_range(struct a
 =09=09}
 =09=09pagevec_release(&pvec);
 =09}
+=09precache_flush_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
=20
@@ -398,6 +406,7 @@ int invalidate_inode_pages2_range(struct
 =09int did_range_unmap =3D 0;
 =09int wrapped =3D 0;
=20
+=09precache_flush_inode(mapping);
 =09pagevec_init(&pvec, 0);
 =09next =3D start;
 =09while (next <=3D end && !wrapped &&
@@ -454,6 +463,7 @@ int invalidate_inode_pages2_range(struct
 =09=09pagevec_release(&pvec);
 =09=09cond_resched();
 =09}
+=09precache_flush_inode(mapping);
 =09return ret;
 }
 EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);
--- linux-2.6.30/mm/filemap.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/filemap.c=092009-06-19 09:33:59.000000000 -0600
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/precache.h>
 #include "internal.h"
=20
 /*
@@ -116,6 +117,16 @@ void __remove_from_page_cache(struct pag
 {
 =09struct address_space *mapping =3D page->mapping;
=20
+=09/*
+=09 * if we're uptodate, flush out into the precache, otherwise
+=09 * invalidate any existing precache entries.  We can't leave
+=09 * stale data around in the precache once our page is gone
+=09 */
+=09if (PageUptodate(page))
+=09=09precache_put(page->mapping, page->index, page);
+=09else
+=09=09precache_flush(page->mapping, page->index);
+
 =09radix_tree_delete(&mapping->page_tree, page->index);
 =09page->mapping =3D NULL;
 =09mapping->nrpages--;
--- linux-2.6.30/include/linux/precache.h=091969-12-31 17:00:00.000000000 -=
0700
+++ linux-2.6.30-tmem/include/linux/precache.h=092009-07-06 15:46:16.000000=
000 -0600
@@ -0,0 +1,50 @@
+#ifndef _LINUX_PRECACHE_H
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#ifdef CONFIG_PRECACHE
+extern void precache_init(struct super_block *sb);
+extern int precache_get(struct address_space *mapping, unsigned long index=
,
+=09       struct page *empty_page);
+extern int precache_put(struct address_space *mapping, unsigned long index=
,
+=09=09struct page *page);
+extern int precache_flush(struct address_space *mapping, unsigned long ind=
ex);
+extern int precache_flush_inode(struct address_space *mapping);
+extern int precache_flush_filesystem(struct super_block *s);
+#else
+static inline void precache_init(struct super_block *sb)
+{
+}
+
+static inline int precache_get(struct address_space *mapping,
+=09=09unsigned long index, struct page *empty_page)
+{
+=09return 0;
+}
+
+static inline int precache_put(struct address_space *mapping,
+=09=09unsigned long index, struct page *page)
+{
+=09return 0;
+}
+
+static inline int precache_flush(struct address_space *mapping,
+=09=09unsigned long index)
+{
+=09return 0;
+}
+
+static inline int precache_flush_inode(struct address_space *mapping)
+{
+=09return 0;
+}
+
+static inline int precache_flush_filesystem(struct super_block *s)
+{
+=09return 0;
+}
+#endif
+
+#define _LINUX_PRECACHE_H
+#endif /* _LINUX_PRECACHE_H */
--- linux-2.6.30/mm/precache.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.30-tmem/mm/precache.c=092009-07-06 15:50:04.000000000 -0600
@@ -0,0 +1,134 @@
+/*
+ * linux/mm/precache.c
+ *
+ * Implements "precache" for filesystems/pagecache on top of transcendent
+ * memory ("tmem") API.  A filesystem creates an "ephemeral tmem pool"
+ * and retains the returned pool_id in its superblock.  Clean pages evicte=
d
+ * from pagecache may be "put" into the pool and associated with a "handle=
"
+ * consisting of the pool_id, an object (inode) id, and an index (page off=
set).
+ * Note that the page is copied to tmem; no kernel mappings are changed.
+ * If the page is later needed, the filesystem (or VFS) issues a "get", pa=
ssing
+ * the same handle and an empty pageframe.  If successful, the page is cop=
ied
+ * into the pageframe and a disk read is avoided.  But since the tmem pool
+ * is of indeterminate size, a "put" page has indeterminate longevity
+ * ("ephemeral"), and the "get" may fail, in which case the filesystem mus=
t
+ * read the page from disk as before.  Note that the filesystem/pagecache =
are
+ * responsible for maintaining coherency between the pagecache, precache,
+ * and the disk, for which "flush page" and "flush object" actions are
+ * provided.  And when a filesystem is unmounted, it must "destroy" the po=
ol.
+ *
+ * Tmem supports two different modes for a precache: "private" or "shared"=
.
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
+#include <linux/precache.h>
+#include <linux/module.h>
+#include <linux/tmem.h>
+
+static int precache_auto_allocate; /* set to 1 to auto_allocate */
+
+int precache_put(struct address_space *mapping, unsigned long index,
+ struct page *page)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->precache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+=09u32 ind =3D (u32) index;
+=09unsigned long pfn =3D page_to_pfn(page);
+=09struct tmem_pool_uuid uuid_private =3D TMEM_POOL_PRIVATE_UUID;
+=09int ret;
+
+=09if ((s32)tmem_pool < 0) {
+=09=09if (!precache_auto_allocate)
+=09=09=09return 0;
+=09=09/* a put on a non-existent precache may auto-allocate one */
+=09=09ret =3D tmem_new_pool(uuid_private, 0);
+=09=09if (ret < 0)
+=09=09=09return 0;
+=09=09printk(KERN_INFO
+=09=09=09"Mapping superblock for s_id=3D%s to precache_id=3D%d\n",
+=09=09=09mapping->host->i_sb->s_id, tmem_pool);
+=09=09mapping->host->i_sb->precache_poolid =3D tmem_pool;
+=09}
+=09if (ind !=3D index)
+=09=09return 0;
+=09mb(); /* ensure page is quiescent; tmem may address it with an alias */
+=09return tmem_put_page(tmem_pool, obj, ind, pfn);
+}
+
+int precache_get(struct address_space *mapping, unsigned long index,
+ struct page *empty_page)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->precache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+=09u32 ind =3D (u32) index;
+=09unsigned long pfn =3D page_to_pfn(empty_page);
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+=09if (ind !=3D index)
+=09=09return 0;
+
+=09return tmem_get_page(tmem_pool, obj, ind, pfn);
+}
+EXPORT_SYMBOL(precache_get);
+
+int precache_flush(struct address_space *mapping, unsigned long index)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->precache_poolid;
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
+EXPORT_SYMBOL(precache_flush);
+
+int precache_flush_inode(struct address_space *mapping)
+{
+=09u32 tmem_pool =3D mapping->host->i_sb->precache_poolid;
+=09u64 obj =3D (unsigned long) mapping->host->i_ino;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+
+=09return tmem_flush_object(tmem_pool, obj);
+}
+EXPORT_SYMBOL(precache_flush_inode);
+
+int precache_flush_filesystem(struct super_block *sb)
+{
+=09u32 tmem_pool =3D sb->precache_poolid;
+=09int ret;
+
+=09if ((s32)tmem_pool < 0)
+=09=09return 0;
+=09ret =3D tmem_destroy_pool(tmem_pool);
+=09if (!ret)
+=09=09return 0;
+=09printk(KERN_INFO
+=09=09"Unmapping superblock for s_id=3D%s from precache_id=3D%d\n",
+=09=09sb->s_id, ret);
+=09sb->precache_poolid =3D 0;
+=09return 1;
+}
+EXPORT_SYMBOL(precache_flush_filesystem);
+
+void precache_init(struct super_block *sb)
+{
+=09struct tmem_pool_uuid uuid_private =3D TMEM_POOL_PRIVATE_UUID;
+
+=09sb->precache_poolid =3D tmem_new_pool(uuid_private, 0);
+}
+EXPORT_SYMBOL(precache_init);
--- linux-2.6.30-tmem-tmem/mm/Kconfig=092009-07-06 16:36:31.000000000 -0600
+++ linux-2.6.30-tmem-precache/mm/Kconfig=092009-07-06 16:37:05.000000000 -=
0600
@@ -263,3 +263,11 @@ config TMEM
 =09  In a virtualized environment, allows unused and underutilized
 =09  system physical memory to be made accessible through a narrow
 =09  well-defined page-copy-based API.
+
+config PRECACHE
+=09bool "Cache clean pages in transcendent memory"
+=09depends on TMEM
+=09help
+=09  Allows the transcendent memory pool to be used to store clean
+=09  page-cache pages which, under some circumstances, will greatly
+=09  reduce paging and thus improve performance.
--- linux-2.6.30-tmem-tmem/mm/Makefile=092009-07-06 16:36:52.000000000 -060=
0
+++ linux-2.6.30-tmem-precache/mm/Makefile=092009-07-06 16:37:10.000000000 =
-0600
@@ -17,6 +17,7 @@ obj-$(CONFIG_PROC_PAGE_MONITOR) +=3D pagew
 obj-$(CONFIG_BOUNCE)=09+=3D bounce.o
 obj-$(CONFIG_SWAP)=09+=3D page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_TMEM)=09+=3D tmem.o
+obj-$(CONFIG_PRECACHE)=09+=3D precache.o
 obj-$(CONFIG_HAS_DMA)=09+=3D dmapool.o
 obj-$(CONFIG_HUGETLBFS)=09+=3D hugetlb.o
 obj-$(CONFIG_NUMA) =09+=3D mempolicy.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
