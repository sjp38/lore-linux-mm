Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CD5A56B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 00:38:27 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1I5cOgT031175
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Feb 2010 14:38:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32A7045DE82
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 14:38:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 07E6C45DE7B
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 14:38:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7930F1DB803A
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 14:38:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F1A9FE18014
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 14:38:19 +0900 (JST)
Date: Thu, 18 Feb 2010 14:34:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Message-Id: <20100218143429.ddea9bb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100208155450.GA17055@localhost>
References: <4B6B7FBF.9090005@bx.jp.nec.com>
	<20100205072858.GC9320@elte.hu>
	<20100208155450.GA17055@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Chris Frost <frost@cs.ucla.edu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Feb 2010 23:54:50 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Hi Ingo,
> 
> > Note that there's also these older experimental commits in tip:tracing/mm 
> > that introduce the notion of 'object collections' and adds the ability to 
> > trace them:
> > 
> > 3383e37: tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
> > c33b359: tracing, page-allocator: Add trace event for page traffic related to the buddy lists
> > 0d524fb: tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
> > b9a2817: tracing, page-allocator: Add trace events for page allocation and page freeing
> > 08b6cb8: perf_counter tools: Provide default bfd_demangle() function in case it's not around
> > eb46710: tracing/mm: rename 'trigger' file to 'dump_range'
> > 1487a7a: tracing/mm: fix mapcount trace record field
> > dcac8cd: tracing/mm: add page frame snapshot trace
> > 
> > this concept, if refreshed a bit and extended to the page cache, would allow 
> > the recording/snapshotting of the MM state of all currently present pages in 
> > the page-cache - a possibly nice addition to the dynamic technique you apply 
> > in your patches.
> > 
> > there's similar "object collections" work underway for 'perf lock' btw., by 
> > Hitoshi Mitake and Frederic.
> > 
> > So there's lots of common ground and lots of interest.
> 
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
> 
>         # time (cat /debug/tracing/trace > /dev/shm/t)
>         (; cat /debug/tracing/trace > /dev/shm/t; )  0.04s user 0.49s system 95% cpu 0.548 total
> 
>         # time (dd if=/debug/tracing/trace of=/dev/shm/t bs=1M)
>         0+138 records in
>         0+138 records out
>         551282 bytes (551 kB) copied, 0.380454 s, 1.4 MB/s
>         (; dd if=/debug/tracing/trace of=/dev/shm/t bs=1M; )  0.09s user 0.48s system 96% cpu 0.600 total
> 
> The patch is based on tip/tracing/mm. 
> 
> Thanks,
> Fengguang
> ---
> tracing: pagecache object collections
> 
> This dumps
> - all cached files of a mounted fs  (the inode-cache)
> - all cached pages of a cached file (the page-cache)
> 
> Usage and Sample output:
> 
> # echo / > /debug/tracing/objects/mm/pages/walk-fs
> # head /debug/tracing/trace
> 
> # tracer: nop
> #
> #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> #              | |       |          |         |
>              zsh-3078  [000]   526.272587: dump_inode: ino=102223 size=169291 cached=172032 age=9 dirty=6 dev=0:15 file=<TODO>
>              zsh-3078  [000]   526.274260: dump_pagecache_range: index=0 len=41 flags=10000000000002c count=1 mapcount=0
>              zsh-3078  [000]   526.274340: dump_pagecache_range: index=41 len=1 flags=10000000000006c count=1 mapcount=0
>              zsh-3078  [000]   526.274401: dump_inode: ino=8966 size=442 cached=4096 age=49 dirty=0 dev=0:15 file=<TODO>
>              zsh-3078  [000]   526.274425: dump_pagecache_range: index=0 len=1 flags=10000000000002c count=1 mapcount=0
>              zsh-3078  [000]   526.274440: dump_inode: ino=8964 size=4096 cached=0 age=49 dirty=0 dev=0:15 file=<TODO>
> 
> Here "age" is either age from inode create time, or from last dirty time.
> 
> TODO:
> 
> correctness
> - show file path name
>   XXX: can trace_seq_path() be called directly inside TRACE_EVENT()?
> - reliably prevent ring buffer overflow,
>   by replacing cond_resched() with some wait function
>   (eg. wait until 2+ pages are free in ring buffer)
> - use stable_page_flags() in recent kernel
> 
> output style
> - use plain tracing output format (no fancy TASK-PID/.../FUNCTION fields)
> - clear ring buffer before dumping the objects?
> - output format: key=value pairs ==> header + tabbed values?
> - add filtering options if necessary
> 

Can we dump page's cgroup ? If so, I'm happy.
Maybe
==
  struct page_cgroup *pc = lookup_page_cgroup(page);
  struct mem_cgroup *mem = pc->mem_cgroup;
  shodt mem_cgroup_id = mem->css.css_id;

  And statistics can be counted per css_id.

And then, some output like

dump_pagecache_range: index=0 len=1 flags=10000000000002c count=1 mapcount=0 file=XXX memcg=group_A:x,group_B:y

Is it okay to add a new field after your work finish ?

If so, I'll think about some infrastructure to get above based on your patch.

THanks,
-Kame





> CC: Ingo Molnar <mingo@elte.hu>
> CC: Chris Frost <frost@cs.ucla.edu>
> CC: Steven Rostedt <rostedt@goodmis.org>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/inode.c                |    2 
>  include/trace/events/mm.h |   67 ++++++++++++++
>  kernel/trace/trace_mm.c   |  165 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 233 insertions(+), 1 deletion(-)
> 
> --- linux-mm.orig/include/trace/events/mm.h	2010-02-08 23:19:09.000000000 +0800
> +++ linux-mm/include/trace/events/mm.h	2010-02-08 23:19:16.000000000 +0800
> @@ -2,6 +2,7 @@
>  #define _TRACE_MM_H
>  
>  #include <linux/tracepoint.h>
> +#include <linux/pagemap.h>
>  #include <linux/mm.h>
>  
>  #undef TRACE_SYSTEM
> @@ -42,6 +43,72 @@ TRACE_EVENT(dump_pages,
>  		  __entry->mapcount, __entry->index)
>  );
>  
> +TRACE_EVENT(dump_pagecache_range,
> +
> +	TP_PROTO(struct page *page, unsigned long len),
> +
> +	TP_ARGS(page, len),
> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	index		)
> +		__field(	unsigned long,	len		)
> +		__field(	unsigned long,	flags		)
> +		__field(	unsigned int,	count		)
> +		__field(	unsigned int,	mapcount	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->index		= page->index;
> +		__entry->len		= len;
> +		__entry->flags		= page->flags;
> +		__entry->count		= atomic_read(&page->_count);
> +		__entry->mapcount	= page_mapcount(page);
> +	),
> +
> +	TP_printk("index=%lu len=%lu flags=%lx count=%u mapcount=%u",
> +		  __entry->index,
> +		  __entry->len,
> +		  __entry->flags,
> +		  __entry->count,
> +		  __entry->mapcount)
> +);
> +
> +TRACE_EVENT(dump_inode,
> +
> +	TP_PROTO(struct inode *inode),
> +
> +	TP_ARGS(inode),
> +
> +	TP_STRUCT__entry(
> +		__field(	unsigned long,	ino		)
> +		__field(	loff_t,		size		)
> +		__field(	unsigned long,	nrpages		)
> +		__field(	unsigned long,	age		)
> +		__field(	unsigned long,	state		)
> +		__field(	dev_t,		dev		)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->ino		= inode->i_ino;
> +		__entry->size		= i_size_read(inode);
> +		__entry->nrpages	= inode->i_mapping->nrpages;
> +		__entry->age		= jiffies - inode->dirtied_when;
> +		__entry->state		= inode->i_state;
> +		__entry->dev		= inode->i_sb->s_dev;
> +	),
> +
> +	TP_printk("ino=%lu size=%llu cached=%lu age=%lu dirty=%lu "
> +		  "dev=%u:%u file=<TODO>",
> +		  __entry->ino,
> +		  __entry->size,
> +		  __entry->nrpages << PAGE_CACHE_SHIFT,
> +		  __entry->age / HZ,
> +		  __entry->state & I_DIRTY,
> +		  MAJOR(__entry->dev),
> +		  MINOR(__entry->dev))
> +);
> +
> +
>  #endif /*  _TRACE_MM_H */
>  
>  /* This part must be outside protection */
> --- linux-mm.orig/kernel/trace/trace_mm.c	2010-02-08 23:19:09.000000000 +0800
> +++ linux-mm/kernel/trace/trace_mm.c	2010-02-08 23:19:16.000000000 +0800
> @@ -9,6 +9,9 @@
>  #include <linux/bootmem.h>
>  #include <linux/debugfs.h>
>  #include <linux/uaccess.h>
> +#include <linux/pagevec.h>
> +#include <linux/writeback.h>
> +#include <linux/file.h>
>  
>  #include "trace_output.h"
>  
> @@ -95,6 +98,162 @@ static const struct file_operations trac
>  	.write		= trace_mm_dump_range_write,
>  };
>  
> +static unsigned long page_flags(struct page* page)
> +{
> +	return page->flags & ((1 << NR_PAGEFLAGS) - 1);
> +}
> +
> +static int pages_similiar(struct page* page0, struct page* page)
> +{
> +	if (page_count(page0) != page_count(page))
> +		return 0;
> +
> +	if (page_mapcount(page0) != page_mapcount(page))
> +		return 0;
> +
> +	if (page_flags(page0) != page_flags(page))
> +		return 0;
> +
> +	return 1;
> +}
> +
> +#define BATCH_LINES	100
> +static void dump_pagecache(struct address_space *mapping)
> +{
> +	int i;
> +	int lines = 0;
> +	pgoff_t len = 0;
> +	struct pagevec pvec;
> +	struct page *page;
> +	struct page *page0 = NULL;
> +	unsigned long start = 0;
> +
> +	for (;;) {
> +		pagevec_init(&pvec, 0);
> +		pvec.nr = radix_tree_gang_lookup(&mapping->page_tree,
> +				(void **)pvec.pages, start + len, PAGEVEC_SIZE);
> +
> +		if (pvec.nr == 0) {
> +			if (len)
> +				trace_dump_pagecache_range(page0, len);
> +			break;
> +		}
> +
> +		if (!page0)
> +			page0 = pvec.pages[0];
> +
> +		for (i = 0; i < pvec.nr; i++) {
> +			page = pvec.pages[i];
> +
> +			if (page->index == start + len &&
> +					pages_similiar(page0, page))
> +				len++;
> +			else {
> +				trace_dump_pagecache_range(page0, len);
> +				page0 = page;
> +				start = page->index;
> +				len = 1;
> +				if (++lines > BATCH_LINES) {
> +					lines = 0;
> +					cond_resched();
> +				}
> +			}
> +		}
> +	}
> +}
> +
> +static void dump_fs_pagecache(struct super_block *sb)
> +{
> +	struct inode *inode;
> +	struct inode *prev_inode = NULL;
> +
> +	down_read(&sb->s_umount);
> +	if (!sb->s_root)
> +		goto out;
> +	spin_lock(&inode_lock);
> +	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> +		if (inode->i_state & (I_FREEING|I_CLEAR|I_WILL_FREE|I_NEW))
> +			continue;
> +		__iget(inode);
> +		spin_unlock(&inode_lock);
> +		trace_dump_inode(inode);
> +		if (inode->i_mapping->nrpages)
> +			dump_pagecache(inode->i_mapping);
> +		iput(prev_inode);
> +		prev_inode = inode;
> +		cond_resched();
> +		spin_lock(&inode_lock);
> +	}
> +	spin_unlock(&inode_lock);
> +	iput(prev_inode);
> +out:
> +	up_read(&sb->s_umount);
> +}
> +
> +static ssize_t
> +trace_pagecache_write(struct file *filp, const char __user *ubuf, size_t count,
> +		      loff_t *ppos)
> +{
> +	struct file *file = NULL;
> +	char *name;
> +	int err = 0;
> +
> +	if (count > PATH_MAX + 1)
> +		return -ENAMETOOLONG;
> +
> +	name = kmalloc(count+1, GFP_KERNEL);
> +	if (!name)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(name, ubuf, count)) {
> +		err = -EFAULT;
> +		goto out;
> +	}
> +
> +	/* strip the newline added by `echo` */
> +	if (count)
> +		name[count-1] = '\0';
> +
> +	file = filp_open(name, O_RDONLY|O_LARGEFILE, 0);
> +	if (IS_ERR(file)) {
> +		err = PTR_ERR(file);
> +		file = NULL;
> +		goto out;
> +	}
> +
> +	if (tracing_update_buffers() < 0) {
> +		err = -ENOMEM;
> +		goto out;
> +	}
> +	if (trace_set_clr_event("mm", "dump_pagecache_range", 1)) {
> +		err = -EINVAL;
> +		goto out;
> +	}
> +	if (trace_set_clr_event("mm", "dump_inode", 1)) {
> +		err = -EINVAL;
> +		goto out;
> +	}
> +
> +	if (filp->f_path.dentry->d_inode->i_private) {
> +		dump_fs_pagecache(file->f_path.dentry->d_sb);
> +	} else {
> +		dump_pagecache(file->f_mapping);
> +	}
> +
> +out:
> +	if (file)
> +		fput(file);
> +	kfree(name);
> +
> +	return err ? err : count;
> +}
> +
> +static const struct file_operations trace_pagecache_fops = {
> +	.open		= tracing_open_generic,
> +	.read		= trace_mm_dump_range_read,
> +	.write		= trace_pagecache_write,
> +};
> +
>  /* move this into trace_objects.c when that file is created */
>  static struct dentry *trace_objects_dir(void)
>  {
> @@ -167,6 +326,12 @@ static __init int trace_objects_mm_init(
>  	trace_create_file("dump_range", 0600, d_pages, NULL,
>  			  &trace_mm_fops);
>  
> +	trace_create_file("walk-file", 0600, d_pages, NULL,
> +			  &trace_pagecache_fops);
> +
> +	trace_create_file("walk-fs", 0600, d_pages, (void *)1,
> +			  &trace_pagecache_fops);
> +
>  	return 0;
>  }
>  fs_initcall(trace_objects_mm_init);
> --- linux-mm.orig/fs/inode.c	2010-02-08 23:19:12.000000000 +0800
> +++ linux-mm/fs/inode.c	2010-02-08 23:19:22.000000000 +0800
> @@ -149,7 +149,7 @@ struct inode *inode_init_always(struct s
>  	inode->i_bdev = NULL;
>  	inode->i_cdev = NULL;
>  	inode->i_rdev = 0;
> -	inode->dirtied_when = 0;
> +	inode->dirtied_when = jiffies;
>  
>  	if (security_inode_alloc(inode))
>  		goto out_free_inode;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
