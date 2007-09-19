Date: Wed, 19 Sep 2007 11:24:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 5/8] oom: add per-cpuset file oom_kill_asking_task
In-Reply-To: <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adds a per-cpuset file 'oom_kill_asking_task', which by default is set to
zero.  If enabled, current is always killed whenever a cpuset-constrained
OOM is triggered; otherwise, the tasklist is scanned for a memory-
hogging task to kill.  Those tasks that do not share exclusive memory
nodes with current are penalized by eight times in the badness scoring.

The value of 'oom_kill_asking_task' is inherited from parent cpusets.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cpusets.txt |    6 +++++-
 include/linux/cpuset.h    |    7 +++++++
 kernel/cpuset.c           |   34 +++++++++++++++++++++++++++++++++-
 mm/oom_kill.c             |   10 ++++++++++
 4 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/Documentation/cpusets.txt b/Documentation/cpusets.txt
--- a/Documentation/cpusets.txt
+++ b/Documentation/cpusets.txt
@@ -181,6 +181,9 @@ containing the following files describing that cpuset:
  - tasks: list of tasks (by pid) attached to that cpuset
  - notify_on_release flag: run /sbin/cpuset_release_agent on exit?
  - memory_pressure: measure of how much paging pressure in cpuset
+ - oom_kill_asking_task: in OOM situations, always kill the task that
+	triggered the condition and avoid scanning the tasklist to find
+	the ideal target
 
 In addition, the root cpuset only has the following file:
  - memory_pressure_enabled flag: compute memory_pressure?
@@ -351,7 +354,8 @@ except perhaps as modified by the tasks NUMA mempolicy or cpuset
 configuration, so long as sufficient free memory pages are available.
 
 When new cpusets are created, they inherit the memory spread settings
-of their parent.
+and OOM killer behavior as specified by oom_kill_asking_task of their
+parent.
 
 Setting memory spreading causes allocations for the affected page
 or slab caches to ignore the tasks NUMA mempolicy and be spread
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -75,6 +75,8 @@ static inline int cpuset_do_slab_mem_spread(void)
 
 extern void cpuset_track_online_nodes(void);
 
+extern int oom_kill_asking_task(const struct task_struct *task);
+
 #else /* !CONFIG_CPUSETS */
 
 static inline int cpuset_init_early(void) { return 0; }
@@ -146,6 +148,11 @@ static inline int cpuset_do_slab_mem_spread(void)
 
 static inline void cpuset_track_online_nodes(void) {}
 
+static inline int oom_kill_asking_task(const struct task_struct *task)
+{
+	return 1;
+}
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -107,6 +107,7 @@ typedef enum {
 	CS_MEMORY_MIGRATE,
 	CS_REMOVED,
 	CS_NOTIFY_ON_RELEASE,
+	CS_OOM_KILL_ASKING_TASK,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
 } cpuset_flagbits_t;
@@ -132,6 +133,11 @@ static inline int notify_on_release(const struct cpuset *cs)
 	return test_bit(CS_NOTIFY_ON_RELEASE, &cs->flags);
 }
 
+static inline int is_oom_kill_asking_task(const struct cpuset *cs)
+{
+	return test_bit(CS_OOM_KILL_ASKING_TASK, &cs->flags);
+}
+
 static inline int is_memory_migrate(const struct cpuset *cs)
 {
 	return test_bit(CS_MEMORY_MIGRATE, &cs->flags);
@@ -1056,7 +1062,8 @@ static int update_memory_pressure_enabled(struct cpuset *cs, char *buf)
  * update_flag - read a 0 or a 1 in a file and update associated flag
  * bit:	the bit to update (CS_CPU_EXCLUSIVE, CS_MEM_EXCLUSIVE,
  *				CS_NOTIFY_ON_RELEASE, CS_MEMORY_MIGRATE,
- *				CS_SPREAD_PAGE, CS_SPREAD_SLAB)
+ *				CS_OOM_KILL_ASKING_TASK, CS_SPREAD_PAGE,
+ *				CS_SPREAD_SLAB)
  * cs:	the cpuset to update
  * buf:	the buffer where we read the 0 or 1
  *
@@ -1299,6 +1306,7 @@ typedef enum {
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
 	FILE_TASKLIST,
+	FILE_OOM_KILL_ASKING_TASK,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct file *file,
@@ -1369,6 +1377,9 @@ static ssize_t cpuset_common_file_write(struct file *file,
 	case FILE_TASKLIST:
 		retval = attach_task(cs, buffer, &pathbuf);
 		break;
+	case FILE_OOM_KILL_ASKING_TASK:
+		retval = update_flag(CS_OOM_KILL_ASKING_TASK, cs, buffer);
+		break;
 	default:
 		retval = -EINVAL;
 		goto out2;
@@ -1481,6 +1492,9 @@ static ssize_t cpuset_common_file_read(struct file *file, char __user *buf,
 	case FILE_SPREAD_SLAB:
 		*s++ = is_spread_slab(cs) ? '1' : '0';
 		break;
+	case FILE_OOM_KILL_ASKING_TASK:
+		*s++ = is_oom_kill_asking_task(cs) ? '1' : '0';
+		break;
 	default:
 		retval = -EINVAL;
 		goto out;
@@ -1849,6 +1863,11 @@ static struct cftype cft_spread_slab = {
 	.private = FILE_SPREAD_SLAB,
 };
 
+static struct cftype cft_oom_kill_asking_task = {
+	.name = "oom_kill_asking_task",
+	.private = FILE_OOM_KILL_ASKING_TASK,
+};
+
 static int cpuset_populate_dir(struct dentry *cs_dentry)
 {
 	int err;
@@ -1873,6 +1892,8 @@ static int cpuset_populate_dir(struct dentry *cs_dentry)
 		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_tasks)) < 0)
 		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_oom_kill_asking_task)) < 0)
+		return err;
 	return 0;
 }
 
@@ -1903,6 +1924,8 @@ static long cpuset_create(struct cpuset *parent, const char *name, int mode)
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
+	if (is_oom_kill_asking_task(parent))
+		set_bit(CS_OOM_KILL_ASKING_TASK, &cs->flags);
 	cs->cpus_allowed = CPU_MASK_NONE;
 	cs->mems_allowed = NODE_MASK_NONE;
 	atomic_set(&cs->count, 0);
@@ -2565,6 +2588,15 @@ int cpuset_mem_spread_node(void)
 }
 EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
 
+/*
+ * Returns non-zero if 'oom_kill_asking_task' is set for this cpuset; otherwise
+ * returns zero.
+ */
+int oom_kill_asking_task(const struct task_struct *task)
+{
+	return is_oom_kill_asking_task(task->cpuset);
+}
+
 /**
  * cpuset_excl_nodes_overlap - Do we overlap @p's mem_exclusive ancestors?
  * @p: pointer to task_struct of some other task.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -496,6 +496,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 		break;
 
 	case CONSTRAINT_CPUSET:
+		/*
+		 * If the cpuset's "oom_kill_asking_task" flag is not set, the
+		 * OOM killer uses the same heuristics as a non-constrained
+		 * allocation attempt to kill a memory-hogging task.  The
+		 * badness score favors killing tasks that share exclusive
+		 * mems with current.
+		 */
+		if (!oom_kill_asking_task(current))
+			goto retry;
+
 		oom_kill_process(current, points,
 				"No available memory in cpuset");
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
