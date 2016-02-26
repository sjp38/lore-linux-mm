Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 122666B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:16:02 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so78772750wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:16:02 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id iw2si16731801wjb.101.2016.02.26.08.16.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 08:16:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id B7F68990C7
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 16:15:59 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/1] mm: thp: Set THP defrag by default to madvise and add a stall-free defrag option
Date: Fri, 26 Feb 2016 16:15:59 +0000
Message-Id: <1456503359-4910-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v1
o Default defrag to madvise instead of never
o Introduce "defer" defrag option to wake kswapd/kcompact if THP is unavailable
o Restore "always" to historical behaviour
o Update documentation

THP defrag is enabled by default to direct reclaim/compact but not wake
kswapd in the event of a THP allocation failure. The problem is that THP
allocation requests potentially enter reclaim/compaction. This potentially
incurs a severe stall that is not guaranteed to be offset by reduced TLB
misses. While there has been considerable effort to reduce the impact
of reclaim/compaction, it is still a high cost and workloads that should
fit in memory fail to do so. Specifically, a simple anon/file streaming
workload will enter direct reclaim on NUMA at least even though the working
set size is 80% of RAM. It's been years and it's time to throw in the towel.

First, this patch defines THP defrag as follows;

madvise: A failed allocation will direct reclaim/compact if the application requests it
never:   Neither reclaim/compact nor wake kswapd
defer:   A failed allocation will wake kswapd/kcompactd
always:  A failed allocation will direct reclaim/compact (historical behaviour)
khugepaged defrag will enter direct/reclaim but not wake kswapd.

Next it sets the default defrag option to be "madvise" to only enter direct
reclaim/compaction for applications that specifically requested it.

Lastly, it removes a check from the page allocator slowpath that is related
to __GFP_THISNODE to allow "defer" to work. The callers that really cares are
slub/slab and they are updated accordingly. The slab one may be surprising
because it also corrects a comment as kswapd was never woken up by that path.

This means that a THP fault will no longer stall for most applications by
default and the ideal for most users that get THP if they are immediately
available. There are still options for users that prefer a stall at
startup of a new application by either restoring historical behaviour with
"always" or pick a half-way point with "defer" where kswapd does some of
the work in the background and wakes kcompactd if necessary. THP defrag
for khugepaged remains enabled and will enter direct/reclaim but no wakeup
kswapd or kcompactd.

After this patch a THP allocation failure will quickly fallback and rely
on khugepaged to recover the situation at some time in the future. In
some cases, this will reduce THP usage but the benefit of THP is hard to
measure and not a universal win where as a stall to reclaim/compaction is
definitely measurable and can be painful.

The first test for this is using "usemem" to read a large file and write
a large anonymous mapping (to avoid the zero page) multiple times. The
total size of the mappings is 80% of RAM and the benchmark simply measures
how long it takes to complete. It uses multiple threads to see if that
is a factor. On UMA, the performance is almost identical so is not reported
but on NUMA, we see this

usemem
                                   4.4.0                 4.4.0
                          kcompactd-v1r1         nodefrag-v1r3
Amean    System-1       102.86 (  0.00%)       46.81 ( 54.50%)
Amean    System-4        37.85 (  0.00%)       34.02 ( 10.12%)
Amean    System-7        48.12 (  0.00%)       46.89 (  2.56%)
Amean    System-12       51.98 (  0.00%)       56.96 ( -9.57%)
Amean    System-21       80.16 (  0.00%)       79.05 (  1.39%)
Amean    System-30      110.71 (  0.00%)      107.17 (  3.20%)
Amean    System-48      127.98 (  0.00%)      124.83 (  2.46%)
Amean    Elapsd-1       185.84 (  0.00%)      105.51 ( 43.23%)
Amean    Elapsd-4        26.19 (  0.00%)       25.58 (  2.33%)
Amean    Elapsd-7        21.65 (  0.00%)       21.62 (  0.16%)
Amean    Elapsd-12       18.58 (  0.00%)       17.94 (  3.43%)
Amean    Elapsd-21       17.53 (  0.00%)       16.60 (  5.33%)
Amean    Elapsd-30       17.45 (  0.00%)       17.13 (  1.84%)
Amean    Elapsd-48       15.40 (  0.00%)       15.27 (  0.82%)

For a single thread, the benchmark completes 43.23% faster with
this patch applied with smaller benefits as the thread increases.
Similar, notice the large reduction in most cases in system CPU
usage. The overall CPU time is

               4.4.0       4.4.0
        kcompactd-v1r1 nodefrag-v1r3
User        10357.65    10438.33
System       3988.88     3543.94
Elapsed      2203.01     1634.41

Which is substantial. Now, the reclaim figures

                                 4.4.0       4.4.0
                          kcompactd-v1r1nodefrag-v1r3
Minor Faults                 128458477   278352931
Major Faults                   2174976         225
Swap Ins                      16904701           0
Swap Outs                     17359627           0
Allocation stalls                43611           0
DMA allocs                           0           0
DMA32 allocs                  19832646    19448017
Normal allocs                614488453   580941839
Movable allocs                       0           0
Direct pages scanned          24163800           0
Kswapd pages scanned                 0           0
Kswapd pages reclaimed               0           0
Direct pages reclaimed        20691346           0
Compaction stalls                42263           0
Compaction success                 938           0
Compaction failures              41325           0

This patch eliminates almost all swapping and direct reclaim activity. There
is still overhead but it's from NUMA balancing which does not identify that
it's pointless trying to do anything with this workload.

I also tried the thpscale benchmark which forces a corner case where compaction
can be used heavily and measures the latency of whether base or huge pages were
used

thpscale Fault Latencies
                                       4.4.0                 4.4.0
                              kcompactd-v1r1         nodefrag-v1r3
Amean    fault-base-1      5288.84 (  0.00%)     2817.12 ( 46.73%)
Amean    fault-base-3      6365.53 (  0.00%)     3499.11 ( 45.03%)
Amean    fault-base-5      6526.19 (  0.00%)     4363.06 ( 33.15%)
Amean    fault-base-7      7142.25 (  0.00%)     4858.08 ( 31.98%)
Amean    fault-base-12    13827.64 (  0.00%)    10292.11 ( 25.57%)
Amean    fault-base-18    18235.07 (  0.00%)    13788.84 ( 24.38%)
Amean    fault-base-24    21597.80 (  0.00%)    24388.03 (-12.92%)
Amean    fault-base-30    26754.15 (  0.00%)    19700.55 ( 26.36%)
Amean    fault-base-32    26784.94 (  0.00%)    19513.57 ( 27.15%)
Amean    fault-huge-1      4223.96 (  0.00%)     2178.57 ( 48.42%)
Amean    fault-huge-3      2194.77 (  0.00%)     2149.74 (  2.05%)
Amean    fault-huge-5      2569.60 (  0.00%)     2346.95 (  8.66%)
Amean    fault-huge-7      3612.69 (  0.00%)     2997.70 ( 17.02%)
Amean    fault-huge-12     3301.75 (  0.00%)     6727.02 (-103.74%)
Amean    fault-huge-18     6696.47 (  0.00%)     6685.72 (  0.16%)
Amean    fault-huge-24     8000.72 (  0.00%)     9311.43 (-16.38%)
Amean    fault-huge-30    13305.55 (  0.00%)     9750.45 ( 26.72%)
Amean    fault-huge-32     9981.71 (  0.00%)    10316.06 ( -3.35%)

The average time to fault pages is substantially reduced in the
majority of caseds but with the obvious caveat that fewer THPs
are actually used in this adverse workload

                                   4.4.0                 4.4.0
                          kcompactd-v1r1         nodefrag-v1r3
Percentage huge-1         0.71 (  0.00%)       14.04 (1865.22%)
Percentage huge-3        10.77 (  0.00%)       33.05 (206.85%)
Percentage huge-5        60.39 (  0.00%)       38.51 (-36.23%)
Percentage huge-7        45.97 (  0.00%)       34.57 (-24.79%)
Percentage huge-12       68.12 (  0.00%)       40.07 (-41.17%)
Percentage huge-18       64.93 (  0.00%)       47.82 (-26.35%)
Percentage huge-24       62.69 (  0.00%)       44.23 (-29.44%)
Percentage huge-30       43.49 (  0.00%)       55.38 ( 27.34%)
Percentage huge-32       50.72 (  0.00%)       51.90 (  2.35%)

                                 4.4.0       4.4.0
                          kcompactd-v1r1nodefrag-v1r3
Minor Faults                  37429143    47564000
Major Faults                      1916        1558
Swap Ins                          1466        1079
Swap Outs                      2936863      149626
Allocation stalls                62510           3
DMA allocs                           0           0
DMA32 allocs                   6566458     6401314
Normal allocs                216361697   216538171
Movable allocs                       0           0
Direct pages scanned          25977580       17998
Kswapd pages scanned                 0     3638931
Kswapd pages reclaimed               0      207236
Direct pages reclaimed         8833714          88
Compaction stalls               103349           5
Compaction success                 270           4
Compaction failures             103079           1

Note again that while this does swap as it's an aggressive workload,
the direct relcim activity and allocation stalls is substantially
reduced. There is some kswapd activity but ftrace showed that the
kswapd activity was due to normal wakeups from 4K pages being
allocated. Compaction-related stalls and activity are almost
eliminated.

I also tried the stutter benchmark. For this, I do not have figures for
NUMA but it's something that does impact UMA so I'll report what is available

stutter
                                 4.4.0                 4.4.0
                        kcompactd-v1r1         nodefrag-v1r3
Min         mmap      7.3571 (  0.00%)      7.3438 (  0.18%)
1st-qrtle   mmap      7.5278 (  0.00%)     17.9200 (-138.05%)
2nd-qrtle   mmap      7.6818 (  0.00%)     21.6055 (-181.25%)
3rd-qrtle   mmap     11.0889 (  0.00%)     21.8881 (-97.39%)
Max-90%     mmap     27.8978 (  0.00%)     22.1632 ( 20.56%)
Max-93%     mmap     28.3202 (  0.00%)     22.3044 ( 21.24%)
Max-95%     mmap     28.5600 (  0.00%)     22.4580 ( 21.37%)
Max-99%     mmap     29.6032 (  0.00%)     25.5216 ( 13.79%)
Max         mmap   4109.7289 (  0.00%)   4813.9832 (-17.14%)
Mean        mmap     12.4474 (  0.00%)     19.3027 (-55.07%)

This benchmark is trying to fault an anonymous mapping while there is
a heavy IO load -- a scenario that desktop users used to complain about
frequently. This shows a mix because the ideal case of mapping with THP
is not hit as often. However, note that 99% of the mappings complete
13.79% faster. The CPU usage here is particularly interesting

               4.4.0       4.4.0
        kcompactd-v1r1nodefrag-v1r3
User           67.50        0.99
System       1327.88       91.30
Elapsed      2079.00     2128.98

And once again we look at the reclaim figures

                                 4.4.0       4.4.0
                          kcompactd-v1r1nodefrag-v1r3
Minor Faults                 335241922  1314582827
Major Faults                       715         819
Swap Ins                             0           0
Swap Outs                            0           0
Allocation stalls               532723           0
DMA allocs                           0           0
DMA32 allocs                1822364341  1177950222
Normal allocs               1815640808  1517844854
Movable allocs                       0           0
Direct pages scanned          21892772           0
Kswapd pages scanned          20015890    41879484
Kswapd pages reclaimed        19961986    41822072
Direct pages reclaimed        21892741           0
Compaction stalls              1065755           0
Compaction success                 514           0
Compaction failures            1065241           0

Allocation stalls and all direct reclaim activity is eliminated as well
as compaction-related stalls.

THP gives impressive gains in some cases but only if they are quickly
available.  We're not going to reach the point where they are completely
free so lets take the costs out of the fast paths finally and defer the
cost to kswapd, kcompactd and khugepaged where it belongs.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/vm/transhuge.txt | 17 ++++++++
 include/linux/gfp.h            |  2 +-
 include/linux/huge_mm.h        |  9 +---
 mm/huge_memory.c               | 99 +++++++++++++++++++++++++++---------------
 mm/page_alloc.c                |  8 ----
 mm/slab.c                      |  8 ++--
 mm/slub.c                      |  2 +-
 7 files changed, 89 insertions(+), 56 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 8a282687ee06..a19b173cbc57 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -113,9 +113,26 @@ guaranteed, but it may be more likely in case the allocation is for a
 MADV_HUGEPAGE region.
 
 echo always >/sys/kernel/mm/transparent_hugepage/defrag
+echo defer >/sys/kernel/mm/transparent_hugepage/defrag
 echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
 echo never >/sys/kernel/mm/transparent_hugepage/defrag
 
+"always" means that an application requesting THP will stall on allocation
+failure and directly reclaim pages and compact memory in an effort to
+allocate a THP immediately. This may be desirable for virtual machines
+that benefit heavily from THP use and are willing to delay the VM start
+to utilise them.
+
+"defer" means that an application will wake kswapd in the background
+to reclaim pages and wake kcompact to compact memory so that THP is
+available in the near future. It's the responsibility of khugepaged
+to then install the THP pages later.
+
+"madvise" will enter direct reclaim like "always" but only for regions
+that are have used madvise(). This is the default behaviour.
+
+"never" should be self-explanatory.
+
 By default kernel tries to use huge zero page on read page fault.
 It's possible to disable huge zero page by writing 0 or enable it
 back by writing 1:
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8942af0813e3..e4a0287e5d0b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -248,7 +248,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
-			 ~__GFP_KSWAPD_RECLAIM)
+			 ~__GFP_RECLAIM)
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ecb080d6ff42..833dcbcd9edb 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -39,7 +39,8 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
-	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
+	TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
+	TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
 	TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
@@ -77,12 +78,6 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
 	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
 	 !is_vma_temporary_stack(__vma))
-#define transparent_hugepage_defrag(__vma)				\
-	((transparent_hugepage_flags &					\
-	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)) ||			\
-	 (transparent_hugepage_flags &					\
-	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG) &&		\
-	  (__vma)->vm_flags & VM_HUGEPAGE))
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 62fe06bb7d04..206f35f06d83 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -46,7 +46,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
 	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
 #endif
-	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
+	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
@@ -237,37 +237,33 @@ static struct shrinker huge_zero_page_shrinker = {
 
 #ifdef CONFIG_SYSFS
 
-static ssize_t double_flag_show(struct kobject *kobj,
-				struct kobj_attribute *attr, char *buf,
-				enum transparent_hugepage_flag enabled,
-				enum transparent_hugepage_flag req_madv)
-{
-	if (test_bit(enabled, &transparent_hugepage_flags)) {
-		VM_BUG_ON(test_bit(req_madv, &transparent_hugepage_flags));
-		return sprintf(buf, "[always] madvise never\n");
-	} else if (test_bit(req_madv, &transparent_hugepage_flags))
-		return sprintf(buf, "always [madvise] never\n");
-	else
-		return sprintf(buf, "always madvise [never]\n");
-}
-static ssize_t double_flag_store(struct kobject *kobj,
+static ssize_t triple_flag_store(struct kobject *kobj,
 				 struct kobj_attribute *attr,
 				 const char *buf, size_t count,
 				 enum transparent_hugepage_flag enabled,
+				 enum transparent_hugepage_flag deferred,
 				 enum transparent_hugepage_flag req_madv)
 {
-	if (!memcmp("always", buf,
+	if (!memcmp("defer", buf,
+		    min(sizeof("defer")-1, count))) {
+		clear_bit(enabled, &transparent_hugepage_flags);
+		clear_bit(req_madv, &transparent_hugepage_flags);
+		set_bit(deferred, &transparent_hugepage_flags);
+	} else if (!memcmp("always", buf,
 		    min(sizeof("always")-1, count))) {
-		set_bit(enabled, &transparent_hugepage_flags);
+		clear_bit(deferred, &transparent_hugepage_flags);
 		clear_bit(req_madv, &transparent_hugepage_flags);
+		set_bit(enabled, &transparent_hugepage_flags);
 	} else if (!memcmp("madvise", buf,
 			   min(sizeof("madvise")-1, count))) {
 		clear_bit(enabled, &transparent_hugepage_flags);
+		clear_bit(deferred, &transparent_hugepage_flags);
 		set_bit(req_madv, &transparent_hugepage_flags);
 	} else if (!memcmp("never", buf,
 			   min(sizeof("never")-1, count))) {
 		clear_bit(enabled, &transparent_hugepage_flags);
 		clear_bit(req_madv, &transparent_hugepage_flags);
+		clear_bit(deferred, &transparent_hugepage_flags);
 	} else
 		return -EINVAL;
 
@@ -277,17 +273,23 @@ static ssize_t double_flag_store(struct kobject *kobj,
 static ssize_t enabled_show(struct kobject *kobj,
 			    struct kobj_attribute *attr, char *buf)
 {
-	return double_flag_show(kobj, attr, buf,
-				TRANSPARENT_HUGEPAGE_FLAG,
-				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
+	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
+		VM_BUG_ON(test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags));
+		return sprintf(buf, "[always] madvise never\n");
+	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "always [madvise] never\n");
+	else
+		return sprintf(buf, "always madvise [never]\n");
 }
+
 static ssize_t enabled_store(struct kobject *kobj,
 			     struct kobj_attribute *attr,
 			     const char *buf, size_t count)
 {
 	ssize_t ret;
 
-	ret = double_flag_store(kobj, attr, buf, count,
+	ret = triple_flag_store(kobj, attr, buf, count,
+				TRANSPARENT_HUGEPAGE_FLAG,
 				TRANSPARENT_HUGEPAGE_FLAG,
 				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
 
@@ -345,16 +347,23 @@ static ssize_t single_flag_store(struct kobject *kobj,
 static ssize_t defrag_show(struct kobject *kobj,
 			   struct kobj_attribute *attr, char *buf)
 {
-	return double_flag_show(kobj, attr, buf,
-				TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
-				TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "[always] defer madvise never\n");
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "always [defer] madvise never\n");
+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
+		return sprintf(buf, "always defer [madvise] never\n");
+	else
+		return sprintf(buf, "always defer madvise [never]\n");
+
 }
 static ssize_t defrag_store(struct kobject *kobj,
 			    struct kobj_attribute *attr,
 			    const char *buf, size_t count)
 {
-	return double_flag_store(kobj, attr, buf, count,
-				 TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
+	return triple_flag_store(kobj, attr, buf, count,
+				 TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
+				 TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
 				 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
 }
 static struct kobj_attribute defrag_attr =
@@ -784,9 +793,30 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	return 0;
 }
 
-static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
+/*
+ * If THP is set to always then directly reclaim/compact as necessary
+ * If set to defer then do no reclaim and defer to khugepaged
+ * If set to madvise and the VMA is flagged then directly reclaim/compact
+ */
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
+{
+	gfp_t reclaim_flags = 0;
+
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags) &&
+	    (vma->vm_flags & VM_HUGEPAGE))
+		reclaim_flags = __GFP_DIRECT_RECLAIM;
+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
+		reclaim_flags = __GFP_KSWAPD_RECLAIM;
+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
+		reclaim_flags = __GFP_DIRECT_RECLAIM;
+
+	return GFP_TRANSHUGE | reclaim_flags;
+}
+
+/* Defrag for khugepaged will enter direct reclaim/compaction if necessary */
+static inline gfp_t alloc_hugepage_khugepaged_gfpmask(void)
 {
-	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_RECLAIM)) | extra_gfp;
+	return GFP_TRANSHUGE | (khugepaged_defrag() ? __GFP_DIRECT_RECLAIM : 0);
 }
 
 /* Caller must hold page table lock. */
@@ -859,7 +889,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		return ret;
 	}
-	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+	gfp = alloc_hugepage_direct_gfpmask(vma);
 	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
@@ -1185,7 +1215,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
-		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
 		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
 	} else
 		new_page = NULL;
@@ -2440,9 +2470,9 @@ static int khugepaged_find_target_node(void)
 	return 0;
 }
 
-static inline struct page *alloc_hugepage(int defrag)
+static inline struct page *alloc_khugepaged_hugepage(void)
 {
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
+	return alloc_pages(alloc_hugepage_khugepaged_gfpmask(),
 			   HPAGE_PMD_ORDER);
 }
 
@@ -2451,7 +2481,7 @@ static struct page *khugepaged_alloc_hugepage(bool *wait)
 	struct page *hpage;
 
 	do {
-		hpage = alloc_hugepage(khugepaged_defrag());
+		hpage = alloc_khugepaged_hugepage();
 		if (!hpage) {
 			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 			if (!*wait)
@@ -2523,8 +2553,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 	/* Only allocate from the target node */
-	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
-		__GFP_THISNODE;
+	gfp = alloc_hugepage_khugepaged_gfpmask() | __GFP_OTHER_NODE | __GFP_THISNODE;
 
 	/* release the mmap_sem read lock. */
 	new_page = khugepaged_alloc_page(hpage, gfp, mm, address, node);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 963431430097..c0ad55c2ed94 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2998,14 +2998,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
 		gfp_mask &= ~__GFP_ATOMIC;
 
-	/*
-	 * If this allocation cannot block and it is for a specific node, then
-	 * fail early.  There's no need to wakeup kswapd or retry for a
-	 * speculative node-specific allocation.
-	 */
-	if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & __GFP_THISNODE) && !can_direct_reclaim)
-		goto nopage;
-
 retry:
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
diff --git a/mm/slab.c b/mm/slab.c
index 4765c97ce690..bbd0dfb6bd18 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -860,7 +860,7 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 
 static inline gfp_t gfp_exact_node(gfp_t flags)
 {
-	return flags;
+	return flags & ~__GFP_NOFAIL;
 }
 
 #else	/* CONFIG_NUMA */
@@ -1031,12 +1031,12 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 }
 
 /*
- * Construct gfp mask to allocate from a specific node but do not direct reclaim
- * or warn about failures. kswapd may still wake to reclaim in the background.
+ * Construct gfp mask to allocate from a specific node but do not reclaim or
+ * warn about failures.
  */
 static inline gfp_t gfp_exact_node(gfp_t flags)
 {
-	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_DIRECT_RECLAIM;
+	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
 }
 #endif
 
diff --git a/mm/slub.c b/mm/slub.c
index 46997517406e..b28e7f7ddef1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1413,7 +1413,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
 	if ((alloc_gfp & __GFP_DIRECT_RECLAIM) && oo_order(oo) > oo_order(s->min))
-		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM;
+		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
