Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B613E8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 19:33:44 -0500 (EST)
Date: Thu, 3 Mar 2011 08:33:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
Message-ID: <20110303003338.GA5883@localhost>
References: <no>
 <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
 <20110302084542.GA20795@elte.hu>
 <1299085326.8493.820.camel@nimitz>
 <20110302184953.GH13693@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110302184953.GH13693@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Liu Yuan <namei.unix@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jaxboe@fusionio.com" <jaxboe@fusionio.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>

On Thu, Mar 03, 2011 at 02:49:53AM +0800, Ingo Molnar wrote:
> 
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Wed, 2011-03-02 at 09:45 +0100, Ingo Molnar wrote:
> > > But, instead of trying to improve those aspects of our existing instrumentation 
> > > frameworks, mm/* is gradually growing its own special instrumentation hacks, missing 
> > > the big picture and fragmenting the instrumentation space some more.
> > > 
> > > That trend is somewhat sad. 
> > 
> > Go any handy examples of how you'd like to see these done?
> 
> There's a very, very old branch in tip:tracing/mm (by Steve) that shows off some of 
> the concepts that could be introduced, to 'dump' current MM state via an extension 
> to the tracepoints APIs:
> 
> 3383e37ea796: tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
> c33b3596bc38: tracing, page-allocator: Add trace event for page traffic related to the buddy lists
> 0d524fb734bc: tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
> b9a28177eedf: tracing, page-allocator: Add trace events for page allocation and page freeing
> 807243eb20b2: Merge branch 'perfcounters/urgent' into tracing/mm
> 08b6cb88eeb5: perf_counter tools: Provide default bfd_demangle() function in case it's not around
> eb4671011887: tracing/mm: rename 'trigger' file to 'dump_range'
> 1487a7a1ff99: tracing/mm: fix mapcount trace record field
> dcac8cdac1d4: tracing/mm: add page frame snapshot trace
> 
> That's just a demo in essence - showing what things could be done in this area.
> 
> You can pick those commits up via running:
> 
>   http://people.redhat.com/mingo/tip.git/README

Ingo, sorry for remain silence on this topic. I'm actually updating the code.
Below is the most up-to-date version on top of 2.6.37.  I can post a patchset
for review after finished with the writeback patches.

Thanks,
Fengguang
---

Usage:

root@bay /home/wfg# echo / > /debug/tracing/objects/mm/pages/dump-fs
root@bay /home/wfg# cat /debug/tracing/trace

# The output has intermixed lines for inode and page
#         ino         size       cached      age(ms) dirty type first-opened-by file-name
      1507329         4096         8192       309042 ____  DIR          swapper /
#      index    len  page-flags count mapcount
           0      2 ____RU_____    1    0
      1786836        12288        40960       309026 ____  DIR          swapper /sbin
           0     10 ___ARU_____    1    0
      1786946        37312        40960       309024 ____  REG          swapper /sbin/init
           0      6 M__ARU_____    2    1
           6      1 M__A_U_____    2    1
           7      1 M__ARU_____    2    1
           8      2 _____U_____    1    0
      1507464            4         4096       309022 ____  LNK          swapper /lib64
           0      1 ___ARU_____    1    0
      1590173        12288            0       309021 ____  DIR          swapper /lib
      4563326           12         4096       309020 ____  LNK          swapper /lib/ld-linux-x86-64.so.2
           0      1 ___ARU_____    1    0
      4563295       128744       131072       309019 ____  REG          swapper /lib/ld-2.11.2.so
           0      1 M__ARU_____   21   20
           1      3 M__ARU_____   17   16
           4      4 M__ARU_____   20   19
           8      2 M__ARU_____   27   26
          10      3 M__ARU_____   20   19
          13      1 M__ARU_____   27   26
          14      1 M__ARU_____   26   25
          15      1 M__ARU_____   20   19
          16      1 M__ARU_____   18   17
          17      1 M__ARU_____    9    8
          18      1 M__A_U_____    4    3
          19      1 M__ARU_____   27   26
          20      1 M__ARU_____   17   16
          21      1 M__ARU_____   20   19
          22      1 M__ARU_____   27   26
          23      1 M__ARU_____   20   19
          24      1 M__ARU_____   26   25
          25      1 _____U_____    1    0
          26      1 M__A_U_____    4    3
          27      1 M__ARU_____   20   19
          28      4 _____U_____    1    0
      1525477        12288            0       309011 ____  DIR             init /etc
      1526463        64634        65536       309009 ____  REG             init /etc/ld.so.cache
           0      1 ___ARU_____    1    0
           1      1 _____U_____    1    0

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmotm/include/trace/events/mm.h	2010-12-26 20:59:48.000000000 +0800
@@ -0,0 +1,164 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/tracepoint.h>
+#include <linux/page-flags.h>
+#include <linux/memcontrol.h>
+#include <linux/pagemap.h>
+#include <linux/mm.h>
+#include <linux/kernel-page-flags.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+extern struct trace_print_flags pageflag_names[];
+
+/**
+ * dump_page_frame - called by the trace page dump trigger
+ * @pfn: page frame number
+ * @page: pointer to the page frame
+ *
+ * This is a helper trace point into the dumping of the page frames.
+ * It will record various infromation about a page frame.
+ */
+TRACE_EVENT(dump_page_frame,
+
+	TP_PROTO(unsigned long pfn, struct page *page),
+
+	TP_ARGS(pfn, page),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	pfn		)
+		__field(	struct page *,	page		)
+		__field(	u64,		stable_flags	)
+		__field(	unsigned long,	flags		)
+		__field(	unsigned int,	count		)
+		__field(	unsigned int,	mapcount	)
+		__field(	unsigned long,	private		)
+		__field(	unsigned long,	mapping		)
+		__field(	unsigned long,	index		)
+	),
+
+	TP_fast_assign(
+		__entry->pfn		= pfn;
+		__entry->page		= page;
+		__entry->stable_flags	= stable_page_flags(page);
+		__entry->flags		= page->flags;
+		__entry->count		= atomic_read(&page->_count);
+		__entry->mapcount	= page_mapcount(page);
+		__entry->private	= page->private;
+		__entry->mapping	= (unsigned long)page->mapping;
+		__entry->index		= page->index;
+	),
+
+	TP_printk("%12lx %16p %8x %8x %16lx %16lx %16lx %s",
+		  __entry->pfn,
+		  __entry->page,
+		  __entry->count,
+		  __entry->mapcount,
+		  __entry->private,
+		  __entry->mapping,
+		  __entry->index,
+		  ftrace_print_flags_seq(p, "|",
+					 __entry->flags & PAGE_FLAGS_MASK,
+					 pageflag_names)
+	)
+);
+
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
+	TP_printk("%12lu %6lu %c%c%c%c%c%c%c%c%c%c%c %4u %4u",
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
+		__field(	unsigned long,	age		) /*    ms */
+		__field(	unsigned long,	state		)
+		__field(	umode_t,	mode		)
+		__array(	char,		comm, TASK_COMM_LEN)
+		__dynamic_array(char,		file,	len	)
+	),
+
+	TP_fast_assign(
+		__entry->ino	= inode->i_ino;
+		__entry->size	= i_size_read(inode);
+		__entry->cached	= inode->i_mapping->nrpages;
+		__entry->cached	<<= PAGE_CACHE_SHIFT;
+		__entry->age	= (jiffies - inode->dirtied_when) * 1000 / HZ;
+		__entry->state	= inode->i_state;
+		__entry->mode	= inode->i_mode;
+		memcpy(__entry->comm, inode->i_comm, TASK_COMM_LEN);
+		memcpy(__get_str(file), name, len);
+	),
+
+	TP_printk("%12lu %12llu %12llu %12lu %c%c%c%c %4s %16s %s",
+		  __entry->ino,
+		  __entry->size,
+		  __entry->cached,
+		  __entry->age,
+		  __entry->state & I_DIRTY_PAGES	? 'D' : '_',
+		  __entry->state & I_DIRTY_DATASYNC	? 'd' : '_',
+		  __entry->state & I_DIRTY_SYNC		? 'm' : '_',
+		  __entry->state & I_SYNC		? 'S' : '_',
+		  show_inode_type(__entry->mode & S_IFMT),
+		  __entry->comm,
+		  __get_str(file))
+);
+
+#endif /*  _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
--- mmotm.orig/kernel/trace/Makefile	2010-12-26 20:58:46.000000000 +0800
+++ mmotm/kernel/trace/Makefile	2010-12-26 20:59:41.000000000 +0800
@@ -26,6 +26,7 @@ obj-$(CONFIG_RING_BUFFER) += ring_buffer
 obj-$(CONFIG_RING_BUFFER_BENCHMARK) += ring_buffer_benchmark.o
 
 obj-$(CONFIG_TRACING) += trace.o
+obj-$(CONFIG_TRACING) += trace_objects.o
 obj-$(CONFIG_TRACING) += trace_output.o
 obj-$(CONFIG_TRACING) += trace_stat.o
 obj-$(CONFIG_TRACING) += trace_printk.o
@@ -53,6 +54,7 @@ endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_EVENT_TRACING) += power-traces.o
+obj-$(CONFIG_EVENT_TRACING) += trace_mm.o
 ifeq ($(CONFIG_TRACING),y)
 obj-$(CONFIG_KGDB_KDB) += trace_kdb.o
 endif
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmotm/kernel/trace/trace_mm.c	2010-12-26 20:59:41.000000000 +0800
@@ -0,0 +1,367 @@
+/*
+ * Trace mm pages
+ *
+ * Copyright (C) 2009 Red Hat Inc, Steven Rostedt <srostedt@redhat.com>
+ *
+ * Code based on Matt Mackall's /proc/[kpagecount|kpageflags] code.
+ */
+#include <linux/module.h>
+#include <linux/bootmem.h>
+#include <linux/debugfs.h>
+#include <linux/uaccess.h>
+#include <linux/ctype.h>
+#include <linux/pagevec.h>
+#include <linux/writeback.h>
+#include <linux/file.h>
+#include <linux/slab.h>
+
+#include "trace_output.h"
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
+
+void trace_mm_page_frames(unsigned long start, unsigned long end,
+			  void (*trace)(unsigned long pfn, struct page *page))
+{
+	unsigned long pfn = start;
+	struct page *page;
+
+	if (start > max_pfn - 1)
+		return;
+
+	if (end > max_pfn)
+		end = max_pfn;
+
+	while (pfn < end) {
+		page = NULL;
+		if (pfn_valid(pfn))
+			page = pfn_to_page(pfn);
+		pfn++;
+		if (page)
+			trace(pfn, page);
+	}
+}
+
+static void trace_mm_page_frame(unsigned long pfn, struct page *page)
+{
+	trace_dump_page_frame(pfn, page);
+}
+
+static ssize_t
+trace_mm_pfn_range_read(struct file *filp, char __user *ubuf, size_t cnt,
+			loff_t *ppos)
+{
+	return simple_read_from_buffer(ubuf, cnt, ppos, "0\n", 2);
+}
+
+
+/*
+ * recognized formats:
+ * 		"M N"	start=M, end=N
+ * 		"M"	start=M, end=M+1
+ * 		"M +N"	start=M, end=M+N-1
+ */
+static ssize_t
+trace_mm_pfn_range_write(struct file *filp, const char __user *ubuf, size_t cnt,
+			 loff_t *ppos)
+{
+	unsigned long start;
+	unsigned long end = 0;
+	char buf[64];
+	char *ptr;
+
+	if (cnt >= sizeof(buf))
+		return -EINVAL;
+
+	if (copy_from_user(&buf, ubuf, cnt))
+		return -EFAULT;
+
+	if (tracing_update_buffers() < 0)
+		return -ENOMEM;
+
+	if (trace_set_clr_event("mm", "dump_page_frame", 1))
+		return -EINVAL;
+
+	buf[cnt] = 0;
+
+	start = simple_strtoul(buf, &ptr, 0);
+
+	for (; *ptr; ptr++) {
+		if (isdigit(*ptr)) {
+			if (*(ptr - 1) == '+')
+				end = start;
+			end += simple_strtoul(ptr, NULL, 0);
+			break;
+		}
+	}
+	if (!*ptr)
+		end = start + 1;
+
+	trace_mm_page_frames(start, end, trace_mm_page_frame);
+
+	return cnt;
+}
+
+static const struct file_operations trace_mm_fops = {
+	.open		= tracing_open_generic,
+	.read		= trace_mm_pfn_range_read,
+	.write		= trace_mm_pfn_range_write,
+};
+
+static struct dentry *trace_objects_mm_dir(void)
+{
+	static struct dentry *d_mm;
+	struct dentry *d_objects;
+
+	if (d_mm)
+		return d_mm;
+
+	d_objects = trace_objects_dir();
+	if (!d_objects)
+		return NULL;
+
+	d_mm = debugfs_create_dir("mm", d_objects);
+	if (!d_mm)
+		pr_warning("Could not create 'objects/mm' directory\n");
+
+	return d_mm;
+}
+
+static unsigned long page_flags(struct page *page)
+{
+	return page->flags & ((1 << NR_PAGEFLAGS) - 1);
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
+	spin_lock(&inode_lock);
+	list_for_each_entry_reverse(inode, &sb->s_inodes, i_sb_list) {
+		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
+			continue;
+		__iget(inode);
+		spin_unlock(&inode_lock);
+		dump_inode_cache(inode, name_buf, mnt);
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
+static struct dentry *trace_objects_mm_pages_dir(void)
+{
+	static struct dentry *d_pages;
+	struct dentry *d_mm;
+
+	if (d_pages)
+		return d_pages;
+
+	d_mm = trace_objects_mm_dir();
+	if (!d_mm)
+		return NULL;
+
+	d_pages = debugfs_create_dir("pages", d_mm);
+	if (!d_pages)
+		pr_warning("Could not create debugfs "
+			   "'objects/mm/pages' directory\n");
+
+	return d_pages;
+}
+
+static __init int trace_objects_mm_init(void)
+{
+	struct dentry *d_pages;
+
+	d_pages = trace_objects_mm_pages_dir();
+	if (!d_pages)
+		return 0;
+
+	trace_create_file("dump-pfn", 0600, d_pages, NULL,
+			  &trace_mm_fops);
+
+	trace_create_file("dump-file", 0600, d_pages, NULL,
+			  &trace_pagecache_fops);
+
+	trace_create_file("dump-fs", 0600, d_pages, (void *)1,
+			  &trace_pagecache_fops);
+
+	return 0;
+}
+fs_initcall(trace_objects_mm_init);
--- mmotm.orig/kernel/trace/trace.h	2010-12-26 20:58:46.000000000 +0800
+++ mmotm/kernel/trace/trace.h	2010-12-26 20:59:41.000000000 +0800
@@ -295,6 +295,7 @@ struct dentry *trace_create_file(const c
 				 const struct file_operations *fops);
 
 struct dentry *tracing_init_dentry(void);
+struct dentry *trace_objects_dir(void);
 
 struct ring_buffer_event;
 
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmotm/kernel/trace/trace_objects.c	2010-12-26 20:59:41.000000000 +0800
@@ -0,0 +1,26 @@
+#include <linux/debugfs.h>
+
+#include "trace.h"
+#include "trace_output.h"
+
+struct dentry *trace_objects_dir(void)
+{
+	static struct dentry *d_objects;
+	struct dentry *d_tracer;
+
+	if (d_objects)
+		return d_objects;
+
+	d_tracer = tracing_init_dentry();
+	if (!d_tracer)
+		return NULL;
+
+	d_objects = debugfs_create_dir("objects", d_tracer);
+	if (!d_objects)
+		pr_warning("Could not create debugfs "
+			   "'objects' directory\n");
+
+	return d_objects;
+}
+
+
--- mmotm.orig/mm/page_alloc.c	2010-12-26 20:58:46.000000000 +0800
+++ mmotm/mm/page_alloc.c	2010-12-26 20:59:41.000000000 +0800
@@ -5493,7 +5493,7 @@ bool is_free_buddy_page(struct page *pag
 }
 #endif
 
-static struct trace_print_flags pageflag_names[] = {
+struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
 	{1UL << PG_error,		"error"		},
 	{1UL << PG_referenced,		"referenced"	},
@@ -5541,7 +5541,7 @@ static void dump_page_flags(unsigned lon
 	printk(KERN_ALERT "page flags: %#lx(", flags);
 
 	/* remove zone id */
-	flags &= (1UL << NR_PAGEFLAGS) - 1;
+	flags &= PAGE_FLAGS_MASK;
 
 	for (i = 0; pageflag_names[i].name && flags; i++) {
 
--- mmotm.orig/include/linux/page-flags.h	2010-12-26 20:58:46.000000000 +0800
+++ mmotm/include/linux/page-flags.h	2010-12-26 20:59:41.000000000 +0800
@@ -414,6 +414,7 @@ static inline void __ClearPageTail(struc
  * there has been a kernel bug or struct page corruption.
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_MASK			((1 << NR_PAGEFLAGS) - 1)
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
--- mmotm.orig/fs/inode.c	2010-12-26 20:58:45.000000000 +0800
+++ mmotm/fs/inode.c	2010-12-26 21:00:09.000000000 +0800
@@ -182,7 +182,13 @@ int inode_init_always(struct super_block
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
@@ -226,6 +232,9 @@ int inode_init_always(struct super_block
 
 	percpu_counter_inc(&nr_inodes);
 
+	BUILD_BUG_ON(sizeof(inode->i_comm) != TASK_COMM_LEN);
+	memcpy(inode->i_comm, current->comm, TASK_COMM_LEN);
+
 	return 0;
 out:
 	return -ENOMEM;
--- mmotm.orig/include/linux/fs.h	2010-12-26 20:59:50.000000000 +0800
+++ mmotm/include/linux/fs.h	2010-12-26 21:00:09.000000000 +0800
@@ -800,6 +800,8 @@ struct inode {
 	struct posix_acl	*i_default_acl;
 #endif
 	void			*i_private; /* fs or device private pointer */
+
+	char			i_comm[16]; /* first opened by */
 };
 
 static inline int inode_unhashed(struct inode *inode)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
