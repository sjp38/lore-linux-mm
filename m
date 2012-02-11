Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id DDA846B13F6
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 04:51:11 -0500 (EST)
Message-Id: <20120211043326.189942131@intel.com>
Date: Sat, 11 Feb 2012 12:31:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/9] readahead: add /debug/readahead/stats
References: <20120211043140.108656864@intel.com>
Content-Disposition: inline; filename=readahead-stats.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This accounting code won't be compiled by default (CONFIG_READAHEAD_STATS=n).

It's expected to be runtime reset and enabled before using:

	echo 0 > /debug/readahead/stats		# reset counters
	echo 1 > /debug/readahead/stats_enable
	# run test workload
	echo 0 > /debug/readahead/stats_enable

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
 mm/readahead.c |  202 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 217 insertions(+)

--- linux-next.orig/mm/readahead.c	2012-02-11 12:02:02.000000000 +0800
+++ linux-next/mm/readahead.c	2012-02-11 12:02:08.000000000 +0800
@@ -33,6 +33,202 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
 
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
+#define RA_STAT_BATCH	(INT_MAX / 2)
+static struct percpu_counter ra_stat[RA_PATTERN_ALL][RA_ACCOUNT_MAX];
+
+static inline void add_ra_stat(int i, int j, s64 amount)
+{
+	__percpu_counter_add(&ra_stat[i][j], amount, RA_STAT_BATCH);
+}
+
+static inline void inc_ra_stat(int i, int j)
+{
+	add_ra_stat(i, j, 1);
+}
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
+	inc_ra_stat(pattern, RA_ACCOUNT_COUNT);
+	add_ra_stat(pattern, RA_ACCOUNT_SIZE, size);
+	add_ra_stat(pattern, RA_ACCOUNT_ASYNC_SIZE, async_size);
+	add_ra_stat(pattern, RA_ACCOUNT_ACTUAL, actual);
+
+	if (start + size >= eof)
+		inc_ra_stat(pattern, RA_ACCOUNT_EOF);
+	if (actual < size)
+		inc_ra_stat(pattern, RA_ACCOUNT_CACHE_HIT);
+
+	if (actual) {
+		inc_ra_stat(pattern, RA_ACCOUNT_IOCOUNT);
+
+		if (start <= offset && offset < start + size)
+			inc_ra_stat(pattern, RA_ACCOUNT_SYNC);
+
+		if (for_mmap)
+			inc_ra_stat(pattern, RA_ACCOUNT_MMAP);
+		if (for_metadata)
+			inc_ra_stat(pattern, RA_ACCOUNT_METADATA);
+	}
+}
+
+static void readahead_stats_reset(void)
+{
+	int i, j;
+
+	for (i = 0; i < RA_PATTERN_ALL; i++)
+		for (j = 0; j < RA_ACCOUNT_MAX; j++)
+			percpu_counter_set(&ra_stat[i][j], 0);
+}
+
+static void
+readahead_stats_sum(long long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX])
+{
+	int i, j;
+
+	for (i = 0; i < RA_PATTERN_ALL; i++)
+		for (j = 0; j < RA_ACCOUNT_MAX; j++) {
+			s64 n = percpu_counter_sum(&ra_stat[i][j]);
+			ra_stats[i][j] += n;
+			ra_stats[RA_PATTERN_ALL][j] += n;
+		}
+}
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	long long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+	int i;
+
+	seq_printf(s,
+		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
+		   "pattern", "readahead", "eof_hit", "cache_hit",
+		   "io", "sync_io", "mmap_io", "meta_io",
+		   "size", "async_size", "io_size");
+
+	memset(ra_stats, 0, sizeof(ra_stats));
+	readahead_stats_sum(ra_stats);
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
+		seq_printf(s, "%-10s %10lld %10lld %10lld %10lld %10lld "
+			   "%10lld %10lld %10lld %10lld %10lld\n",
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
+	readahead_stats_reset();
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
+	int i, j;
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
+	for (i = 0; i < RA_PATTERN_ALL; i++)
+		for (j = 0; j < RA_ACCOUNT_MAX; j++)
+			percpu_counter_init(&ra_stat[i][j], 0);
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
@@ -44,6 +240,12 @@ static inline void readahead_event(struc
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
--- linux-next.orig/mm/Kconfig	2012-02-08 18:46:04.000000000 +0800
+++ linux-next/mm/Kconfig	2012-02-11 12:03:14.000000000 +0800
@@ -396,3 +396,18 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
+
+config READAHEAD_STATS
+	bool "Collect page cache readahead stats"
+	depends on DEBUG_FS
+	default n
+	help
+	  This provides the readahead events accounting facilities.
+
+	  To do readahead accounting for a workload:
+
+	  echo 0 > /sys/kernel/debug/readahead/stats  # reset counters
+	  echo 1 > /sys/kernel/debug/readahead/stats_enable
+	  # run the workload
+	  echo 0 > /sys/kernel/debug/readahead/stats_enable
+	  cat /sys/kernel/debug/readahead/stats       # check counters


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
