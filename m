From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/11] readahead: add /debug/readahead/stats
Date: Sun, 07 Feb 2010 12:10:22 +0800
Message-ID: <20100207041044.003502719@intel.com>
References: <20100207041013.891441102@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=readahead-stats.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Collect readahead stats when CONFIG_READAHEAD_STATS=y.

This is enabled by default because the added overheads are trivial:
two readahead_stats() calls per readahead.

Example output:
(taken from a fresh booted NFS-ROOT box with rsize=16k)

$ cat /debug/readahead/stats
pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io       size async_size    io_size
initial           524        216         26        498        498         18          7          4          4
subsequent        181         80          1        130         13         60         25         25         24
context            94         28          3         85         64          8          7          2          5
thrash              0          0          0          0          0          0          0          0          0
around            162        121         33        162        162        162         60          0         21
fadvise             0          0          0          0          0          0          0          0          0
random            137          0          0        137        137          0          1          0          1
all              1098        445         63       1012        874          0         17          6          9

The two most important columns are
- io		number of readahead IO
- io_size	average readahead IO size

CC: Ingo Molnar <mingo@elte.hu> 
CC: Jens Axboe <jens.axboe@oracle.com> 
CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/Kconfig     |   13 +++
 mm/readahead.c |  177 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 188 insertions(+), 2 deletions(-)

--- linux.orig/mm/readahead.c	2010-02-01 21:55:46.000000000 +0800
+++ linux/mm/readahead.c	2010-02-01 21:57:07.000000000 +0800
@@ -38,6 +38,179 @@ const char * const ra_pattern_names[] = 
 	[RA_PATTERN_ALL]		= "all",
 };
 
+#ifdef CONFIG_READAHEAD_STATS
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+enum ra_account {
+	/* number of readaheads */
+	RA_ACCOUNT_COUNT,	/* readahead request */
+	RA_ACCOUNT_EOF,		/* readahead request contains/beyond EOF page */
+	RA_ACCOUNT_CHIT,	/* readahead request covers some cached pages */
+	RA_ACCOUNT_IOCOUNT,	/* readahead IO */
+	RA_ACCOUNT_SYNC,	/* readahead IO that is synchronous */
+	RA_ACCOUNT_MMAP,	/* readahead IO by mmap accesses */
+	/* number of readahead pages */
+	RA_ACCOUNT_SIZE,	/* readahead size */
+	RA_ACCOUNT_ASIZE,	/* readahead async size */
+	RA_ACCOUNT_ACTUAL,	/* readahead actual IO size */
+	/* end mark */
+	RA_ACCOUNT_MAX,
+};
+
+static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+
+static void readahead_stats(struct address_space *mapping,
+			    pgoff_t offset,
+			    unsigned long req_size,
+			    unsigned int ra_flags,
+			    pgoff_t start,
+			    unsigned int size,
+			    unsigned int async_size,
+			    int actual)
+{
+	unsigned int pattern = ra_pattern(ra_flags);
+
+	ra_stats[pattern][RA_ACCOUNT_COUNT]++;
+	ra_stats[pattern][RA_ACCOUNT_SIZE] += size;
+	ra_stats[pattern][RA_ACCOUNT_ASIZE] += async_size;
+	ra_stats[pattern][RA_ACCOUNT_ACTUAL] += actual;
+
+	if (actual < size) {
+		if (start + size >
+		    (i_size_read(mapping->host) - 1) >> PAGE_CACHE_SHIFT)
+			ra_stats[pattern][RA_ACCOUNT_EOF]++;
+		else
+			ra_stats[pattern][RA_ACCOUNT_CHIT]++;
+	}
+
+	if (!actual)
+		return;
+
+	ra_stats[pattern][RA_ACCOUNT_IOCOUNT]++;
+
+	if (start <= offset && start + size > offset)
+		ra_stats[pattern][RA_ACCOUNT_SYNC]++;
+
+	if (ra_flags & READAHEAD_MMAP)
+		ra_stats[pattern][RA_ACCOUNT_MMAP]++;
+}
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	unsigned long i;
+	unsigned long count, iocount;
+
+	seq_printf(s, "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
+			"pattern",
+			"readahead", "eof_hit", "cache_hit",
+			"io", "sync_io", "mmap_io",
+			"size", "async_size", "io_size");
+
+	for (i = 0; i < RA_PATTERN_MAX; i++) {
+		count = ra_stats[i][RA_ACCOUNT_COUNT];
+		iocount = ra_stats[i][RA_ACCOUNT_IOCOUNT];
+		/*
+		 * avoid division-by-zero
+		 */
+		if (count == 0)
+			count = 1;
+		if (iocount == 0)
+			iocount = 1;
+
+		seq_printf(s, "%-10s %10lu %10lu %10lu %10lu %10lu %10lu "
+			   "%10lu %10lu %10lu\n",
+				ra_pattern_names[i],
+				ra_stats[i][RA_ACCOUNT_COUNT],
+				ra_stats[i][RA_ACCOUNT_EOF],
+				ra_stats[i][RA_ACCOUNT_CHIT],
+				ra_stats[i][RA_ACCOUNT_IOCOUNT],
+				ra_stats[i][RA_ACCOUNT_SYNC],
+				ra_stats[i][RA_ACCOUNT_MMAP],
+				ra_stats[i][RA_ACCOUNT_SIZE]   / count,
+				ra_stats[i][RA_ACCOUNT_ASIZE]  / count,
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
+static struct file_operations readahead_stats_fops = {
+	.owner		= THIS_MODULE,
+	.open		= readahead_stats_open,
+	.write		= readahead_stats_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *ra_debug_root;
+
+static int debugfs_create_readahead(void)
+{
+	struct dentry *debugfs_stats;
+
+	ra_debug_root = debugfs_create_dir("readahead", NULL);
+	if (!ra_debug_root)
+		goto out;
+
+	debugfs_stats = debugfs_create_file("stats", 0644, ra_debug_root,
+					    NULL, &readahead_stats_fops);
+	if (!debugfs_stats)
+		goto out;
+
+	return 0;
+out:
+	printk(KERN_ERR "readahead: failed to create debugfs entries\n");
+	return -ENOMEM;
+}
+
+static int __init readahead_init(void)
+{
+	debugfs_create_readahead();
+	return 0;
+}
+
+static void __exit readahead_exit(void)
+{
+	debugfs_remove_recursive(ra_debug_root);
+}
+
+module_init(readahead_init);
+module_exit(readahead_exit);
+#endif
+
+static void readahead_event(struct address_space *mapping,
+			    pgoff_t offset,
+			    unsigned long req_size,
+			    unsigned int ra_flags,
+			    pgoff_t start,
+			    unsigned int size,
+			    unsigned int async_size,
+			    unsigned int actual)
+{
+#ifdef CONFIG_READAHEAD_STATS
+	readahead_stats(mapping, offset, req_size, ra_flags,
+			start, size, async_size, actual);
+	readahead_stats(mapping, offset, req_size,
+			RA_PATTERN_ALL << READAHEAD_PATTERN_SHIFT,
+			start, size, async_size, actual);
+#endif
+	trace_readahead(mapping, offset, req_size, ra_flags,
+			start, size, async_size, actual);
+}
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
@@ -289,7 +462,7 @@ int force_page_cache_readahead(struct ad
 		nr_to_read -= this_chunk;
 	}
 
-	trace_readahead(mapping, offset, nr_to_read,
+	readahead_event(mapping, offset, nr_to_read,
 			RA_PATTERN_FADVISE << READAHEAD_PATTERN_SHIFT,
 			offset, nr_to_read, 0, ret);
 
@@ -320,7 +493,7 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
-	trace_readahead(mapping, offset, req_size, ra->ra_flags,
+	readahead_event(mapping, offset, req_size, ra->ra_flags,
 			ra->start, ra->size, ra->async_size, actual);
 
 	return actual;
--- linux.orig/mm/Kconfig	2010-02-01 21:55:28.000000000 +0800
+++ linux/mm/Kconfig	2010-02-01 21:55:49.000000000 +0800
@@ -283,3 +283,16 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config READAHEAD_STATS
+	bool "Collect page-cache readahead stats"
+	depends on DEBUG_FS
+	default y
+	help
+	  Enable readahead events accounting. Usage:
+
+	  # mount -t debugfs none /debug
+
+	  # echo > /debug/readahead/stats  # reset counters
+	  # do benchmarks
+	  # cat /debug/readahead/stats     # check counters
