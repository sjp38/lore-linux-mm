Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D52626B005C
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:15:14 -0400 (EDT)
Date: Wed, 12 Aug 2009 14:15:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] tracing, documentation: Clarifications and corrections to
	tracepoint-analysis.txt
Message-ID: <20090812131517.GD19269@csn.ul.ie>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie> <1249918915-16061-6-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1249918915-16061-6-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, Jonathan Corbet <corbet@lwn.net>, Fernando Carrijo <fcarrijo@yahoo.com.br>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch makes a number of corrections and clarifications as pointed
out by Jonathan Corbet.

  o Listed some requirement kernel config options
  o Spelled out that perf has to be installed from tools/perf
  o Mention that tracing_enabled must be set
  o Fix numerous minor typos
  o Fix tense issues
  o Expand on what -c means

Fernando Carrijo also spotted that a library was misnamed libpixmap
instead of libpixman. This patch should be considered a fix to
tracing-documentation-add-a-document-describing-how-to-do-some-performance-analysis-with-tracepoints.patch.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 Documentation/trace/tracepoint-analysis.txt |   49 ++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 13 deletions(-)

diff --git a/Documentation/trace/tracepoint-analysis.txt b/Documentation/trace/tracepoint-analysis.txt
index e7a7d3e..282e8d9 100644
--- a/Documentation/trace/tracepoint-analysis.txt
+++ b/Documentation/trace/tracepoint-analysis.txt
@@ -17,8 +17,18 @@ gathering and interpreting these events. Lacking any current Best Practises,
 this document describes some of the methods that can be used.
 
 This document assumes that debugfs is mounted on /sys/kernel/debug and that
-the appropriate tracing options have been configured into the kernel. It is
-assumed that the PCL tool tools/perf has been installed and is in your path.
+at least the following tracing options have been configured into the kernel
+
+	CONFIG_EVENT_PROFILE=y
+	CONFIG_FTRACE=y
+	CONFIG_DYNAMIC_FTRACE=y
+	CONFIG_TRACEPOINTS=y
+
+It is also assumed that the PCL tool available from tools/perf has been
+installed and is in your path. This can be trivially installed as
+
+  $ make prefix=/usr/local
+  $ make prefix=/usr/local install
 
 2. Listing Available Events
 ===========================
@@ -61,6 +71,11 @@ to page allocation would look something like
 
   $ for i in `find /sys/kernel/debug/tracing/events -name "enable" | grep mm_`; do echo 1 > $i; done
 
+To start monitoring the events then, one would do something like
+
+  $ echo 1 > tracing_enabled
+  $ cat trace_pipe | some-processing-script
+
 2.2 System-Wide Event Enabling with SystemTap
 ---------------------------------------------
 
@@ -116,7 +131,7 @@ basis using set_ftrace_pid.
 2.5 Local Event Enablement with PCL
 -----------------------------------
 
-Events can be activate and tracked for the duration of a process on a local
+Events can be activated and tracked for the duration of a process on a local
 basis using PCL such as follows.
 
   $ perf stat -e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
@@ -142,8 +157,8 @@ as any script reading trace_pipe.
 =====================================
 
 Any workload can exhibit variances between runs and it can be important
-to know what the standard deviation in. By and large, this is left to the
-performance analyst to do it by hand. In the event that the discrete event
+to know what the standard deviation is. By and large, this is left to the
+performance analyst to do by hand. In the event that the discrete event
 occurrences are useful to the performance analyst, then perf can be used.
 
   $ perf stat --repeat 5 -e kmem:mm_page_alloc -e kmem:mm_page_free_direct
@@ -190,11 +205,11 @@ be gathered on-line as appropriate. Examples of post-processing might include
 
   o Reading information from /proc for the PID that triggered the event
   o Deriving a higher-level event from a series of lower-level events.
-  o Calculate latencies between two events
+  o Calculating latencies between two events
 
 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl is an example
 script that can read trace_pipe from STDIN or a copy of a trace. When used
-on-line, it can be interrupted once to generate a report without existing
+on-line, it can be interrupted once to generate a report without exiting
 and twice to exit.
 
 Simplistically, the script just reads STDIN and counts up events but it
@@ -204,7 +219,7 @@ also can do more such as
     are freed to the main allocator from the per-CPU lists, it recognises
     that as one per-CPU drain even though there is no specific tracepoint
     for that event
-  o It can aggregate based on PID or individual process number
+  o It can aggregate based on PID or process name
   o In the event memory is getting externally fragmented, it reports
     on whether the fragmentation event was severe or moderate.
   o When receiving an event about a PID, it can record who the parent was so
@@ -217,7 +232,7 @@ also can do more such as
 
 There may also be a requirement to identify what functions with a program
 were generating events within the kernel. To begin this sort of analysis, the
-data must be recorded. At the time of writing, this required root
+data must be recorded.
 
   $ perf record -c 1 \
 	-e kmem:mm_page_alloc -e kmem:mm_page_free_direct \
@@ -226,10 +241,17 @@ data must be recorded. At the time of writing, this required root
   Time: 0.894
   [ perf record: Captured and wrote 0.733 MB perf.data (~32010 samples) ]
 
-Note the use of '-c 1' to set the event period to sample. The default sample
-period is quite high to minimise overhead but the information collected can be
+Note the use of '-c 1' to set the sample period. The default sample period
+is quite high to minimise overhead but the information collected can be
 very coarse as a result.
 
+The sample period is in units of "events occurred". For a hardware counter,
+this would usually mean the PMU is programmed to "raise an interrupt after
+this many events occured" and the event is recorded on interrupt receipt. For
+software-events such as tracepoints, one event will be recorded every
+"sample period" number of times the tracepoint triggered.  In this case,
+-c 1 means "record a sample every time this tracepoint is triggered".
+
 This record outputted a file called perf.data which can be analysed using
 perf report.
 
@@ -297,7 +319,8 @@ symbol.
        0.01%     Xorg  /opt/gfx-test/lib/libpixman-1.so.0.13.1  [.] get_fast_path
        0.00%     Xorg  [kernel]                                 [k] ftrace_trace_userstack
 
-To see where within the function pixmanFillsse2 things are going wrong
+Note here that kernel symbols are marked [k]. To see where within the
+function pixmanFillsse2 things are going wrong
 
   $ perf annotate pixmanFillsse2
   [ ... ]
@@ -323,5 +346,5 @@ To see where within the function pixmanFillsse2 things are going wrong
 At a glance, it looks like the time is being spent copying pixmaps to
 the card.  Further investigation would be needed to determine why pixmaps
 are being copied around so much but a starting point would be to take an
-ancient build of libpixmap out of the library path where it was totally
+ancient build of libpixman out of the library path where it was totally
 forgotten about from months ago!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
