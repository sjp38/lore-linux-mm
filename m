Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D0C8290013C
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:57:08 -0400 (EDT)
Message-Id: <20110829034932.411784596@intel.com>
Date: Mon, 29 Aug 2011 11:29:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 6/7] tracing/mm: add dump-file and dump-fs interfaces
References: <20110829032951.677220552@intel.com>
Content-Disposition: inline; filename=trace-mm-pages.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Chris Frost <frost@cs.ucla.edu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This dumps
- all cached files of a mounted fs  (the inode-cache)
- all cached pages of a cached file (the page-cache)

Usage and Sample output:

# echo / > /debug/tracing/objects/mm/pages/dump-fs
# head -20 /debug/tracing/trace
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
             zsh-3128  [000]   432.050943: dump_inode_cache: ino=1507329 size=4096 cached=4096 dirtied_when=4294676467 age=444 state=____ type=DIR name=/
             zsh-3128  [000]   432.050949: dump_page_cache: index=0 len=1 flags=____RU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]   432.050962: dump_inode_cache: ino=1786836 size=12288 cached=12288 dirtied_when=4294676472 age=444 state=____ type=DIR name=/sbin
             zsh-3128  [000]   432.050966: dump_page_cache: index=0 len=3 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]   432.050973: dump_inode_cache: ino=1786946 size=37312 cached=40960 dirtied_when=4294676473 age=444 state=____ type=REG name=/sbin/init
             zsh-3128  [000]   432.050977: dump_page_cache: index=0 len=6 flags=M__ARU_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]   432.050978: dump_page_cache: index=6 len=1 flags=M__A_U_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]   432.050978: dump_page_cache: index=7 len=1 flags=M__ARU_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]   432.050979: dump_page_cache: index=8 len=2 flags=_____U_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]   432.050986: dump_inode_cache: ino=1507464 size=4 cached=4096 dirtied_when=4294676477 age=444 state=____ type=LNK name=/lib64
             zsh-3128  [000]   432.050989: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]   432.050995: dump_inode_cache: ino=1590173 size=12288 cached=0 dirtied_when=4294676477 age=444 state=____ type=DIR name=/lib
             zsh-3128  [000]   432.051003: dump_inode_cache: ino=1590265 size=27 cached=4096 dirtied_when=4294676478 age=444 state=____ type=LNK name=/lib/ld-linux-x86-64.so.2
             zsh-3128  [000]   432.051006: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]   432.051013: dump_inode_cache: ino=1663440 size=4096 cached=0 dirtied_when=4294676479 age=444 state=____ type=DIR name=/lib/x86_64-linux-gnu
             zsh-3128  [000]   432.051022: dump_inode_cache: ino=3293287 size=136936 cached=139264 dirtied_when=4294676480 age=444 state=____ type=REG name=/lib/x86_64-linux-gnu/ld-2.13.so

Here "age" is the number of seconds from either inode create time, or
last dirty time for dirtied inodes. "memcg" is the memory controller
group id to be added by next patch.

CC: Ingo Molnar <mingo@elte.hu>
CC: Chris Frost <frost@cs.ucla.edu>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/inode.c                |    8 +
 fs/internal.h             |    5 
 include/linux/fs.h        |    1 
 include/trace/events/mm.h |   95 ++++++++++++++++
 kernel/trace/trace_mm.c   |  213 ++++++++++++++++++++++++++++++++++++
 5 files changed, 316 insertions(+), 6 deletions(-)

--- linux-mmotm.orig/include/trace/events/mm.h	2011-08-29 09:50:55.000000000 +0800
+++ linux-mmotm/include/trace/events/mm.h	2011-08-29 10:26:27.000000000 +0800
@@ -3,7 +3,10 @@
 
 #include <linux/tracepoint.h>
 #include <linux/page-flags.h>
+#include <linux/memcontrol.h>
+#include <linux/pagemap.h>
 #include <linux/mm.h>
+#include <linux/kernel-page-flags.h>
 
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM mm
@@ -63,6 +66,98 @@ TRACE_EVENT(dump_page_frame,
 	)
 );
 
+TRACE_EVENT(dump_page_cache,
+
+	TP_PROTO(struct page *page, unsigned long len),
+
+	TP_ARGS(page, len),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	index		)
+		__field(	unsigned long,	len		)
+		__field(	u64,		flags		)
+		__field(	unsigned int,	count		)
+		__field(	unsigned int,	mapcount	)
+	),
+
+	TP_fast_assign(
+		__entry->index		= page->index;
+		__entry->len		= len;
+		__entry->flags		= stable_page_flags(page);
+		__entry->count		= atomic_read(&page->_count);
+		__entry->mapcount	= page_mapcount(page);
+	),
+
+	TP_printk("index=%lu len=%lu flags=%c%c%c%c%c%c%c%c%c%c%c "
+		  "count=%u mapcount=%u",
+		  __entry->index,
+		  __entry->len,
+		  __entry->flags & (1ULL << KPF_MMAP)		? 'M' : '_',
+		  __entry->flags & (1ULL << KPF_MLOCKED)	? 'm' : '_',
+		  __entry->flags & (1ULL << KPF_UNEVICTABLE)	? 'u' : '_',
+		  __entry->flags & (1ULL << KPF_ACTIVE)		? 'A' : '_',
+		  __entry->flags & (1ULL << KPF_REFERENCED)	? 'R' : '_',
+		  __entry->flags & (1ULL << KPF_UPTODATE)	? 'U' : '_',
+		  __entry->flags & (1ULL << KPF_DIRTY)		? 'D' : '_',
+		  __entry->flags & (1ULL << KPF_WRITEBACK)	? 'W' : '_',
+		  __entry->flags & (1ULL << KPF_RECLAIM)	? 'I' : '_',
+		  __entry->flags & (1ULL << KPF_MAPPEDTODISK)	? 'd' : '_',
+		  __entry->flags & (1ULL << KPF_PRIVATE)	? 'P' : '_',
+		  __entry->count,
+		  __entry->mapcount)
+);
+
+
+#define show_inode_type(val)	__print_symbolic(val, 	   \
+				{ S_IFREG,	"REG"	}, \
+				{ S_IFDIR,	"DIR"	}, \
+				{ S_IFLNK,	"LNK"	}, \
+				{ S_IFBLK,	"BLK"	}, \
+				{ S_IFCHR,	"CHR"	}, \
+				{ S_IFIFO,	"FIFO"	}, \
+				{ S_IFSOCK,	"SOCK"	})
+
+TRACE_EVENT(dump_inode_cache,
+
+	TP_PROTO(struct inode *inode, char *name, int len),
+
+	TP_ARGS(inode, name, len),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	ino		)
+		__field(	loff_t,		size		) /* bytes */
+		__field(	loff_t,		cached		) /* bytes */
+		__field(	unsigned long,	dirtied_when	)
+		__field(	unsigned long,	state		)
+		__field(	umode_t,	mode		)
+		__dynamic_array(char,		file,	len	)
+	),
+
+	TP_fast_assign(
+		__entry->ino	= inode->i_ino;
+		__entry->size	= i_size_read(inode);
+		__entry->cached	= inode->i_mapping->nrpages << PAGE_CACHE_SHIFT;
+		__entry->dirtied_when	= inode->dirtied_when;
+		__entry->state	= inode->i_state;
+		__entry->mode	= inode->i_mode;
+		memcpy(__get_str(file), name, len);
+	),
+
+	TP_printk("ino=%lu size=%llu cached=%llu dirtied_when=%lu age=%lu "
+		  "state=%c%c%c%c type=%s name=%s",
+		  __entry->ino,
+		  __entry->size,
+		  __entry->cached,
+		  __entry->dirtied_when,
+		  (jiffies - __entry->dirtied_when) / HZ,
+		  __entry->state & I_DIRTY_PAGES	? 'D' : '_',
+		  __entry->state & I_DIRTY_DATASYNC	? 'd' : '_',
+		  __entry->state & I_DIRTY_SYNC		? 'm' : '_',
+		  __entry->state & I_SYNC		? 'S' : '_',
+		  show_inode_type(__entry->mode & S_IFMT),
+		  __get_str(file))
+);
+
 #endif /*  _TRACE_MM_H */
 
 /* This part must be outside protection */
--- linux-mmotm.orig/kernel/trace/trace_mm.c	2011-08-29 09:50:55.000000000 +0800
+++ linux-mmotm/kernel/trace/trace_mm.c	2011-08-29 09:50:56.000000000 +0800
@@ -2,6 +2,7 @@
  * Trace mm pages
  *
  * Copyright (C) 2009 Red Hat Inc, Steven Rostedt <srostedt@redhat.com>
+ * Copyright (C) 2009 Intel Corporation, Wu Fengguang <fengguang.wu@intel.com>
  *
  * Code based on Matt Mackall's /proc/[kpagecount|kpageflags] code.
  */
@@ -10,6 +11,10 @@
 #include <linux/debugfs.h>
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
+#include <linux/pagevec.h>
+#include <linux/writeback.h>
+#include <linux/file.h>
+#include <linux/slab.h>
 
 #include "trace_output.h"
 
@@ -123,6 +128,208 @@ static struct dentry *trace_objects_mm_d
 	return d_mm;
 }
 
+static unsigned long page_flags(struct page *page)
+{
+	return page->flags & PAGE_FLAGS_MASK;
+}
+
+static int pages_similar(struct page *page0, struct page *page)
+{
+	if (page_flags(page0) != page_flags(page))
+		return 0;
+
+	if (page_count(page0) != page_count(page))
+		return 0;
+
+	if (page_mapcount(page0) != page_mapcount(page))
+		return 0;
+
+	return 1;
+}
+
+static void dump_pagecache(struct address_space *mapping)
+{
+	unsigned long nr_pages;
+	struct page *pages[PAGEVEC_SIZE];
+	struct page *uninitialized_var(page0);
+	struct page *page;
+	unsigned long start = 0;
+	unsigned long len = 0;
+	int i;
+
+	for (;;) {
+		rcu_read_lock();
+		nr_pages = radix_tree_gang_lookup(&mapping->page_tree,
+				(void **)pages, start + len, PAGEVEC_SIZE);
+		rcu_read_unlock();
+
+		if (nr_pages == 0) {
+			if (len)
+				trace_dump_page_cache(page0, len);
+			return;
+		}
+
+		for (i = 0; i < nr_pages; i++) {
+			page = pages[i];
+
+			if (len &&
+			    page->index == start + len &&
+			    pages_similar(page0, page))
+				len++;
+			else {
+				if (len)
+					trace_dump_page_cache(page0, len);
+				page0 = page;
+				start = page->index;
+				len = 1;
+			}
+		}
+		cond_resched();
+	}
+}
+
+static void dump_inode_cache(struct inode *inode,
+			     char *name_buf,
+			     struct vfsmount *mnt)
+{
+	struct path path = {
+		.mnt = mnt,
+		.dentry = d_find_alias(inode)
+	};
+	char *name;
+	int len;
+
+	if (!mnt) {
+		trace_dump_inode_cache(inode, name_buf, strlen(name_buf));
+		return;
+	}
+
+	if (!path.dentry) {
+		trace_dump_inode_cache(inode, "", 1);
+		return;
+	}
+
+	name = d_path(&path, name_buf, PAGE_SIZE);
+	if (IS_ERR(name)) {
+		name = "";
+		len = 1;
+	} else
+		len = PAGE_SIZE + name_buf - name;
+
+	trace_dump_inode_cache(inode, name, len);
+
+	if (path.dentry)
+		dput(path.dentry);
+}
+
+static void dump_fs_pagecache(struct super_block *sb, struct vfsmount *mnt)
+{
+	struct inode *inode;
+	struct inode *prev_inode = NULL;
+	char *name_buf;
+
+	name_buf = (char *)__get_free_page(GFP_TEMPORARY);
+	if (!name_buf)
+		return;
+
+	down_read(&sb->s_umount);
+	if (!sb->s_root)
+		goto out;
+
+	spin_lock(&inode_sb_list_lock);
+	list_for_each_entry_reverse(inode, &sb->s_inodes, i_sb_list) {
+		spin_lock(&inode->i_lock);
+		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW)) {
+			spin_unlock(&inode->i_lock);
+			continue;
+		}
+		__iget(inode);
+		spin_unlock(&inode->i_lock);
+		spin_unlock(&inode_sb_list_lock);
+		dump_inode_cache(inode, name_buf, mnt);
+		if (inode->i_mapping->nrpages)
+			dump_pagecache(inode->i_mapping);
+		iput(prev_inode);
+		prev_inode = inode;
+		cond_resched();
+		spin_lock(&inode_sb_list_lock);
+	}
+	spin_unlock(&inode_sb_list_lock);
+	iput(prev_inode);
+out:
+	up_read(&sb->s_umount);
+	free_page((unsigned long)name_buf);
+}
+
+static ssize_t
+trace_pagecache_write(struct file *filp, const char __user *ubuf, size_t count,
+		      loff_t *ppos)
+{
+	struct file *file = NULL;
+	char *name;
+	int err = 0;
+
+	if (count <= 1)
+		return -EINVAL;
+	if (count >= PAGE_SIZE)
+		return -ENAMETOOLONG;
+
+	name = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	if (copy_from_user(name, ubuf, count)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	/* strip the newline added by `echo` */
+	if (name[count-1] == '\n')
+		name[count-1] = '\0';
+	else
+		name[count] = '\0';
+
+	file = filp_open(name, O_RDONLY|O_LARGEFILE, 0);
+	if (IS_ERR(file)) {
+		err = PTR_ERR(file);
+		file = NULL;
+		goto out;
+	}
+
+	if (tracing_update_buffers() < 0) {
+		err = -ENOMEM;
+		goto out;
+	}
+	if (trace_set_clr_event("mm", "dump_page_cache", 1)) {
+		err = -EINVAL;
+		goto out;
+	}
+	if (trace_set_clr_event("mm", "dump_inode_cache", 1)) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (filp->f_path.dentry->d_inode->i_private) {
+		dump_fs_pagecache(file->f_path.dentry->d_sb, file->f_path.mnt);
+	} else {
+		dump_inode_cache(file->f_mapping->host, name, NULL);
+		dump_pagecache(file->f_mapping);
+	}
+
+out:
+	if (file)
+		fput(file);
+	kfree(name);
+
+	return err ? err : count;
+}
+
+static const struct file_operations trace_pagecache_fops = {
+	.open		= tracing_open_generic,
+	.read		= trace_mm_pfn_range_read,
+	.write		= trace_pagecache_write,
+};
+
 static struct dentry *trace_objects_mm_pages_dir(void)
 {
 	static struct dentry *d_pages;
@@ -154,6 +361,12 @@ static __init int trace_objects_mm_init(
 	trace_create_file("dump-pfn", 0600, d_pages, NULL,
 			  &trace_mm_fops);
 
+	trace_create_file("dump-file", 0600, d_pages, NULL,
+			  &trace_pagecache_fops);
+
+	trace_create_file("dump-fs", 0600, d_pages, (void *)1,
+			  &trace_pagecache_fops);
+
 	return 0;
 }
 fs_initcall(trace_objects_mm_init);
--- linux-mmotm.orig/fs/inode.c	2011-08-29 09:50:55.000000000 +0800
+++ linux-mmotm/fs/inode.c	2011-08-29 09:50:56.000000000 +0800
@@ -158,7 +158,13 @@ int inode_init_always(struct super_block
 	inode->i_bdev = NULL;
 	inode->i_cdev = NULL;
 	inode->i_rdev = 0;
-	inode->dirtied_when = 0;
+
+	/*
+	 * This records inode load time. It will be invalidated once inode is
+	 * dirtied, or jiffies wraps around. Despite the pitfalls it still
+	 * provides useful information for some use cases like fastboot.
+	 */
+	inode->dirtied_when = jiffies;
 
 	if (security_inode_alloc(inode))
 		goto out;
--- linux-mmotm.orig/fs/internal.h	2011-08-29 09:50:55.000000000 +0800
+++ linux-mmotm/fs/internal.h	2011-08-29 09:50:56.000000000 +0800
@@ -124,11 +124,6 @@ extern long do_handle_open(int mountdirf
 			   struct file_handle __user *ufh, int open_flag);
 
 /*
- * inode.c
- */
-extern spinlock_t inode_sb_list_lock;
-
-/*
  * fs-writeback.c
  */
 extern void inode_wb_list_del(struct inode *inode);
--- linux-mmotm.orig/include/linux/fs.h	2011-08-29 09:50:55.000000000 +0800
+++ linux-mmotm/include/linux/fs.h	2011-08-29 09:50:56.000000000 +0800
@@ -1378,6 +1378,7 @@ extern int send_sigurg(struct fown_struc
 
 extern struct list_head super_blocks;
 extern spinlock_t sb_lock;
+extern spinlock_t inode_sb_list_lock;
 
 struct super_block {
 	struct list_head	s_list;		/* Keep this first */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
