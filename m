Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 868746B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 18:25:47 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f76so252712609vke.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 15:25:47 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id u28si983130qte.19.2016.09.11.15.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 15:25:46 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id n66so10523197qkf.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 15:25:46 -0700 (PDT)
Date: Sun, 11 Sep 2016 18:24:12 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [RFC] scripts: Include postprocessing script for memory allocation
 tracing
Message-ID: <20160911222411.GA2854@janani-Inspiron-3521>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org

The objective of this patch is to help users observe latencies in memory
allocation.
The function graph tracer is great for seeing how long functions took to
execute. And often, tracepoints, along with the tracer help understand
situations better. However, while it is possible to set a threshold for
function graph and have only the functions that exceed a certain
threshold appear in the output (by echoing the threshold value in
tracing_thresh in the tracing directory), there is no method to filter
out tracepoints that are not associated with functions whose latencies
exceed the threshold.

When the threshold is set high, it is possible that a lot of information
that is of little interest to the user is printed from the tracepoints.
Limiting this information can help reduce disk I/O significantly.

This patch deals with latencies in memory allocation and more
specifically, direct reclaim and compaction.

setup_alloc_trace.sh is a bash script which handles the initial the
setup of
function graph, specifies which functions to include in the output and
enables some tracepoints of interest. Upon exit, it clears all the
values set.

The functions traced currently are __alloc_pages_nodemask,
try_to_free_pages, mem_cgroup_soft_limit_reclaim, shrink_node,
shrink_node_memcg, shrink_slab, shrink_active_list,
shrink_inactive_list, compact_zone and try_to_compact_pages.

The tracepoints enabled are mm_shrink_slab_start,
mm_slab_slab_end, mm_vmscan_direct_reclaim_begin,
mm_vmscan_direct_reclaim_end, mm_vmscan_lru_shrink_inactive,
mm_compaction_begin, mm_compation_end,
mm_compaction_try_to_compact_pages.

More functions can be traced as desired by making changes to
setup_alloc_trace.sh accordingly.

allocation_postprocess.py is a script which reads from trace_pipe. It
does the following to filter out info from tracepoints that may not
be important:

1. Displays mm_vmscan_direct_reclaim_begin and
mm_vmscan_direct_reclaim_end only when try_to_free_pages has
exceeded the threshold.
2. Displays mm_compaction_begin and mm_compaction_end only when
compact_zone has exceeded the threshold.
3. Displays mm_compaction_try_to_compat_pages only when
try_to_compact_pages has exceeded the threshold.
4. Displays mm_shrink_slab_start and mm_shrink_slab_end only when
the time elapsed between them exceeds the threshold.
5. Displays mm_vmscan_lru_shrink_inactive only when shrink_inactive_list
has exceeded the threshold.

When CTRL+C is pressed, the script shows the times taken by the
shrinkers. However, currently it is not possible to differentiate among
the
superblock shrinkers.

Sample output:
^Ci915_gem_shrinker_scan : total time = 8.731000 ms, max latency =
0.278000 ms
ext4_es_scan : total time = 0.970000 ms, max latency = 0.129000 ms
scan_shadow_nodes : total time = 1.150000 ms, max latency = 0.175000 ms
super_cache_scan : total time = 8.455000 ms, max latency = 0.466000 ms
deferred_split_scan : total time = 25.767000 ms, max latency = 25.485000
ms

Usage:

# ./setup_alloc_trace.sh -t 134 -s /sys/kernel/debug/tracing > file.dat

Where -t represents threshold (134 us in this case) and -s represents
the path to the tracing diretory. The default is
/sys/kernel/debug/tracing, which is used when no path is specified.
The threshold on the other hand, must be set.

Ideas/ comments/ suggestions are welcome, escpecially on adherence to
the python coding style followed by the Linux community and the
functions enabled to be traced.

Thanks.

Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
---
 scripts/tracing/allocation_postprocess.py | 267 ++++++++++++++++++++++++++++++
 scripts/tracing/setup_alloc_trace.sh      |  88 ++++++++++
 2 files changed, 355 insertions(+)
 create mode 100755 scripts/tracing/allocation_postprocess.py
 create mode 100755 scripts/tracing/setup_alloc_trace.sh

diff --git a/scripts/tracing/allocation_postprocess.py b/scripts/tracing/allocation_postprocess.py
new file mode 100755
index 0000000..2f65457
--- /dev/null
+++ b/scripts/tracing/allocation_postprocess.py
@@ -0,0 +1,267 @@
+#!/usr/bin/env python
+# python 2.7
+
+"""
+This script uses function graph and some of the existing
+tracepoints to help people observe how long page allocations and some
+functions in the direct reclaim and compaction paths take.
+The functions and tracepoints enabled can be seen in setup_alloc_trace.sh.
+It reads from trace_pipe of the tracing directory and prints
+only those tracepoints and functions which are associated
+with latencies greater than the threshold specified.
+When CTRL+C is pressed, the times spent in the various shrinkers are displayed.
+The setup of trace is done in setup_alloc_trace.sh, from where this script is
+invoked.
+"""
+
+import argparse
+import re
+import sys
+import signal
+
+from collections import defaultdict
+
+# Constants for tracepoints
+
+DIRECT_RECLAIM_BEGIN        = 1
+DIRECT_RECLAIM_END          = 2
+SHRINK_SLAB_START           = 3
+SHRINK_INACTIVE_LIST        = 5
+TRY_TO_COMPACT              = 6
+COMPACTION_BEGIN            = 7
+COMPACTION_END              = 8
+
+SECS_TO_US                  = 1000000
+US_TO_MS                    = 1000
+
+# Parse command line arguments
+parser = argparse.ArgumentParser(description='Parser for latency analyzer')
+
+parser.add_argument('-s', '--source', action='store',
+                    default='/sys/kernel/debug/tracing',
+                    dest='source_path',
+                    help='Specify source file to read trace output')
+parser.add_argument('-t', '--threshold', action='store', default=0.0,
+                    dest='threshold', type=float)
+args = parser.parse_args()
+
+source_path = ''.join((args.source_path,'/trace_pipe'))
+threshold = args.threshold
+
+# Regexes
+line_pattern = re.compile(r'\s*(\d+\.\d+)\s+\|\s+\d*\)*\s+([\w-]+)\s+\|\s+.*\s+(\d*\.*\d*)\s+[us]{0,2}\s+\|\s+(.*)')
+tracepoint_pattern = re.compile(r'\/\*\s*([\w]*):\s*(.*)\s*\*\/')
+shrinker_pattern = re.compile(r'\s*([\w]*)\+(.*)\s*')
+function_end_pattern = re.compile(r'.*\/\*\s*([\w]*)\s*\*\/')
+
+# The dictionary which holds tracepoint information for all processes
+all_information = defaultdict(dict)
+
+# The dictionary which holds shrinker latencies
+shrinker_latencies = defaultdict(float)
+shrinker_max_latencies = defaultdict(float)
+
+def print_shrinker_latencies(signum, frame):
+    """ This function prints the time spent in each shrinker, when CTRL+C is 
+    pressed.
+    """
+
+    signal.signal(signal.SIGINT, original_sigint)
+    for key, value in shrinker_latencies.iteritems():
+        print '%s : total time = %f ms, max latency = %f ms' %(key,
+                                        value*US_TO_MS,
+                                        shrinker_max_latencies[key]*US_TO_MS)
+    sys.exit(0)
+
+original_sigint = signal.getsignal(signal.SIGINT)
+signal.signal(signal.SIGINT, print_shrinker_latencies)
+
+
+def set_begin_info(process, EVENT, timestamp, info):
+    """ This function sets information associated with mm_shrink_slab_start.
+    It sets the entire tracepoint info, along with the timestamp, which will
+    be used to calculate latencies when corresponding mm_ shrink_slab_end
+    tracepoints are encountered.
+    """
+
+    per_process_dict = all_information[process]
+    begin_info = {}
+    begin_info["data"] = info
+    begin_info["time"] = timestamp
+    per_process_dict[EVENT] = begin_info
+
+
+def set_trace_info(process, EVENT, info):
+    """ This function sets trace information associated with specific events.
+    """
+
+    per_process_dict = all_information[process]
+    per_process_dict[EVENT] = info
+
+
+def store_max_latency(shrinker_name, latency):
+    """ This function stores the maximum latency encountered in a shrinker. """
+
+    max_latency = shrinker_max_latencies[shrinker_name]
+    if latency > max_latency:
+        shrinker_max_latencies[shrinker_name] = latency
+
+
+def find_latency(process, BEGIN_EVENT, timestamp):
+    """ This function calculates shrinker latencies."""
+
+    per_process_dict = all_information.get(process, None)
+    if per_process_dict:
+        begin_info = per_process_dict.get(BEGIN_EVENT, None)
+        if begin_info:
+            begin_data = begin_info.get("data", None)
+            begin_time = begin_info.get("time", None)
+            if begin_time:
+                time_elapsed = float(timestamp) - float(begin_time)
+                if time_elapsed*SECS_TO_US > threshold:
+                    return (True, begin_data, time_elapsed)
+                return (False, begin_data, time_elapsed)
+    return (False, None, 0.0)
+
+
+def print_line(line_info):
+    print line_info,
+
+
+def print_tracepoint(process, EVENT, info):
+    if info:
+        print info,
+    else:
+        per_process_dict = all_information.get(process, None)
+        TP_info = per_process_dict.get(EVENT, None)
+        if TP_info:
+            print TP_info,
+        per_process_dict.pop(EVENT, None)
+
+with open(source_path) as f:
+    for line in f:
+        line_match = re.match(line_pattern, line)
+        if line_match:
+            timestamp = line_match.group(1)
+            process_info = line_match.group(2)
+            function_match = re.match(function_end_pattern, line_match.group(4))
+            tracepoint_match = re.match(tracepoint_pattern, line_match.group(4))
+            if tracepoint_match:
+                TP_whole = line_match.group(4)
+                TP_name = tracepoint_match.group(1)
+                TP_info = tracepoint_match.group(2)
+
+
+                def call_set_trace_info(EVENT):
+                    set_trace_info(process_info, EVENT, line)
+
+
+                def direct_reclaim_b():
+                    call_set_trace_info(DIRECT_RECLAIM_BEGIN)
+
+
+                def direct_reclaim_e():
+                    call_set_trace_info(DIRECT_RECLAIM_END)
+
+
+                def shrink_inactive_list():
+                    call_set_trace_info(SHRINK_INACTIVE_LIST)
+
+
+                def shrink_slab_b():
+                    set_begin_info(process_info, SHRINK_SLAB_START, timestamp,
+                                    line)
+
+
+                def shrink_slab_e():
+                    delay_status, begin_data, time_elapsed = find_latency(
+                                                                process_info,
+                                                                SHRINK_SLAB_START,
+                                                                timestamp)
+                    shrinker_match = re.match(shrinker_pattern, TP_info)
+                    if shrinker_match:
+                        shrinker_name = shrinker_match.group(1)
+                        shrinker_latencies[shrinker_name] += time_elapsed
+                        store_max_latency(shrinker_name, time_elapsed)
+
+                    if delay_status:
+                        print_tracepoint(process_info,
+                                         SHRINK_SLAB_START,
+                                         begin_data)
+                        print_tracepoint(process_info,
+                                         None,
+                                         line)
+
+
+                def try_to_compact():
+                    call_set_trace_info(TRY_TO_COMPACT)
+
+
+                def compact_b():
+                    call_set_trace_info(COMPACTION_BEGIN)
+
+
+                def compact_e():
+                    call_set_trace_info(COMPACTION_END)
+
+
+                trace_match = {'mm_vmscan_direct_reclaim_begin' : direct_reclaim_b,
+                               'mm_vmscan_direct_reclaim_end'   : direct_reclaim_e,
+                               'mm_shrink_slab_start'           : shrink_slab_b,
+                               'mm_shrink_slab_end'             : shrink_slab_e,
+                               'mm_vmscan_lru_shrink_inactive'  :
+                                                              shrink_inactive_list,
+                               'mm_compaction_try_to_compact_pages':
+                                                              try_to_compact,
+                               'mm_compaction_begin'            : compact_b,
+                               'mm_compaction_end'              : compact_e}
+
+                if TP_name in trace_match:
+                    trace_match[TP_name]()
+                else:
+                    pass
+
+            else:
+                function_match = re.match(function_end_pattern,
+                                          line_match.group(4))
+                if function_match:
+                    function_name = function_match.group(1)
+
+
+                    def alloc_pages():
+                        print_line(line)
+                        all_information.pop(process_info, None)
+
+
+                    def try_to_free_pages():
+                        print_tracepoint(process_info, DIRECT_RECLAIM_BEGIN, None)
+                        print_tracepoint(process_info, DIRECT_RECLAIM_END, None)
+                        print_line(line)
+
+
+                    def shrink_inactive_list():
+                        print_tracepoint(process_info, SHRINK_INACTIVE_LIST, None)
+                        print_line(line)
+
+
+                    def try_to_compact():
+                        print_tracepoint(process_info, TRY_TO_COMPACT, None)
+                        print_line(line)
+
+
+                    def compact_zone():
+                        print_tracepoint(process_info, COMPACTION_BEGIN, None)
+                        print_tracepoint(process_info, COMPACTION_END, None)
+                        print_line(line)
+
+
+                    f_match = {'__alloc_pages_nodemask' : alloc_pages,
+                               'try_to_free_pages'      : try_to_free_pages,
+                               'shrink_inactive_list'   : shrink_inactive_list,
+                               'try_to_compact'         : try_to_compact,
+                               'compact_zone'           : compact_zone}
+
+                    if function_name in f_match:
+                        f_match[function_name]()
+                    else:
+                        print_line(line)
diff --git a/scripts/tracing/setup_alloc_trace.sh b/scripts/tracing/setup_alloc_trace.sh
new file mode 100755
index 0000000..9a558b0
--- /dev/null
+++ b/scripts/tracing/setup_alloc_trace.sh
@@ -0,0 +1,88 @@
+#! /bin/bash
+
+# This script does all the basic setup necessary for allocation_postprocess.py
+# and then invokes the script. All the setup that is done at the beginning
+# is cleared on exit.
+
+# Usage: # ./setup_alloc_trace.sh -t THRESHOLD_IN_US -s
+# path/to/tracing/directory > path/to/output/file.
+
+while getopts :t:s: name
+do
+	case $name in
+		t)threshold=$OPTARG;;
+		s)trace_dir=$OPTARG;;
+		*) echo "Usage: ./setup_alloc_trace.sh -t THRESHOLD_IN_US -s path/to/tracing/directory"
+		esac
+done
+
+if [[ -z $threshold ]]
+then
+	echo "Must specify threshold."
+	exit 1
+fi
+
+if [[ -z $trace_dir ]]
+then
+	trace_dir="/sys/kernel/debug/tracing"
+fi
+
+pwd=`pwd`
+cd $trace_dir
+echo 0 > tracing_on
+
+echo function_graph > current_tracer
+echo funcgraph-proc > trace_options
+echo funcgraph-abstime > trace_options
+
+# set filter functions
+echo __alloc_pages_nodemask > set_ftrace_filter
+echo try_to_free_pages >> set_ftrace_filter
+echo mem_cgroup_soft_limit_reclaim >> set_ftrace_filter
+echo shrink_node >> set_ftrace_filter
+echo shrink_node_memcg >> set_ftrace_filter
+echo shrink_slab >> set_ftrace_filter
+echo shrink_active_list >> set_ftrace_filter
+echo shrink_inactive_list >> set_ftrace_filter
+echo compact_zone >> set_ftrace_filter
+echo try_to_compact_pages >> set_ftrace_filter
+
+echo $threshold > tracing_thresh
+
+# set tracepoints
+echo 1 > events/vmscan/mm_shrink_slab_start/enable
+echo 1 > events/vmscan/mm_shrink_slab_end/enable
+echo 1 > events/vmscan/mm_vmscan_direct_reclaim_begin/enable
+echo 1 > events/vmscan/mm_vmscan_direct_reclaim_end/enable
+echo 1 > events/vmscan/mm_vmscan_lru_shrink_inactive/enable
+echo 1 > events/compaction/mm_compaction_begin/enable
+echo 1 > events/compaction/mm_compaction_end/enable
+echo 1 > events/compaction/mm_compaction_try_to_compact_pages/enable
+echo 1 > tracing_on
+
+cd $pwd
+
+./allocation_postprocess.py -t $threshold -s $trace_dir
+
+function cleanup {
+	cd $trace_dir
+	echo 0 > tracing_on
+	echo nop > current_tracer
+	echo > set_ftrace_filter
+	echo 0 > tracing_thresh
+
+	echo 0 > events/vmscan/mm_shrink_slab_start/enable
+	echo 0 > events/vmscan/mm_shrink_slab_end/enable
+	echo 0 > events/vmscan/mm_vmscan_direct_reclaim_begin/enable
+	echo 0 > events/vmscan/mm_vmscan_direct_reclaim_end/enable
+	echo 0 > events/vmscan/mm_vmscan_lru_shrink_inactive/enable
+	echo 0 > events/compaction/mm_compaction_begin/enable
+	echo 0 > events/compaction/mm_compaction_end/enable
+	echo 0 > events/compaction/mm_compaction_try_to_compact_pages/enable
+
+	exit $?
+}
+
+trap cleanup SIGINT
+trap cleanup SIGTERM
+trap cleanup EXIT
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
