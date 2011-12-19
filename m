Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6F9FA6B006E
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 05:36:37 -0500 (EST)
Message-Id: <20111219102357.412324016@intel.com>
Date: Mon, 19 Dec 2011 18:23:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/10] readahead: add /debug/readahead/stats
References: <20111219102308.488847921@intel.com>
Content-Disposition: inline; filename=readahead-stats.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

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
 mm/readahead.c |  193 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 208 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-12-16 19:59:36.000000000 +0800
+++ linux-next/mm/readahead.c	2011-12-16 20:00:37.000000000 +0800
@@ -33,6 +33,193 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
 
 #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+#ifdef CONFIG_READAHEAD_STATS
+#include <linux/ftrace_event.h>
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+
+static u32 readahead_stats_enable __read_mostly;
+
+static const struct trace_print_flags ra_pattern_names[] = {
+	READAHEAD_PATTERNS
+};
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
+static DEFINE_PER_CPU(unsigned long[RA_PATTERN_ALL][RA_ACCOUNT_MAX], ra_stat);
+
+static void readahead_stats(struct address_space *mapping,
+			    pgoff_t offset,
+			    unsigned long req_size,
+			    bool for_mmap,
+			    bool for_metadata,
+			    enum readahead_pattern pattern,
+			    pgoff_t start,
+			    unsigned long size,
+			    unsigned long async_size,
+			    int actual)
+{
+	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
+
+	preempt_disable();
+
+	__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_COUNT]);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_SIZE], size);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ASYNC_SIZE], async_size);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ACTUAL], actual);
+
+	if (start + size >= eof)
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_EOF]);
+	if (actual < size)
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_CACHE_HIT]);
+
+	if (actual) {
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_IOCOUNT]);
+
+		if (start <= offset && offset < start + size)
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_SYNC]);
+
+		if (for_mmap)
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_MMAP]);
+		if (for_metadata)
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_METADATA]);
+	}
+
+	preempt_enable();
+}
+
+static void ra_stats_clear(void)
+{
+	int cpu;
+	int i, j;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < RA_PATTERN_ALL; i++)
+			for (j = 0; j < RA_ACCOUNT_MAX; j++)
+				per_cpu(ra_stat[i][j], cpu) = 0;
+}
+
+static void ra_stats_sum(unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX])
+{
+	int cpu;
+	int i, j;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < RA_PATTERN_ALL; i++)
+			for (j = 0; j < RA_ACCOUNT_MAX; j++) {
+				unsigned long n = per_cpu(ra_stat[i][j], cpu);
+				ra_stats[i][j] += n;
+				ra_stats[RA_PATTERN_ALL][j] += n;
+			}
+}
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	unsigned long i;
+	unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+
+	seq_printf(s,
+		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
+		   "pattern", "readahead", "eof_hit", "cache_hit",
+		   "io", "sync_io", "mmap_io", "meta_io",
+		   "size", "async_size", "io_size");
+
+	memset(ra_stats, 0, sizeof(ra_stats));
+	ra_stats_sum(ra_stats);
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
+				ra_pattern_names[i].name,
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
+	ra_stats_clear();
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
+#endif
+
 static inline void readahead_event(struct address_space *mapping,
 				   pgoff_t offset,
 				   unsigned long req_size,
@@ -44,6 +231,12 @@ static inline void readahead_event(struc
 				   unsigned long async_size,
 				   int actual)
 {
+#ifdef CONFIG_READAHEAD_STATS
+	if (readahead_stats_enable)
+		readahead_stats(mapping, offset, req_size,
+				for_mmap, for_metadata,
+				pattern, start, size, async_size, actual);
+#endif
 	trace_readahead(mapping, offset, req_size,
 			pattern, start, size, async_size, actual);
 }
--- linux-next.orig/mm/Kconfig	2011-12-16 19:59:36.000000000 +0800
+++ linux-next/mm/Kconfig	2011-12-16 19:59:44.000000000 +0800
@@ -396,3 +396,18 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
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
