Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 497AA6B02B8
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 01:36:28 -0500 (EST)
Date: Wed, 14 Dec 2011 14:36:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-ID: <20111214063625.GA13824@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.666312513@intel.com>
 <20111129152106.GN5635@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129152106.GN5635@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

>   This looks all inherently racy (which doesn't matter much as you suggest)
> so I just wanted to suggest that if you used per-cpu counters you'd get
> race-free and faster code at the cost of larger data structures and using
> percpu_counter_add() instead of ++ (which doesn't seem like a big
> complication to me).

OK, here is the incremental patch to use per-cpu counters :)

---
 mm/readahead.c |   61 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 44 insertions(+), 17 deletions(-)

--- linux-next.orig/mm/readahead.c	2011-12-14 09:50:37.000000000 +0800
+++ linux-next/mm/readahead.c	2011-12-14 14:16:15.000000000 +0800
@@ -68,7 +68,7 @@ enum ra_account {
 	RA_ACCOUNT_MAX,
 };
 
-static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
+static DEFINE_PER_CPU(unsigned long[RA_PATTERN_ALL][RA_ACCOUNT_MAX], ra_stat);
 
 static void readahead_stats(struct address_space *mapping,
 			    pgoff_t offset,
@@ -83,38 +83,62 @@ static void readahead_stats(struct addre
 {
 	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
 
-recount:
-	ra_stats[pattern][RA_ACCOUNT_COUNT]++;
-	ra_stats[pattern][RA_ACCOUNT_SIZE] += size;
-	ra_stats[pattern][RA_ACCOUNT_ASYNC_SIZE] += async_size;
-	ra_stats[pattern][RA_ACCOUNT_ACTUAL] += actual;
+	preempt_disable();
+
+	__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_COUNT]);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_SIZE], size);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ASYNC_SIZE], async_size);
+	__this_cpu_add(ra_stat[pattern][RA_ACCOUNT_ACTUAL], actual);
 
 	if (start + size >= eof)
-		ra_stats[pattern][RA_ACCOUNT_EOF]++;
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_EOF]);
 	if (actual < size)
-		ra_stats[pattern][RA_ACCOUNT_CACHE_HIT]++;
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_CACHE_HIT]);
 
 	if (actual) {
-		ra_stats[pattern][RA_ACCOUNT_IOCOUNT]++;
+		__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_IOCOUNT]);
 
 		if (start <= offset && offset < start + size)
-			ra_stats[pattern][RA_ACCOUNT_SYNC]++;
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_SYNC]);
 
 		if (for_mmap)
-			ra_stats[pattern][RA_ACCOUNT_MMAP]++;
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_MMAP]);
 		if (for_metadata)
-			ra_stats[pattern][RA_ACCOUNT_METADATA]++;
+			__this_cpu_inc(ra_stat[pattern][RA_ACCOUNT_METADATA]);
 	}
 
-	if (pattern != RA_PATTERN_ALL) {
-		pattern = RA_PATTERN_ALL;
-		goto recount;
-	}
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
 }
 
 static int readahead_stats_show(struct seq_file *s, void *_)
 {
 	unsigned long i;
+	unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
 
 	seq_printf(s,
 		   "%-10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",
@@ -122,6 +146,9 @@ static int readahead_stats_show(struct s
 		   "io", "sync_io", "mmap_io", "meta_io",
 		   "size", "async_size", "io_size");
 
+	memset(ra_stats, 0, sizeof(ra_stats));
+	ra_stats_sum(ra_stats);
+
 	for (i = 0; i < RA_PATTERN_MAX; i++) {
 		unsigned long count = ra_stats[i][RA_ACCOUNT_COUNT];
 		unsigned long iocount = ra_stats[i][RA_ACCOUNT_IOCOUNT];
@@ -159,7 +186,7 @@ static int readahead_stats_open(struct i
 static ssize_t readahead_stats_write(struct file *file, const char __user *buf,
 				     size_t size, loff_t *offset)
 {
-	memset(ra_stats, 0, sizeof(ra_stats));
+	ra_stats_clear();
 	return size;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
