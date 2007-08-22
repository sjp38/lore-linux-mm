Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 24 of 24] add oom_kill_asking_task flag
Message-Id: <96b5899e730ecaa20788.1187786951@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:11 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User David Rientjes <rientjes@google.com>
# Date 1187778125 -7200
# Node ID 96b5899e730ecaa2078883f75e86765fa1a36431
# Parent  a3d679df54ebb1f977b97ab6b3e501134bf9e7ef
add oom_kill_asking_task flag

Adds an oom_kill_asking_task flag to cpusets.  If unset (by default), we
iterate through the task list via select_bad_process() during a
cpuset-constrained OOM to find the best candidate task to kill.  If set,
we simply kill current to avoid the overhead which is needed for some
customers with a large number of threads or heavy workload.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cpusets.txt |    3 +++
 include/linux/cpuset.h    |    5 +++++
 kernel/cpuset.c           |   39 ++++++++++++++++++++++++++++++++++++++-
 mm/oom_kill.c             |    7 +++++++
 4 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/Documentation/cpusets.txt b/Documentation/cpusets.txt
--- a/Documentation/cpusets.txt
+++ b/Documentation/cpusets.txt
@@ -181,6 +181,9 @@ containing the following files describin
  - tasks: list of tasks (by pid) attached to that cpuset
  - notify_on_release flag: run /sbin/cpuset_release_agent on exit?
  - memory_pressure: measure of how much paging pressure in cpuset
+ - oom_kill_asking_task flag: when this cpuset OOM's, should we kill
+	the task that asked for the memory or should we iterate through
+	the task list to find the best task to kill (can be expensive)?
 
 In addition, the root cpuset only has the following file:
  - memory_pressure_enabled flag: compute memory_pressure?
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -52,6 +52,7 @@ extern void cpuset_set_last_tif_memdie(s
 				       unsigned long last_tif_memdie);
 extern int cpuset_set_oom(struct task_struct *task);
 extern void cpuset_clear_oom(struct task_struct *task);
+extern int cpuset_oom_kill_asking_task(struct task_struct *task);
 
 #define cpuset_memory_pressure_bump() 				\
 	do {							\
@@ -136,6 +137,10 @@ static inline int cpuset_set_oom(struct 
 	return 0;
 }
 static inline void cpuset_clear_oom(struct task_struct *task) {}
+static inline int cpuset_oom_kill_asking_task(struct task_struct *task)
+{
+	return 0;
+}
 
 static inline void cpuset_memory_pressure_bump(void) {}
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -116,6 +116,7 @@ typedef enum {
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
 	CS_OOM,
+	CS_OOM_KILL_ASKING_TASK,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -157,6 +158,11 @@ static inline int is_oom(const struct cp
 static inline int is_oom(const struct cpuset *cs)
 {
 	return test_bit(CS_OOM, &cs->flags);
+}
+
+static inline int is_oom_kill_asking_task(const struct cpuset *cs)
+{
+	return test_bit(CS_OOM_KILL_ASKING_TASK, &cs->flags);
 }
 
 /*
@@ -1068,7 +1074,8 @@ static int update_memory_pressure_enable
  * update_flag - read a 0 or a 1 in a file and update associated flag
  * bit:	the bit to update (CS_CPU_EXCLUSIVE, CS_MEM_EXCLUSIVE,
  *				CS_NOTIFY_ON_RELEASE, CS_MEMORY_MIGRATE,
- *				CS_SPREAD_PAGE, CS_SPREAD_SLAB)
+ *				CS_SPREAD_PAGE, CS_SPREAD_SLAB,
+ *				CS_OOM_KILL_ASKING_TASK)
  * cs:	the cpuset to update
  * buf:	the buffer where we read the 0 or 1
  *
@@ -1320,6 +1327,7 @@ typedef enum {
 	FILE_NOTIFY_ON_RELEASE,
 	FILE_MEMORY_PRESSURE_ENABLED,
 	FILE_MEMORY_PRESSURE,
+	FILE_OOM_KILL_ASKING_TASK,
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
 	FILE_TASKLIST,
@@ -1382,6 +1390,9 @@ static ssize_t cpuset_common_file_write(
 	case FILE_MEMORY_PRESSURE:
 		retval = -EACCES;
 		break;
+	case FILE_OOM_KILL_ASKING_TASK:
+		retval = update_flag(CS_OOM_KILL_ASKING_TASK, cs, buffer);
+		break;
 	case FILE_SPREAD_PAGE:
 		retval = update_flag(CS_SPREAD_PAGE, cs, buffer);
 		cs->mems_generation = cpuset_mems_generation++;
@@ -1499,6 +1510,9 @@ static ssize_t cpuset_common_file_read(s
 	case FILE_MEMORY_PRESSURE:
 		s += sprintf(s, "%d", fmeter_getrate(&cs->fmeter));
 		break;
+	case FILE_OOM_KILL_ASKING_TASK:
+		*s++ = is_oom_kill_asking_task(cs) ? '1' : '0';
+		break;
 	case FILE_SPREAD_PAGE:
 		*s++ = is_spread_page(cs) ? '1' : '0';
 		break;
@@ -1861,6 +1875,11 @@ static struct cftype cft_memory_pressure
 static struct cftype cft_memory_pressure = {
 	.name = "memory_pressure",
 	.private = FILE_MEMORY_PRESSURE,
+};
+
+static struct cftype cft_oom_kill_asking_task = {
+	.name = "oom_kill_asking_task",
+	.private = FILE_OOM_KILL_ASKING_TASK,
 };
 
 static struct cftype cft_spread_page = {
@@ -1891,6 +1910,8 @@ static int cpuset_populate_dir(struct de
 		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_memory_pressure)) < 0)
 		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_oom_kill_asking_task)) < 0)
+		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_spread_page)) < 0)
 		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_spread_slab)) < 0)
@@ -1923,6 +1944,8 @@ static long cpuset_create(struct cpuset 
 	cs->flags = 0;
 	if (notify_on_release(parent))
 		set_bit(CS_NOTIFY_ON_RELEASE, &cs->flags);
+	if (is_oom_kill_asking_task(parent))
+		set_bit(CS_OOM_KILL_ASKING_TASK, &cs->flags);
 	if (is_spread_page(parent))
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
 	if (is_spread_slab(parent))
@@ -2661,6 +2684,20 @@ void cpuset_clear_oom(struct task_struct
 }
 
 /*
+ * Returns 1 if current should simply be killed when a cpuset-constrained OOM
+ * occurs.  Otherwise, we iterate through the task list and select the best
+ * candidate we can find.
+ */
+int cpuset_oom_kill_asking_task(struct task_struct *task)
+{
+	int ret;
+	task_lock(task);
+	ret = is_oom_kill_asking_task(task->cpuset);
+	task_unlock(task);
+	return ret;
+}
+
+/*
  * Collection of memory_pressure is suppressed unless
  * this flag is enabled by writing "1" to the special
  * cpuset file 'memory_pressure_enabled' in the root cpuset.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -457,6 +457,13 @@ void out_of_memory(struct zonelist *zone
 
 	case CONSTRAINT_CPUSET:
 		read_lock(&tasklist_lock);
+		if (cpuset_oom_kill_asking_task(current)) {
+			oom_kill_process(current, 0,
+					 "No available memory in cpuset", gfp_mask,
+					 order);
+			goto out_cpuset;
+		}
+
 		last_tif_memdie = cpuset_get_last_tif_memdie(current);
 		/*
 		 * If current's cpuset is already in the OOM killer or its killed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
