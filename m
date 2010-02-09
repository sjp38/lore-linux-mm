Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E6DBB6B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 11:21:08 -0500 (EST)
Date: Wed, 10 Feb 2010 00:21:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Message-ID: <20100209162101.GA12840@localhost>
References: <4B6B7FBF.9090005@bx.jp.nec.com> <20100205072858.GC9320@elte.hu> <20100208155450.GA17055@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100208155450.GA17055@localhost>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Chris Frost <frost@cs.ucla.edu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

> Here is a scratch patch to exercise the "object collections" idea :)
> 
> Interestingly, the pagecache walk is pretty fast, while copying out the trace
> data takes more time:
> 
>         # time (echo / > walk-fs)
>         (; echo / > walk-fs; )  0.01s user 0.11s system 82% cpu 0.145 total
> 
>         # time wc /debug/tracing/trace
>         4570 45893 551282 /debug/tracing/trace
>         wc /debug/tracing/trace  0.75s user 0.55s system 88% cpu 1.470 total

Ah got it: it takes much time to "print" the raw trace data.

> TODO:
> 
> correctness
> - show file path name
>   XXX: can trace_seq_path() be called directly inside TRACE_EVENT()?

OK, finished with the file name with d_path(). I choose not to mangle
the possible '\n' in file names, and simply show "?" for such files,
for the sake of speed.

Thanks,
Fengguang
---
tracing: pagecache object collections

This dumps
- all cached files of a mounted fs  (the inode-cache)
- all cached pages of a cached file (the page-cache)

Usage and Sample output:

# echo /dev > /debug/tracing/objects/mm/pages/walk-fs
# tail /debug/tracing/trace
             zsh-2528  [000] 10429.172470: dump_inode: ino=889 size=0 cached=0 age=442 dirty=0 dev=0:18 file=/dev/console
             zsh-2528  [000] 10429.172472: dump_inode: ino=888 size=0 cached=0 age=442 dirty=7 dev=0:18 file=/dev/null
             zsh-2528  [000] 10429.172474: dump_inode: ino=887 size=40 cached=0 age=442 dirty=0 dev=0:18 file=/dev/shm
             zsh-2528  [000] 10429.172477: dump_inode: ino=886 size=40 cached=0 age=442 dirty=0 dev=0:18 file=/dev/pts
             zsh-2528  [000] 10429.172479: dump_inode: ino=885 size=11 cached=0 age=442 dirty=0 dev=0:18 file=/dev/core
             zsh-2528  [000] 10429.172481: dump_inode: ino=884 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stderr
             zsh-2528  [000] 10429.172483: dump_inode: ino=883 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stdout
             zsh-2528  [000] 10429.172486: dump_inode: ino=882 size=15 cached=0 age=442 dirty=0 dev=0:18 file=/dev/stdin
             zsh-2528  [000] 10429.172488: dump_inode: ino=881 size=13 cached=0 age=442 dirty=0 dev=0:18 file=/dev/fd
             zsh-2528  [000] 10429.172491: dump_inode: ino=872 size=13360 cached=0 age=442 dirty=0 dev=0:18 file=/dev

Here "age" is either age from inode create time, or from last dirty time.

TODO:

correctness
- reliably prevent ring buffer overflow,
  by replacing cond_resched() with some wait function
  (eg. wait until 2+ pages are free in ring buffer)
- use stable_page_flags() in recent kernel

output style
- use plain tracing output format (no fancy TASK-PID/.../FUNCTION fields)
- clear ring buffer before dumping the objects?
- output format: key=value pairs ==> header + tabbed values?
- add filtering options if necessary

CC: Ingo Molnar <mingo@elte.hu>
CC: Chris Frost <frost@cs.ucla.edu>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/inode.c                |    2 
 include/trace/events/mm.h |   70 ++++++++++++
 kernel/trace/trace_mm.c   |  204 ++++++++++++++++++++++++++++++++++++
 3 files changed, 275 insertions(+), 1 deletion(-)

--- linux-mm.orig/include/trace/events/mm.h	2010-02-08 23:19:09.000000000 +0800
+++ linux-mm/include/trace/events/mm.h	2010-02-09 23:39:03.000000000 +0800
@@ -2,6 +2,7 @@
 #define _TRACE_MM_H
 
 #include <linux/tracepoint.h>
+#include <linux/pagemap.h>
 #include <linux/mm.h>
 
 #undef TRACE_SYSTEM
@@ -42,6 +43,75 @@ TRACE_EVENT(dump_pages,
 		  __entry->mapcount, __entry->index)
 );
 
+TRACE_EVENT(dump_pagecache_range,
+
+	TP_PROTO(struct page *page, unsigned long len),
+
+	TP_ARGS(page, len),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	index		)
+		__field(	unsigned long,	len		)
+		__field(	unsigned long,	flags		)
+		__field(	unsigned int,	count		)
+		__field(	unsigned int,	mapcount	)
+	),
+
+	TP_fast_assign(
+		__entry->index		= page->index;
+		__entry->len		= len;
+		__entry->flags		= page->flags;
+		__entry->count		= atomic_read(&page->_count);
+		__entry->mapcount	= page_mapcount(page);
+	),
+
+	TP_printk("index=%lu len=%lu flags=%lx count=%u mapcount=%u",
+		  __entry->index,
+		  __entry->len,
+		  __entry->flags,
+		  __entry->count,
+		  __entry->mapcount)
+);
+
+TRACE_EVENT(dump_inode,
+
+	TP_PROTO(struct inode *inode, char *name, int len),
+
+	TP_ARGS(inode, name, len),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	ino		)
+		__field(	loff_t,		size		)
+		__field(	unsigned long,	nrpages		)
+		__field(	unsigned long,	age		)
+		__field(	unsigned long,	state		)
+		__field(	dev_t,		dev		)
+		__dynamic_array(char,		file,	len	)
+	),
+
+	TP_fast_assign(
+		__entry->ino		= inode->i_ino;
+		__entry->size		= i_size_read(inode);
+		__entry->nrpages	= inode->i_mapping->nrpages;
+		__entry->age		= jiffies - inode->dirtied_when;
+		__entry->state		= inode->i_state;
+		__entry->dev		= inode->i_sb->s_dev;
+		memcpy(__get_str(file), name, len);
+	),
+
+	TP_printk("ino=%lu size=%llu cached=%lu age=%lu dirty=%lu "
+		  "dev=%u:%u file=%s",
+		  __entry->ino,
+		  __entry->size,
+		  __entry->nrpages << PAGE_CACHE_SHIFT,
+		  __entry->age / HZ,
+		  __entry->state & I_DIRTY,
+		  MAJOR(__entry->dev),
+		  MINOR(__entry->dev),
+		  strchr(__get_str(file), '\n') ? "?" : __get_str(file))
+);
+
+
 #endif /*  _TRACE_MM_H */
 
 /* This part must be outside protection */
--- linux-mm.orig/kernel/trace/trace_mm.c	2010-02-08 23:19:09.000000000 +0800
+++ linux-mm/kernel/trace/trace_mm.c	2010-02-10 00:04:47.000000000 +0800
@@ -9,6 +9,9 @@
 #include <linux/bootmem.h>
 #include <linux/debugfs.h>
 #include <linux/uaccess.h>
+#include <linux/pagevec.h>
+#include <linux/writeback.h>
+#include <linux/file.h>
 
 #include "trace_output.h"
 
@@ -95,6 +98,201 @@ static const struct file_operations trac
 	.write		= trace_mm_dump_range_write,
 };
 
+static unsigned long page_flags(struct page* page)
+{
+	return page->flags & ((1 << NR_PAGEFLAGS) - 1);
+}
+
+static int pages_similiar(struct page* page0, struct page* page)
+{
+	if (page_count(page0) != page_count(page))
+		return 0;
+
+	if (page_mapcount(page0) != page_mapcount(page))
+		return 0;
+
+	if (page_flags(page0) != page_flags(page))
+		return 0;
+
+	return 1;
+}
+
+#define BATCH_LINES	100
+static void dump_pagecache(struct address_space *mapping)
+{
+	int i;
+	int lines = 0;
+	pgoff_t len = 0;
+	struct pagevec pvec;
+	struct page *page;
+	struct page *page0 = NULL;
+	unsigned long start = 0;
+
+	for (;;) {
+		pagevec_init(&pvec, 0);
+		pvec.nr = radix_tree_gang_lookup(&mapping->page_tree,
+				(void **)pvec.pages, start + len, PAGEVEC_SIZE);
+
+		if (pvec.nr == 0) {
+			if (len)
+				trace_dump_pagecache_range(page0, len);
+			break;
+		}
+
+		if (!page0)
+			page0 = pvec.pages[0];
+
+		for (i = 0; i < pvec.nr; i++) {
+			page = pvec.pages[i];
+
+			if (page->index == start + len &&
+					pages_similiar(page0, page))
+				len++;
+			else {
+				trace_dump_pagecache_range(page0, len);
+				page0 = page;
+				start = page->index;
+				len = 1;
+				if (++lines > BATCH_LINES) {
+					lines = 0;
+					cond_resched();
+				}
+			}
+		}
+	}
+}
+
+static void dump_inode(struct inode *inode,
+		       char *name_buf,
+		       struct vfsmount *mnt)
+{
+	struct path path = {
+		.mnt = mnt,
+		.dentry = d_find_alias(inode)
+	};
+	char *name;
+	int len;
+
+	if (!path.dentry) {
+		trace_dump_inode(inode, "?", 2);
+		return;
+	}
+
+	name = d_path(&path, name_buf, PAGE_SIZE);
+	if (IS_ERR(name)) {
+		name = "?";
+		len = 2;
+	} else
+		len = PAGE_SIZE + name_buf - name;
+
+	trace_dump_inode(inode, name, len);
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
+	spin_lock(&inode_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
+			continue;
+		__iget(inode);
+		spin_unlock(&inode_lock);
+		dump_inode(inode, name_buf, mnt);
+		if (inode->i_mapping->nrpages)
+			dump_pagecache(inode->i_mapping);
+		iput(prev_inode);
+		prev_inode = inode;
+		cond_resched();
+		spin_lock(&inode_lock);
+	}
+	spin_unlock(&inode_lock);
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
+	if (count > PATH_MAX + 1)
+		return -ENAMETOOLONG;
+
+	name = kmalloc(count+1, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	if (copy_from_user(name, ubuf, count)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	/* strip the newline added by `echo` */
+	if (name[count-1] != '\n')
+		return -EINVAL;
+	name[count-1] = '\0';
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
+	if (trace_set_clr_event("mm", "dump_pagecache_range", 1)) {
+		err = -EINVAL;
+		goto out;
+	}
+	if (trace_set_clr_event("mm", "dump_inode", 1)) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	if (filp->f_path.dentry->d_inode->i_private) {
+		dump_fs_pagecache(file->f_path.dentry->d_sb, file->f_path.mnt);
+	} else {
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
+	.read		= trace_mm_dump_range_read,
+	.write		= trace_pagecache_write,
+};
+
 /* move this into trace_objects.c when that file is created */
 static struct dentry *trace_objects_dir(void)
 {
@@ -167,6 +365,12 @@ static __init int trace_objects_mm_init(
 	trace_create_file("dump_range", 0600, d_pages, NULL,
 			  &trace_mm_fops);
 
+	trace_create_file("walk-file", 0600, d_pages, NULL,
+			  &trace_pagecache_fops);
+
+	trace_create_file("walk-fs", 0600, d_pages, (void *)1,
+			  &trace_pagecache_fops);
+
 	return 0;
 }
 fs_initcall(trace_objects_mm_init);
--- linux-mm.orig/fs/inode.c	2010-02-08 23:19:12.000000000 +0800
+++ linux-mm/fs/inode.c	2010-02-08 23:19:22.000000000 +0800
@@ -149,7 +149,7 @@ struct inode *inode_init_always(struct s
 	inode->i_bdev = NULL;
 	inode->i_cdev = NULL;
 	inode->i_rdev = 0;
-	inode->dirtied_when = 0;
+	inode->dirtied_when = jiffies;
 
 	if (security_inode_alloc(inode))
 		goto out_free_inode;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
