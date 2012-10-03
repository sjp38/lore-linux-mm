Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1A4756B00DA
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:52:25 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/33] autonuma: add Documentation/vm/autonuma.txt
Date: Thu,  4 Oct 2012 01:50:43 +0200
Message-Id: <1349308275-2174-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

From: Karen Noel <knoel@redhat.com>

Documentation of the AutoNUMA design.

Signed-off-by: Karen Noel <knoel@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/autonuma.txt |  364 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 364 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/vm/autonuma.txt

diff --git a/Documentation/vm/autonuma.txt b/Documentation/vm/autonuma.txt
new file mode 100644
index 0000000..70d40b8
--- /dev/null
+++ b/Documentation/vm/autonuma.txt
@@ -0,0 +1,364 @@
+= AutoNUMA Documentation =
+
+Table of Contents:
+
+    I:   Intruduction to AutoNUMA
+    II:  AutoNUMA Daemons and Algorithms
+         knuma_scand - the page scanning daemon
+         NUMA hinting fault
+         Migrate-on-fault
+         sched_autonuma_balance - the AutoNUMA balance routine
+         Scheduler load balancing
+    III: AutoNUMA Data Structures
+         mm_autonuma - per process mm AutoNUMA data
+         task_autonuma - per task AutoNUMA data
+         page_autonuma - per page AutoNUMA data
+         pte and pmd - NUMA flags
+    IV:  Definition of AutoNUMA "Active"
+    V:   AutoNUMA Flags
+
+== I: Introduction to AutoNUMA ==
+
+AutoNUMA was introduced to the Linux kernel to improve the performance
+of applications running on NUMA hardware systems. The fundamental
+principle is that an application will perform best when the threads of
+its processes are accessing memory on the same NUMA node as the
+threads are scheduled.
+
+AutoNUMA moves tasks, which can be threads or processes, closer to the
+memory they are accessing. It also moves application data to memory
+closer to the tasks that reference it. This is all done automatically
+by the kernel when AutoNUMA is active. (See seciton IV for the
+definition of when AutoNUMA is active.)
+
+The following daemons are started and algorithms executed only if
+AutoNUMA is active on the system. No memory is allocated for AutoNUMA
+data structures if AutoNUMA is not active at boot time.
+
+== II: AutoNUMA Daemons and Algorithms ==
+
+The following sections describe the basic flow, or chain reaction, of
+AutoNUMA events.
+
+=== knuma_scand - the page scanning daemon ===
+
+The AutoNUMA logic is a chain reaction resulting from the actions of
+the AutoNUMA daemon, knum_scand. The knuma_scand daemon periodically
+scans the mm structures of all active processes. It gathers the
+AutoNUMA mm statistics for each "anon" page in the process's working
+set. While scanning, knuma_scand also sets the NUMA bit and clears the
+present bit in each pte or pmd that was counted. This triggers NUMA
+hinting page faults described next.
+
+The mm statistics are expentially decayed by dividing the total memory
+in half and adding the new totals to the decayed values for each
+knuma_scand pass. This causes the mm statistics to resemble a simple
+forecasting model, taking into account some past working set data.
+
+=== NUMA hinting fault ===
+
+A NUMA hinting fault occurs when a task running on a CPU thread
+accesses a vma whose pte or pmd is not present and the NUMA bit is
+set. The NUMA hinting page fault handler returns the pte or pmd back
+to its present state and counts the fault's occurance in the
+task_autonuma structure.
+
+The NUMA hinting fault gathers the AutoNUMA task statistics as follows:
+
+- Increments the total number of pages faulted for this task
+
+- Increments the number of pages faulted on the current NUMA node
+
+- If the fault was for an hugepage, the number of subpages represented
+  by an hugepage is added to the task statistics above
+
+- Each time the NUMA hinting page fault discoveres that another
+  knuma_scand pass has occurred, it divides the total number of pages
+  and the pages for each NUMA node in half. This causes the task
+  statistics to be exponentially decayed, just as the mm statistics
+  are. Thus, the task statistics also resemble a simple forcasting
+  model, taking into account some past NUMA hinting fault data.
+
+If the page being accessed is on the current NUMA node (same as the
+task), the NUMA hinting fault handler only records the nid of the
+current NUMA node in the page_autonuma structure field last_nid and
+then it'd done.
+
+Othewise, it checks if the nid of the current NUMA node matches the
+last_nid in the page_autonuma structure. If it matches it means it's
+the second NUMA hinting fault for the page occurring (on a subsequent
+pass of the knuma_scand daemon) from the current NUMA node. So if it
+matches, the NUMA hinting fault handler migrates the contents of the
+page to a new page on the current NUMA node.
+
+If the NUMA node accessing the page does not match last_nid, then
+last_nid is reset to the current NUMA node (since it is considered the
+first fault again).
+
+Note: You can clear a flag (AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT) which
+causes the page to be migrated on the second NUMA hinting fault
+instead of the very first one for a newly allocated page.
+
+=== Migrate-on-Fault (MoF) ===
+
+If the migrate-on-fault logic is active and the NUMA hinting fault
+handler determines that the page should be migrated, a new page is
+allocated on the current NUMA node and the data is copied from the
+previous page on the remote node to the new page. The associated pte
+or pmd is modified to reference the pfn of the new page, and the
+previous page is freed to the LRU of its NUMA node. See routine
+migrate_pages() in mm/migrate.c.
+
+If no page is available on the current NUMA node or I/O is in progress
+on the page, it is not migrated and the task continues to reference
+the remote page.
+
+=== sched_autonuma_balance - the AutoNUMA balance routine ===
+
+The AutoNUMA balance routine is responsible for deciding which NUMA
+node is the best for running the current task and potentially which
+task on the remote node it should be exchanged with. It uses the mm
+statistics collected by the knuma_scand daemon and the task statistics
+collected by the NUMA hinting fault to make this decision.
+
+The AutoNUMA balance routine is invoked as part of the scheduler load
+balancing code. It exchanges the task on the current CPU's run queue
+with a current task from a remote NUMA node if that exchange would
+result in the tasks running with a smaller percentage of cross-node
+memory accesses. Because the balance routine involves only running
+tasks, it is only invoked when the scheduler is not idle
+balancing. This means that the CFS scheduler is in control of
+scheduling decsions and can move tasks to idle threads on any NUMA
+node based on traditional or new policies.
+
+The following defines "memory weight" and "task weight" in the
+AutoNUMA balance routine's algorithms.
+
+- memory weight = % of total memory from the NUMA node. Uses mm
+                  statistics collected by the knuma_scand daemon.
+
+- task weight = % of total memory faulted on the NUMA node. Uses task
+                statistics collected by the NUMA hinting fault.
+
+=== task_selected_nid - The AutoNUMA preferred NUMA node ===
+
+The AutoNUMA balance routine first determines which NUMA node the
+current task has the most affinity to run on, based on the maximum
+task weight and memory weight for each NUMA node. If both max values
+are for the same NUMA node, that node's nid is stored in
+task_selected_nid.
+
+If the selected nid is the current NUMA node, the AutoNUMA balance
+routine is finished and does not proceed to compare tasks on other
+NUMA nodes.
+
+If the selected nid is not the current NUMA node, a task exchange is
+possible as described next. (Note that the task exchange algorithm
+might update task_selected_nid to a different NUMA node)
+
+=== Task exchange ===
+
+The following defines "weight" in the AutoNUMA balance routine's
+algorithm.
+
+If the tasks are threads of the same process:
+
+    weight = task weight for the NUMA node (since memory weights are
+             the same)
+
+If the tasks are not threads of the same process:
+
+    weight = memory weight for the NUMA node (prefer to move the task
+             to the memory)
+
+The following algorithm determines if the current task will be
+exchanged with a running task on a remote NUMA node:
+
+    this_diff: Weight of the current task on the remote NUMA node
+               minus its weight on the current NUMA node (only used if
+               a positive value). How much does the current task
+               prefer to run on the remote NUMA node.
+
+    other_diff: Weight of the current task on the remote NUMA node
+                minus the weight of the other task on the same remote
+                NUMA node (only used if a positive value). How much
+                does the current task prefer to run on the remote NUMA
+                node compared to the other task.
+
+    total_weight_diff = this_diff + other_diff
+
+    total_weight_diff: How favorable it is to exchange the two tasks.
+                       The pair of tasks with the highest
+                       total_weight_diff (if any) are selected for
+                       exchange.
+
+As mentioned above, if the two tasks are threads of the same process,
+the AutoNUMA balance routine uses the task_autonuma statistics. By
+using the task_autonuma statistics, each thread follows its own memory
+locality and they will not necessarily converge on the same node. This
+is often very desirable for processes with more threads than CPUs on
+each NUMA node.
+
+If the two tasks are not threads of the same process, the AutoNUMA
+balance routine uses the mm_autonuma statistics to calculate the
+memory weights. This way all threads of the same process converge to
+the same node, which is the one with the highest percentage of memory
+for the process.
+
+If task_selected_nid, determined above, is not the NUMA node the
+current task will be exchanged to, task_selected_nid for this task is
+updated. This causes the AutoNUMA balance routine to favor overall
+balance of the system over a single task's preference for a NUMA node.
+
+To exchange the two tasks, the AutoNUMA balance routine stops the CPU
+that is running the remote task and exchanges the tasks on the two run
+queues. Once each task has been moved to another node, closer to most
+of the memory it is accessing, any memory for that task not in the new
+NUMA node also moves to the NUMA node over time with the
+migrate-on-fault logic.
+
+=== Scheduler Load Balancing ===
+
+Load balancing, which affects fairness more than performance,
+schedules based on AutoNUMA recommendations (task_selected_nid) unless
+the flag AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG is set.
+
+The CFS load balancer uses the task's AutoNUMA task_selected_nid when
+deciding to move a task to a different run-queue or when waking it
+up. For example, idle balancing while looking into the run-queues of
+busy CPUs, first looks for a task with task_selected_nid set to the
+NUMA node of the idle CPU. Idle balancing falls back to scheduling
+tasks without task_selected_nid set or with a different NUMA node set
+in task_selected_nid. This allows a task to move to a different NUMA
+node and its memory will follow it to the new NUMA node over time.
+
+== III: AutoNUMA Data Structures ==
+
+The following data structures are defined for AutoNUMA. All structures
+are allocated only if AutoNUMA is active (as defined in the
+introduction).
+
+=== mm_autonuma - per process mm AutoNUMA data ===
+
+The mm_autonuma structure is used to hold AutoNUMA data required for
+each mm structure. Total size: 32 bytes + 8 * # of NUMA nodes.
+
+- Link of mm structures to be scanned by knuma_scand (8 bytes)
+
+- Pointer to associated mm structure (8 bytes)
+
+- fault_pass - pass number of knuma_scand (8 bytes)
+
+- Memory NUMA statistics for this process:
+
+    Total number of anon pages in the process working set (8 bytes)
+
+    Per NUMA node number of anon pages in the process working set (8
+    bytes * # of NUMA nodes)
+
+=== task_autonuma - per task AutoNUMA data ===
+
+The task_autonuma structure is used to hold AutoNUMA data required for
+each mm task (process/thread). Total size: 10 bytes + 8 * # of NUMA
+nodes.
+
+- selected_nid: preferred NUMA node as determined by the AutoNUMA
+                scheduler balancing code, -1 if none (2 bytes)
+
+- Task NUMA statistics for this thread/process:
+
+    Total number of NUMA hinting page faults in this pass of
+    knuma_scand (8 bytes)
+
+    Per NUMA node number of NUMA hinting page faults in this pass of
+    knuma_scand (8 bytes * # of NUMA nodes)
+
+=== page_autonuma - per page AutoNUMA data ===
+
+The page_autonuma structure is used to hold AutoNUMA data required for
+each page of memory. Total size: 2 bytes
+
+    last_nid - NUMA node for last time this page incurred a NUMA
+               hinting fault, -1 if none (2 bytes)
+
+=== pte and pmd - NUMA flags ===
+
+A bit in pte and pmd structures are used to indicate to the page fault
+handler that the fault was incurred for NUMA purposes.
+
+    _PAGE_NUMA: a NUMA hinting fault at either the pte or pmd level (1
+                bit)
+
+        The same bit used for _PAGE_PROTNONE is used for
+        _PAGE_NUMA. This is okay because all uses of _PAGE_PROTNONE
+        are mutually exclusive of _PAGE_NUMA.
+
+Note: NUMA hinting fault at the pmd level is only used on
+architectures where pmd granularity is supported.
+
+== IV: AutoNUMA Active ==
+
+AutoNUMA is considered active when each of the following 4 conditions
+are met:
+
+- AutoNUMA is compiled into the kernel
+
+    CONFIG_AUTONUMA=y
+
+- The hardware has NUMA properties
+
+- AutoNUMA is enabled at boot time
+
+    "noautonuma" not passed to the kernel command line
+
+- AutoNUMA is enabled dynamically at run-time
+
+    CONFIG_AUTONUMA_DEFAULT_ENABLED=y
+
+  or
+
+    echo 1 >/sys/kernel/mm/autonuma/enabled
+
+== V: AutoNUMA Flags ==
+
+AUTONUMA_POSSIBLE_FLAG: The kernel was not passed the "noautonuma"
+                        boot parameter and is being run on NUMA
+                        hardware.
+
+AUTONUMA_ENABLED_FLAG: AutoNUMA is enabled (default set at compile
+                       time).
+
+AUTONUMA_DEBUG_FLAG (default 0): printf lots of debug info, set
+		                 through sysfs
+
+AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG (default 0): AutoNUMA will
+                                                     prioritize on
+                                                     NUMA affinity and
+                                                     will disregard
+                                                     inter-node
+                                                     fairness.
+
+AUTONUMA_CHILD_INHERITANCE_FLAG (default 1): AutoNUMA statistics are
+                                             copied to the child at
+                                             every fork/clone instead
+                                             of resetting them like it
+                                             happens unconditionally
+                                             in execve.
+
+AUTONUMA_SCAN_PMD_FLAG (default 1): trigger NUMA hinting faults for
+                                    the pmd level instead of just the
+                                    pte level (note: for THP, NUMA
+                                    hinting faults always occur at the
+                                    pmd level)
+
+AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG (default 0): page is migrated
+                                                     on first NUMA
+                                                     hinting fault
+                                                     instead of second
+
+AUTONUMA_MM_WORKING_SET_FLAG (default 1): mm_autonuma represents a
+                                          working set estimation of
+                                          the memory used by the
+                                          process
+
+Contributors: Andrea Arcangeli, Karen Noel, Rik van Riel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
