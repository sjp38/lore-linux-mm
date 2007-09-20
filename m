Date: Thu, 20 Sep 2007 13:23:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 6/9] oom: add oom_kill_asking_task sysctl
In-Reply-To: <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adds a new sysctl, 'oom_kill_asking_task', which will automatically kill
the OOM-triggering task instead of scanning through the tasklist to find
a memory-hogging target.  This is helpful for systems with an insanely
large number of tasks where scanning the tasklist significantly degrades
performance.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |   22 ++++++++++++++++++++++
 kernel/sysctl.c             |    9 +++++++++
 mm/oom_kill.c               |   13 ++++++++-----
 3 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/vm:
 - min_unmapped_ratio
 - min_slab_ratio
 - panic_on_oom
+- oom_kill_asking_task
 - mmap_min_address
 - numa_zonelist_order
 
@@ -220,6 +221,27 @@ The default value is 0.
 1 and 2 are for failover of clustering. Please select either
 according to your policy of failover.
 
+=============================================================
+
+oom_kill_asking_task
+
+This enables or disables killing the OOM-triggering task in
+out-of-memory situations.
+
+If this is set to zero, the OOM killer will scan through the entire
+tasklist and select a task based on heuristics to kill.  This normally
+selects a rogue memory-hogging task that frees up a large amount of
+memory when killed.
+
+If this is set to non-zero, the OOM killer simply kills the task that
+triggered the out-of-memory condition.  This avoids the expensive
+tasklist scan.
+
+If panic_on_oom is selected, it takes precedence over whatever value
+is used in oom_kill_asking_task.
+
+The default value is 0.
+
 ==============================================================
 
 mmap_min_addr
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -63,6 +63,7 @@ extern int print_fatal_signals;
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern int sysctl_panic_on_oom;
+extern int sysctl_oom_kill_asking_task;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -798,6 +799,14 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "oom_kill_asking_task",
+		.data		= &sysctl_oom_kill_asking_task,
+		.maxlen		= sizeof(sysctl_oom_kill_asking_task),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_OVERCOMMIT_RATIO,
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 
 int sysctl_panic_on_oom;
+int sysctl_oom_kill_asking_task;
 static DEFINE_MUTEX(zone_scan_mutex);
 /* #define DEBUG */
 
@@ -478,14 +479,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 				"No available memory (MPOL_BIND)");
 		break;
 
-	case CONSTRAINT_CPUSET:
-		oom_kill_process(current, points,
-				"No available memory in cpuset");
-		break;
-
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom)
 			panic("out of memory. panic_on_oom is selected\n");
+		/* Fall-through */
+	case CONSTRAINT_CPUSET:
+		if (sysctl_oom_kill_asking_task) {
+			oom_kill_process(current, points,
+					"Out of memory (oom_kill_asking_task)");
+			break;
+		}
 retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
