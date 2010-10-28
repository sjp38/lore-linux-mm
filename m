Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80A026B00E7
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 15:15:47 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o9SJFiDP015612
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 12:15:44 -0700
Received: from gyb13 (gyb13.prod.google.com [10.243.49.77])
	by hpaq5.eem.corp.google.com with ESMTP id o9SJDqwX010479
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 12:15:42 -0700
Received: by gyb13 with SMTP id 13so1607257gyb.9
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 12:15:36 -0700 (PDT)
Date: Thu, 28 Oct 2010 12:15:23 -0700
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting
 the working set
Message-ID: <20101028191523.GA14972@google.com>
Reply-To: 20101025094235.9154.A69D9226@jp.fujitsu.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On ChromiumOS, we do not use swap. When memory is low, the only way to
free memory is to reclaim pages from the file list. This results in a
lot of thrashing under low memory conditions. We see the system become
unresponsive for minutes before it eventually OOMs. We also see very
slow browser tab switching under low memory. Instead of an unresponsive
system, we'd really like the kernel to OOM as soon as it starts to
thrash. If it can't keep the working set in memory, then OOM.
Losing one of many tabs is a better behaviour for the user than an
unresponsive system.

This patch create a new sysctl, min_filelist_kbytes, which disables reclaim
of file-backed pages when when there are less than min_filelist_bytes worth
of such pages in the cache. This tunable is handy for low memory systems
using solid-state storage where interactive response is more important
than not OOMing.

With this patch and min_filelist_kbytes set to 50000, I see very little
block layer activity during low memory. The system stays responsive under
low memory and browser tab switching is fast. Eventually, a process a gets
killed by OOM. Without this patch, the system gets wedged for minutes
before it eventually OOMs. Below is the vmstat output from my test runs.

BEFORE (notice the high bi and wa, also how long it takes to OOM):

$ vmstat -a 5 1000
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa
 6  2      0  10212 350464 352276    0    0   780     1 3227 4348 78 11  1 10
 1  2      0   8852 351168 353216    0    0  3154     0 3424 3424 65 16  6 14
 2  1      0  14788 348844 349044    0    0  1620     2 2925 3336 74 10  3 13
 4  1      0  16756 346264 349004    0    0   372     0 2923 2977 76  8  1 15
 1  3      0   8432 357596 347136    0    0  5346     1 3633 4599 57 20  4 19
 1  2      0  10704 350856 351720    0    0  3003     1 3635 3921 57 15  7 20
 2  5      0   8048 352160 352660    0    0  6995     0 4033 4872 47 25  4 24

* unresponsive

 1  6      0   8120 351928 352884    0    0 13402     0 4767 4663 36 37  2 25
 1 14      0   8540 351700 352672    0    0 23932     3 4352 3188 10 54  0 36
 0  6      0   8276 351860 353004    0    0 24741     2 4286 3076 10 55  1 34
 0 18      0   8012 352012 352836    0    0 26684     0 4441 2995  9 54  0 36
 0 27      0   8384 351600 352992    0    0 27056     1 4688 2994  3 54  0 43
 0 20      0   8292 351696 353008    0    0 27410     5 4568 2957  2 55  0 42
 1 16      0   8180 351728 352984    0    0 27199     0 4409 2789  1 56  0 43
 3 14      0   7928 351524 353072    0    0 28060     0 4563 3426  1 57  0 42
 0 21      0   8140 351572 353100    0    0 29664     0 5074 5127  1 59  0 39
 0 21      0   7960 351504 352656    0    0 31719     1 4769 4917  0 64  0 36

* OOM

 1 26      0  99864 351424 261060    0    0 27382     0 5229 6085  1 59  0 40
 0  1      0  58124 388300 266644    0    0  8688     0 3413 5204 35 26 11 29
 0  1      0  69796 369644 273136    0    0   201    11 2266 1622 32  3 29 36
 1  1      0  74560 360908 276976    0    0     0     0 1916 1650 24  3 33 40

AFTER (Notice almost no bi or wa and quick OOM):

$ vmstat -a 5 1000
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa
 0  0      0  35892 387588 289644    0    0     0     0 3616 3983 50 11 40  0
 5  0      0  40108 375328 297996    0    0   291     0 3657 4534 52 12 36  0
 2  0      0  58676 369724 284320    0    0   193     1 2677 3265 54  7 39  0
 3  0      0  61188 366028 285492    0    0     0     0 2639 2756 35  5 60  0
 0  0      0  58716 367132 286996    0    0    13     0 3044 4233 34  7 59  0
 5  0      0  43080 379872 289924    0    0     0     1 3475 4244 62 12 27  0
 0  0      0  42580 372940 297684    0    0   485     0 2794 3253 76 10 13  1
 2  0      0  42160 370292 300864    0    0   202     0 3074 4365 61  9 29  1
 6  0      0  44116 370716 298100    0    0    75     0 3062 5257 75 10 15  0
 3  0      0  30228 383652 298696    0    0     0     1 3244 4858 76 11 12  0
 4  0      0  26752 384272 301844    0    0    18     0 2892 4634 83 10  7  0
 3  0      0  19348 386540 307252    0    0   333     0 2876 3932 84  9  7  0
 1  0      0  30864 378408 304440    0    0   198     2 3024 4167 79  9 12  0
 6  0      0  28540 379684 304848    0    0    14     0 2925 4746 79 11 10  0
 6  2      0  14216 379312 320088    0    0   289     2 3561 3764 77 10  4 10

* OOM

 0  0      0  83880 352600 276612    0    0   853     0 3947 4777 45 13 38  4
 2  1      0  85016 355900 272980    0    0   787     1 3480 4787 71 14 13  2
 1  0      0  67496 358288 286760    0    0   689     0 3211 4056 72 12 15  2
 2  0      0  66504 356896 289528    0    0     0     6 2848 3268 51  6 43  0
 1  0      0  58444 357780 296760    0    0     2     0 2938 3956 39  7 53  0
 2  0      0  58196 356680 297860    0    0     5     0 2606 3204 34  6 60  0

Change-Id: I17d4521a35e2648dda9db5c85aba5334a2d12f50
Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 include/linux/mm.h |    2 ++
 kernel/sysctl.c    |   10 ++++++++++
 mm/vmscan.c        |   25 +++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..40ececc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -36,6 +36,8 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+extern int min_filelist_kbytes;
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3a45c22..59f898a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1320,6 +1320,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "min_filelist_kbytes",
+		.data		= &min_filelist_kbytes,
+		.maxlen		= sizeof(min_filelist_kbytes),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..9c27d9a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -130,6 +130,11 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+/*
+ * Low watermark used to prevent fscache thrashing during low memory.
+ */
+int min_filelist_kbytes = 0;
+
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1583,11 +1588,31 @@ static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
 		return inactive_anon_is_low(zone, sc);
 }
 
+/*
+ * Check low watermark used to prevent fscache thrashing during low memory.
+ */
+static int file_is_low(struct zone *zone, struct scan_control *sc)
+{
+	unsigned long pages_min, active, inactive;
+
+	if (!scanning_global_lru(sc))
+		return false;
+
+	pages_min = min_filelist_kbytes >> (PAGE_SHIFT - 10);
+	active = zone_page_state(zone, NR_ACTIVE_FILE);
+	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+
+	return ((active + inactive) < pages_min);
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);
 
+	if (file && file_is_low(zone, sc))
+		return 0;
+
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(zone, sc, file))
 		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
