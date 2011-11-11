Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8B6B6B0070
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:40:14 -0500 (EST)
Received: by faas10 with SMTP id s10so1814640faa.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 04:40:11 -0800 (PST)
Subject: [PATCH v3 4/4] mm-tracepoint: fixup documentation and examples
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 11 Nov 2011 16:40:09 +0300
Message-ID: <20111111124009.7371.10762.stgit@zurg>
In-Reply-To: <20110729075837.12274.58405.stgit@localhost6>
References: <20110729075837.12274.58405.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

Rename page-free mm tracepoints.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 Documentation/trace/tracepoint-analysis.txt |   40 ++++++++++++++-------------
 tools/perf/Documentation/examples.txt       |   34 +++++++++++------------
 2 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/Documentation/trace/tracepoint-analysis.txt b/Documentation/trace/tracepoint-analysis.txt
index 87bee3c..058cc6c 100644
--- a/Documentation/trace/tracepoint-analysis.txt
+++ b/Documentation/trace/tracepoint-analysis.txt
@@ -93,14 +93,14 @@ By specifying the -a switch and analysing sleep, the system-wide events
 for a duration of time can be examined.
 
  $ perf stat -a \
-	-e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
-	-e kmem:mm_pagevec_free \
+	-e kmem:mm_page_alloc -e kmem:mm_page_free \
+	-e kmem:mm_page_free_batched \
 	sleep 10
  Performance counter stats for 'sleep 10':
 
            9630  kmem:mm_page_alloc
-           2143  kmem:mm_page_free_direct
-           7424  kmem:mm_pagevec_free
+           2143  kmem:mm_page_free
+           7424  kmem:mm_page_free_batched
 
    10.002577764  seconds time elapsed
 
@@ -119,15 +119,15 @@ basis using set_ftrace_pid.
 Events can be activated and tracked for the duration of a process on a local
 basis using PCL such as follows.
 
-  $ perf stat -e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
-		 -e kmem:mm_pagevec_free ./hackbench 10
+  $ perf stat -e kmem:mm_page_alloc -e kmem:mm_page_free \
+		 -e kmem:mm_page_free_batched ./hackbench 10
   Time: 0.909
 
     Performance counter stats for './hackbench 10':
 
           17803  kmem:mm_page_alloc
-          12398  kmem:mm_page_free_direct
-           4827  kmem:mm_pagevec_free
+          12398  kmem:mm_page_free
+           4827  kmem:mm_page_free_batched
 
     0.973913387  seconds time elapsed
 
@@ -146,8 +146,8 @@ to know what the standard deviation is. By and large, this is left to the
 performance analyst to do it by hand. In the event that the discrete event
 occurrences are useful to the performance analyst, then perf can be used.
 
-  $ perf stat --repeat 5 -e kmem:mm_page_alloc -e kmem:mm_page_free_direct
-			-e kmem:mm_pagevec_free ./hackbench 10
+  $ perf stat --repeat 5 -e kmem:mm_page_alloc -e kmem:mm_page_free
+			-e kmem:mm_page_free_batched ./hackbench 10
   Time: 0.890
   Time: 0.895
   Time: 0.915
@@ -157,8 +157,8 @@ occurrences are useful to the performance analyst, then perf can be used.
    Performance counter stats for './hackbench 10' (5 runs):
 
           16630  kmem:mm_page_alloc         ( +-   3.542% )
-          11486  kmem:mm_page_free_direct   ( +-   4.771% )
-           4730  kmem:mm_pagevec_free       ( +-   2.325% )
+          11486  kmem:mm_page_free	    ( +-   4.771% )
+           4730  kmem:mm_page_free_batched  ( +-   2.325% )
 
     0.982653002  seconds time elapsed   ( +-   1.448% )
 
@@ -168,15 +168,15 @@ aggregation of discrete events, then a script would need to be developed.
 Using --repeat, it is also possible to view how events are fluctuating over
 time on a system-wide basis using -a and sleep.
 
-  $ perf stat -e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
-		-e kmem:mm_pagevec_free \
+  $ perf stat -e kmem:mm_page_alloc -e kmem:mm_page_free \
+		-e kmem:mm_page_free_batched \
 		-a --repeat 10 \
 		sleep 1
   Performance counter stats for 'sleep 1' (10 runs):
 
            1066  kmem:mm_page_alloc         ( +-  26.148% )
-            182  kmem:mm_page_free_direct   ( +-   5.464% )
-            890  kmem:mm_pagevec_free       ( +-  30.079% )
+            182  kmem:mm_page_free          ( +-   5.464% )
+            890  kmem:mm_page_free_batched  ( +-  30.079% )
 
     1.002251757  seconds time elapsed   ( +-   0.005% )
 
@@ -220,8 +220,8 @@ were generating events within the kernel. To begin this sort of analysis, the
 data must be recorded. At the time of writing, this required root:
 
   $ perf record -c 1 \
-	-e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
-	-e kmem:mm_pagevec_free \
+	-e kmem:mm_page_alloc -e kmem:mm_page_free \
+	-e kmem:mm_page_free_batched \
 	./hackbench 10
   Time: 0.894
   [ perf record: Captured and wrote 0.733 MB perf.data (~32010 samples) ]
@@ -260,8 +260,8 @@ noticed that X was generating an insane amount of page allocations so let's look
 at it:
 
   $ perf record -c 1 -f \
-		-e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
-		-e kmem:mm_pagevec_free \
+		-e kmem:mm_page_alloc -e kmem:mm_page_free \
+		-e kmem:mm_page_free_batched \
 		-p `pidof X`
 
 This was interrupted after a few seconds and
diff --git a/tools/perf/Documentation/examples.txt b/tools/perf/Documentation/examples.txt
index 8eb6c48..77f9527 100644
--- a/tools/perf/Documentation/examples.txt
+++ b/tools/perf/Documentation/examples.txt
@@ -17,8 +17,8 @@ titan:~> perf list
   kmem:kmem_cache_alloc_node               [Tracepoint event]
   kmem:kfree                               [Tracepoint event]
   kmem:kmem_cache_free                     [Tracepoint event]
-  kmem:mm_page_free_direct                 [Tracepoint event]
-  kmem:mm_pagevec_free                     [Tracepoint event]
+  kmem:mm_page_free                        [Tracepoint event]
+  kmem:mm_page_free_batched                [Tracepoint event]
   kmem:mm_page_alloc                       [Tracepoint event]
   kmem:mm_page_alloc_zone_locked           [Tracepoint event]
   kmem:mm_page_pcpu_drain                  [Tracepoint event]
@@ -29,15 +29,15 @@ measured. For example the page alloc/free properties of a 'hackbench
 run' are:
 
  titan:~> perf stat -e kmem:mm_page_pcpu_drain -e kmem:mm_page_alloc
- -e kmem:mm_pagevec_free -e kmem:mm_page_free_direct ./hackbench 10
+ -e kmem:mm_page_free_batched -e kmem:mm_page_free ./hackbench 10
  Time: 0.575
 
  Performance counter stats for './hackbench 10':
 
           13857  kmem:mm_page_pcpu_drain
           27576  kmem:mm_page_alloc
-           6025  kmem:mm_pagevec_free
-          20934  kmem:mm_page_free_direct
+           6025  kmem:mm_page_free_batched
+          20934  kmem:mm_page_free
 
     0.613972165  seconds time elapsed
 
@@ -45,8 +45,8 @@ You can observe the statistical properties as well, by using the
 'repeat the workload N times' feature of perf stat:
 
  titan:~> perf stat --repeat 5 -e kmem:mm_page_pcpu_drain -e
-   kmem:mm_page_alloc -e kmem:mm_pagevec_free -e
-   kmem:mm_page_free_direct ./hackbench 10
+   kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
+   kmem:mm_page_free ./hackbench 10
  Time: 0.627
  Time: 0.644
  Time: 0.564
@@ -57,8 +57,8 @@ You can observe the statistical properties as well, by using the
 
           12920  kmem:mm_page_pcpu_drain    ( +-   3.359% )
           25035  kmem:mm_page_alloc         ( +-   3.783% )
-           6104  kmem:mm_pagevec_free       ( +-   0.934% )
-          18376  kmem:mm_page_free_direct   ( +-   4.941% )
+           6104  kmem:mm_page_free_batched  ( +-   0.934% )
+          18376  kmem:mm_page_free	    ( +-   4.941% )
 
     0.643954516  seconds time elapsed   ( +-   2.363% )
 
@@ -158,15 +158,15 @@ Or you can observe the whole system's page allocations for 10
 seconds:
 
 titan:~/git> perf stat -a -e kmem:mm_page_pcpu_drain -e
-kmem:mm_page_alloc -e kmem:mm_pagevec_free -e
-kmem:mm_page_free_direct sleep 10
+kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
+kmem:mm_page_free sleep 10
 
  Performance counter stats for 'sleep 10':
 
          171585  kmem:mm_page_pcpu_drain
          322114  kmem:mm_page_alloc
-          73623  kmem:mm_pagevec_free
-         254115  kmem:mm_page_free_direct
+          73623  kmem:mm_page_free_batched
+         254115  kmem:mm_page_free
 
    10.000591410  seconds time elapsed
 
@@ -174,15 +174,15 @@ Or observe how fluctuating the page allocations are, via statistical
 analysis done over ten 1-second intervals:
 
  titan:~/git> perf stat --repeat 10 -a -e kmem:mm_page_pcpu_drain -e
-   kmem:mm_page_alloc -e kmem:mm_pagevec_free -e
-   kmem:mm_page_free_direct sleep 1
+   kmem:mm_page_alloc -e kmem:mm_page_free_batched -e
+   kmem:mm_page_free sleep 1
 
  Performance counter stats for 'sleep 1' (10 runs):
 
           17254  kmem:mm_page_pcpu_drain    ( +-   3.709% )
           34394  kmem:mm_page_alloc         ( +-   4.617% )
-           7509  kmem:mm_pagevec_free       ( +-   4.820% )
-          25653  kmem:mm_page_free_direct   ( +-   3.672% )
+           7509  kmem:mm_page_free_batched  ( +-   4.820% )
+          25653  kmem:mm_page_free	    ( +-   3.672% )
 
     1.058135029  seconds time elapsed   ( +-   3.089% )
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
