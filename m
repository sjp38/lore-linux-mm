Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D2DF6B0080
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 04:40:59 -0500 (EST)
Message-Id: <20111121093846.636765408@intel.com>
Date: Mon, 21 Nov 2011 17:18:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/8] readahead: add /debug/readahead/stats
References: <20111121091819.394895091@intel.com>
Content-Disposition: inline; filename=readahead-stats.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

The accounting code will be compiled in by default (CONFIG_READAHEAD_STATS=y),
and will remain inactive unless enabled explicitly with either boot option

	readahead_stats=1

or through the debugfs interface

	echo 1 > /debug/readahead/stats_enable

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
pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io       size async_size    io_size
initial           545        347         10        535        535          0         74         38          3
subsequent         48         41          1         11          1          5         53         53         15
context           156        156          0          3          0          1       1690       1690         12
around            152        152          0        152        152        152       1920        480         45
backwards           2          0          2          2          2          0          4          0          3
fadvise          2566          0          0       2566          0          0          0          0          1
oversize            0          0          0          0          0          0          0          0          0
random             30          0          1         29         29          0          1          0          1
all              3499        696         14       3298        719          0        171        102          3

The two most important columns are
- io		number of readahead IO
- io_size	average readahead IO size

CC: Ingo Molnar <mingo@elte.hu>
CC: Jens Axboe <jens.axboe@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/kernel-parameters.txt |    6 
 mm/Kconfig                          |   15 ++
 mm/readahead.c                      |  194 ++++++++++++++++++++++++++
 3 files changed, 215 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-11-21 17:08:43.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-21 17:13:28.000000000 +0800
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
 static int __init config_readahead_size(char *str)
 {
 	unsigned long bytes;
@@ -51,6 +62,182 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
 
 #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+#ifdef CONFIG_READAHEAD_STATS
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+
+static u32 readahead_stats_enable __read_mostly;
+
+static int __init config_readahead_stats(char *str)
+{
+	int enable = 1;
+	get_option(&str, &enable);
+	readahead_stats_enable = enable;
+	return 0;
+}
+early_param("readahead_stats", config_readahead_stats);
+
+enum ra_account {
+	/* number of readaheads */
+	RA_ACCOUNT_COUNT,	/* readahead request */
+	RA_ACCOUNT_EOF,		/* readahead request covers EOF */
+	RA_ACCOUNT_CHIT,	/* readahead request covers some cached pages */
+	RA_ACCOUNT_IOCOUNT,	/* readahead IO */
+	RA_ACCOUNT_SYNC,	/* readahead IO that is synchronous */
+	RA_ACCOUNT_MMAP,	/* readahead IO by mmap page faults */
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
+	if (start <= offset && offset < start + size)
+		ra_stats[pattern][RA_ACCOUNT_SYNC]++;
+
+	if (ra_flags & READAHEAD_MMAP)
+		ra_stats[pattern][RA_ACCOUNT_MMAP]++;
+}
+
+static int readahead_stats_show(struct seq_file *s, void *_)
+{
+	unsigned long i;
+
+	seq_printf(s, "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
+			"pattern",
+			"readahead", "eof_hit", "cache_hit",
+			"io", "sync_io", "mmap_io",
+			"size", "async_size", "io_size");
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
+	if (readahead_stats_enable) {
+		readahead_stats(mapping, offset, req_size, ra_flags,
+				start, size, async_size, actual);
+		readahead_stats(mapping, offset, req_size,
+				RA_PATTERN_ALL << READAHEAD_PATTERN_SHIFT,
+				start, size, async_size, actual);
+	}
+#endif
+}
+
 /*
  * see if a page needs releasing upon read_cache_pages() failure
  * - the caller of read_cache_pages() may have set PG_private or PG_fscache
@@ -247,10 +434,14 @@ int force_page_cache_readahead(struct ad
 			ret = err;
 			break;
 		}
+		readahead_event(mapping, offset, nr_to_read,
+				RA_PATTERN_FADVISE << READAHEAD_PATTERN_SHIFT,
+				offset, this_chunk, 0, err);
 		ret += err;
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
 	}
+
 	return ret;
 }
 
@@ -278,6 +469,9 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	readahead_event(mapping, offset, req_size, ra->ra_flags,
+			ra->start, ra->size, ra->async_size, actual);
+
 	ra->ra_flags &= ~READAHEAD_MMAP;
 	return actual;
 }
--- linux-next.orig/mm/Kconfig	2011-11-21 17:08:31.000000000 +0800
+++ linux-next/mm/Kconfig	2011-11-21 17:08:51.000000000 +0800
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
+	  To enable accounting early, boot kernel with "readahead_stats=1".
+	  Or run these commands after boot:
+
+	  echo 1 > /sys/kernel/debug/readahead/stats_enable
+	  echo 0 > /sys/kernel/debug/readahead/stats  # reset counters
+	  # run the workload
+	  cat /sys/kernel/debug/readahead/stats       # check counters
--- linux-next.orig/Documentation/kernel-parameters.txt	2011-11-21 17:08:38.000000000 +0800
+++ linux-next/Documentation/kernel-parameters.txt	2011-11-21 17:08:51.000000000 +0800
@@ -2251,6 +2251,12 @@ bytes respectively. Such letter suffixes
 			This default max readahead size may be overrode
 			in some cases, notably NFS, btrfs and software RAID.
 
+	readahead_stats[=0|1]
+			Enable/disable readahead stats accounting.
+
+			It's also possible to enable/disable it after boot:
+			echo 1 > /sys/kernel/debug/readahead/stats_enable
+
 	reboot=		[BUGS=X86-32,BUGS=ARM,BUGS=IA-64] Rebooting mode
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
