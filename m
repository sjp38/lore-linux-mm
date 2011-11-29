Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C5AB6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 01:44:24 -0500 (EST)
Date: Tue, 29 Nov 2011 14:41:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-ID: <20111129064109.GA8612@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.636765408@intel.com>
 <20111121152958.e4fd76d4.akpm@linux-foundation.org>
 <20111129032323.GC19506@localhost>
 <20111128204950.29404d0b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128204950.29404d0b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Tue, Nov 29, 2011 at 12:49:50PM +0800, Andrew Morton wrote:
> On Tue, 29 Nov 2011 11:23:23 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > > +{
> > > > +#ifdef CONFIG_READAHEAD_STATS
> > > > +	if (readahead_stats_enable) {
> > > > +		readahead_stats(mapping, offset, req_size, ra_flags,
> > > > +				start, size, async_size, actual);
> > > > +		readahead_stats(mapping, offset, req_size,
> > > > +				RA_PATTERN_ALL << READAHEAD_PATTERN_SHIFT,
> > > > +				start, size, async_size, actual);
> > > > +	}
> > > > +#endif
> > > > +}
> > > 
> > > The stub should be inlined, methinks.  The overhead of evaluating and
> > > preparing eight arguments is significant.  I don't think the compiler
> > > is yet smart enough to save us.
> > 
> > The parameter list actually becomes even out of control when doing the
> > bit fields:
> > 
> > +       readahead_event(mapping, offset, req_size,
> > +                       ra->pattern, ra->for_mmap, ra->for_metadata,
> > +                       ra->start + ra->size >= eof,
> > +                       ra->start, ra->size, ra->async_size, actual);
> > 
> > So I end up passing file_ra_state around. The added cost is, I'll have
> > to dynamically create a file_ra_state for the fadvise case, which
> > should be acceptable since it's a cold path.
> 
> That will reduce the cost of something which would have zero cost by
> making this function a static inline when CONFIG_READAHEAD_STATS=n.

What I do now is to remove the readahead_event() function altogether,
as done by the below patch.

Do you suggest to remove fadvise_ra and still passing the many raw
values to readahead_stats()? (need to restore the inline function
readahead_event() because there will be two call sites)

Thanks,
Fengguang
---
Subject: readahead: add /debug/readahead/stats
Date: Sun Nov 20 11:25:50 CST 2011

The accounting code will be compiled in by default (CONFIG_READAHEAD_STATS=y),
and will remain inactive by default.

It can be runtime enabled/disabled through the debugfs interface

	echo 1 > /debug/readahead/stats_enable
	echo 0 > /debug/readahead/stats_enable

The added overheads are two readahead_stats() calls per readahead.
Which is trivial costs unless there are concurrent random reads on
super fast SSDs, which may lead to cache bouncing when updating the
global ra_stats[][]. Considering that normal users won't need this
except when debugging performance problems, it's disabled by default.
So it looks reasonable to keep this debug code simple rather than trying
to improve its scalability.

Example output:
(taken from a fresh booted NFS-ROOT console box with rsize=524288)

$ cat /debug/readahead/stats
pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io    meta_io       size async_size    io_size
initial           702        511          0        692        692          0          0          2          0          2
subsequent          7          0          1          7          1          1          0         23         22         23
context           160        161          0          2          0          1          0          0          0         16
around            184        184        177        184        184        184          0         58          0         53
backwards           2          0          2          2          2          0          0          4          0          3
fadvise          2593         47          8       2588       2588          0          0          1          0          1
oversize            0          0          0          0          0          0          0          0          0          0
random             45         20          0         44         44          0          0          1          0          1
all              3697        923        188       3519       3511        186          0          4          0          4

The two most important columns are
- io		number of readahead IO
- io_size	average readahead IO size

CC: Ingo Molnar <mingo@elte.hu>
CC: Jens Axboe <axboe@kernel.dk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/Kconfig     |   15 +++
 mm/readahead.c |  183 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 196 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/readahead.c	2011-11-29 14:14:36.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-29 14:24:25.000000000 +0800
@@ -18,6 +18,17 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+static const char * const ra_pattern_names[] = {
+	[RA_PATTERN_INITIAL]            = "initial",
+	[RA_PATTERN_SUBSEQUENT]         = "subsequent",
+	[RA_PATTERN_CONTEXT]            = "context",
+	[RA_PATTERN_MMAP_AROUND]        = "around",
+	[RA_PATTERN_FADVISE]            = "fadvise",
+	[RA_PATTERN_OVERSIZE]           = "oversize",
+	[RA_PATTERN_RANDOM]             = "random",
+	[RA_PATTERN_ALL]                = "all",
+};
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
@@ -32,6 +43,167 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
 
 #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+#ifdef CONFIG_READAHEAD_STATS
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+
+static u32 readahead_stats_enable __read_mostly;
+
+enum ra_account {
+	/* number of readaheads */
+	RA_ACCOUNT_COUNT,	/* readahead request */
+	RA_ACCOUNT_EOF,		/* readahead request covers EOF */
+	RA_ACCOUNT_CACHE_HIT,	/* readahead request covers some cached pages */
+	RA_ACCOUNT_IOCOUNT,	/* readahead IO */
+	RA_ACCOUNT_SYNC,	/* readahead IO that is synchronous */
+	RA_ACCOUNT_MMAP,	/* readahead IO by mmap page faults */
+	RA_ACCOUNT_METADATA,	/* readahead IO on metadata */
+	/* number of readahead pages */
+	RA_ACCOUNT_SIZE,	/* readahead size */
+	RA_ACCOUNT_ASYNC_SIZE,	/* readahead async size */
+	RA_ACCOUNT_ACTUAL,	/* readahead actual IO size */
+	/* end mark */
+	RA_ACCOUNT_MAX,
+};
+
+static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+
+static inline void readahead_stats(struct file_ra_state *ra,
+				   struct address_space *mapping,
+				   pgoff_t offset,
+				   unsigned long req_size,
+				   pgoff_t eof,
+				   int actual)
+{
+	enum readahead_pattern pattern = ra->pattern;
+
+recount:
+	ra_stats[pattern][RA_ACCOUNT_COUNT]++;
+	ra_stats[pattern][RA_ACCOUNT_SIZE] += ra->size;
+	ra_stats[pattern][RA_ACCOUNT_ASYNC_SIZE] += ra->async_size;
+	ra_stats[pattern][RA_ACCOUNT_ACTUAL] += actual;
+
+	if (ra->start + ra->size >= eof)
+		ra_stats[pattern][RA_ACCOUNT_EOF]++;
+	if (actual < ra->size)
+		ra_stats[pattern][RA_ACCOUNT_CACHE_HIT]++;
+
+	if (actual) {
+		ra_stats[pattern][RA_ACCOUNT_IOCOUNT]++;
+
+		if (ra->start <= offset && offset < ra->start + ra->size)
+			ra_stats[pattern][RA_ACCOUNT_SYNC]++;
+
+		if (ra->for_mmap)
+			ra_stats[pattern][RA_ACCOUNT_MMAP]++;
+		if (ra->for_metadata)
+			ra_stats[pattern][RA_ACCOUNT_METADATA]++;
+	}
+
+	if (pattern != RA_PATTERN_ALL) {
+		pattern = RA_PATTERN_ALL;
+		goto recount;
+	}
+}
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	unsigned long i;
+
+	seq_printf(s,
+		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
+		   "pattern", "readahead", "eof_hit", "cache_hit",
+		   "io", "sync_io", "mmap_io", "meta_io",
+		   "size", "async_size", "io_size");
+
+	for (i = 0; i < RA_PATTERN_MAX; i++) {
+		unsigned long count = ra_stats[i][RA_ACCOUNT_COUNT];
+		unsigned long iocount = ra_stats[i][RA_ACCOUNT_IOCOUNT];
+		/*
+		 * avoid division-by-zero
+		 */
+		if (count == 0)
+			count = 1;
+		if (iocount == 0)
+			iocount = 1;
+
+		seq_printf(s, "%-10s %10lu %10lu %10lu %10lu %10lu "
+			   "%10lu %10lu %10lu %10lu %10lu\n",
+				ra_pattern_names[i],
+				ra_stats[i][RA_ACCOUNT_COUNT],
+				ra_stats[i][RA_ACCOUNT_EOF],
+				ra_stats[i][RA_ACCOUNT_CACHE_HIT],
+				ra_stats[i][RA_ACCOUNT_IOCOUNT],
+				ra_stats[i][RA_ACCOUNT_SYNC],
+				ra_stats[i][RA_ACCOUNT_MMAP],
+				ra_stats[i][RA_ACCOUNT_METADATA],
+				ra_stats[i][RA_ACCOUNT_SIZE] / count,
+				ra_stats[i][RA_ACCOUNT_ASYNC_SIZE] / count,
+				ra_stats[i][RA_ACCOUNT_ACTUAL] / iocount);
+	}
+
+	return 0;
+}
+
+static int readahead_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, readahead_stats_show, NULL);
+}
+
+static ssize_t readahead_stats_write(struct file *file, const char __user *buf,
+				     size_t size, loff_t *offset)
+{
+	memset(ra_stats, 0, sizeof(ra_stats));
+	return size;
+}
+
+static const struct file_operations readahead_stats_fops = {
+	.owner		= THIS_MODULE,
+	.open		= readahead_stats_open,
+	.write		= readahead_stats_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int __init readahead_create_debugfs(void)
+{
+	struct dentry *root;
+	struct dentry *entry;
+
+	root = debugfs_create_dir("readahead", NULL);
+	if (!root)
+		goto out;
+
+	entry = debugfs_create_file("stats", 0644, root,
+				    NULL, &readahead_stats_fops);
+	if (!entry)
+		goto out;
+
+	entry = debugfs_create_bool("stats_enable", 0644, root,
+				    &readahead_stats_enable);
+	if (!entry)
+		goto out;
+
+	return 0;
+out:
+	printk(KERN_ERR "readahead: failed to create debugfs entries\n");
+	return -ENOMEM;
+}
+
+late_initcall(readahead_create_debugfs);
+#else
+#define readahead_stats_enable	0
+static inline void readahead_stats(struct file_ra_state *ra,
+				   struct address_space *mapping,
+				   pgoff_t offset,
+				   unsigned long req_size,
+				   pgoff_t eof,
+				   int actual)
+{
+}
+#endif
+
 /*
  * see if a page needs releasing upon read_cache_pages() failure
  * - the caller of read_cache_pages() may have set PG_private or PG_fscache
@@ -209,6 +381,9 @@ out:
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		pgoff_t offset, unsigned long nr_to_read)
 {
+	struct file_ra_state fadvice_ra = {
+		.pattern	= RA_PATTERN_FADVISE,
+	};
 	int ret = 0;
 
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
@@ -222,8 +397,9 @@ int force_page_cache_readahead(struct ad
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
-		err = __do_page_cache_readahead(mapping, filp,
-						offset, this_chunk, 0);
+		fadvice_ra.start = offset;
+		fadvice_ra.size = this_chunk;
+		err = ra_submit(&fadvice_ra, mapping, filp, offset, nr_to_read);
 		if (err < 0) {
 			ret = err;
 			break;
@@ -267,6 +443,9 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	if (readahead_stats_enable)
+		readahead_stats(ra, mapping, offset, req_size, eof, actual);
+
 	ra->for_mmap = 0;
 	ra->for_metadata = 0;
 	return actual;
--- linux-next.orig/mm/Kconfig	2011-11-29 14:14:25.000000000 +0800
+++ linux-next/mm/Kconfig	2011-11-29 14:14:37.000000000 +0800
@@ -373,3 +373,18 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config READAHEAD_STATS
+	bool "Collect page cache readahead stats"
+	depends on DEBUG_FS
+	default y
+	help
+	  This provides the readahead events accounting facilities.
+
+	  To do readahead accounting for a workload:
+
+	  echo 1 > /sys/kernel/debug/readahead/stats_enable
+	  echo 0 > /sys/kernel/debug/readahead/stats  # reset counters
+	  # run the workload
+	  cat /sys/kernel/debug/readahead/stats       # check counters
+	  echo 0 > /sys/kernel/debug/readahead/stats_enable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
