Message-ID: <46E743F8.9050206@google.com>
Date: Tue, 11 Sep 2007 18:42:16 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 6/6] cpuset dirty limits
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
In-Reply-To: <46E741B1.4030100@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Per cpuset dirty ratios

This implements dirty ratios per cpuset. Two new files are added
to the cpuset directories:

background_dirty_ratio	Percentage at which background writeback starts

throttle_dirty_ratio	Percentage at which the application is throttled
			and we start synchrononous writeout.

Both variables are set to -1 by default which means that the global
limits (/proc/sys/vm/vm_dirty_ratio and /proc/sys/vm/dirty_background_ratio)
are used for a cpuset.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Ethan Solomita <solo@google.com>

---

Patch against 2.6.23-rc4-mm1

diff -uprN -X 0/Documentation/dontdiff 5/include/linux/cpuset.h 7/include/linux/cpuset.h
--- 5/include/linux/cpuset.h	2007-09-11 14:50:48.000000000 -0700
+++ 7/include/linux/cpuset.h	2007-09-11 14:51:12.000000000 -0700
@@ -77,6 +77,7 @@ extern void cpuset_track_online_nodes(vo
 
 extern int current_cpuset_is_being_rebound(void);
 
+extern void cpuset_get_current_ratios(int *background, int *ratio);
 /*
  * We need macros since struct address_space is not defined yet
  */
diff -uprN -X 0/Documentation/dontdiff 5/kernel/cpuset.c 7/kernel/cpuset.c
--- 5/kernel/cpuset.c	2007-09-11 14:50:49.000000000 -0700
+++ 7/kernel/cpuset.c	2007-09-11 14:56:18.000000000 -0700
@@ -51,6 +51,7 @@
 #include <linux/time.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/writeback.h>
 
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
@@ -92,6 +93,9 @@ struct cpuset {
 	int mems_generation;
 
 	struct fmeter fmeter;		/* memory_pressure filter */
+
+	int background_dirty_ratio;
+	int throttle_dirty_ratio;
 };
 
 /* Retrieve the cpuset for a container */
@@ -169,6 +173,8 @@ static struct cpuset top_cpuset = {
 	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
 	.cpus_allowed = CPU_MASK_ALL,
 	.mems_allowed = NODE_MASK_ALL,
+	.background_dirty_ratio = -1,
+	.throttle_dirty_ratio = -1,
 };
 
 /*
@@ -785,6 +791,21 @@ static int update_flag(cpuset_flagbits_t
 	return 0;
 }
 
+static int update_int(int *cs_int, char *buf, int min, int max)
+{
+	char *endp;
+	int val;
+
+	val = simple_strtol(buf, &endp, 10);
+	if (val < min || val > max)
+		return -EINVAL;
+
+	mutex_lock(&callback_mutex);
+	*cs_int = val;
+	mutex_unlock(&callback_mutex);
+	return 0;
+}
+
 /*
  * Frequency meter - How fast is some event occurring?
  *
@@ -933,6 +954,8 @@ typedef enum {
 	FILE_MEMORY_PRESSURE,
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
+	FILE_THROTTLE_DIRTY_RATIO,
+	FILE_BACKGROUND_DIRTY_RATIO,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct container *cont,
@@ -997,6 +1020,12 @@ static ssize_t cpuset_common_file_write(
 		retval = update_flag(CS_SPREAD_SLAB, cs, buffer);
 		cs->mems_generation = cpuset_mems_generation++;
 		break;
+	case FILE_BACKGROUND_DIRTY_RATIO:
+		retval = update_int(&cs->background_dirty_ratio, buffer, -1, 100);
+		break;
+	case FILE_THROTTLE_DIRTY_RATIO:
+		retval = update_int(&cs->throttle_dirty_ratio, buffer, -1, 100);
+		break;
 	default:
 		retval = -EINVAL;
 		goto out2;
@@ -1090,6 +1119,12 @@ static ssize_t cpuset_common_file_read(s
 	case FILE_SPREAD_SLAB:
 		*s++ = is_spread_slab(cs) ? '1' : '0';
 		break;
+	case FILE_BACKGROUND_DIRTY_RATIO:
+		s += sprintf(s, "%d", cs->background_dirty_ratio);
+		break;
+	case FILE_THROTTLE_DIRTY_RATIO:
+		s += sprintf(s, "%d", cs->throttle_dirty_ratio);
+		break;
 	default:
 		retval = -EINVAL;
 		goto out;
@@ -1173,6 +1208,20 @@ static struct cftype cft_spread_slab = {
 	.private = FILE_SPREAD_SLAB,
 };
 
+static struct cftype cft_background_dirty_ratio = {
+	.name = "background_dirty_ratio",
+	.read = cpuset_common_file_read,
+	.write = cpuset_common_file_write,
+	.private = FILE_BACKGROUND_DIRTY_RATIO,
+};
+
+static struct cftype cft_throttle_dirty_ratio = {
+	.name = "throttle_dirty_ratio",
+	.read = cpuset_common_file_read,
+	.write = cpuset_common_file_write,
+	.private = FILE_THROTTLE_DIRTY_RATIO,
+};
+
 static int cpuset_populate(struct container_subsys *ss, struct container *cont)
 {
 	int err;
@@ -1193,6 +1242,10 @@ static int cpuset_populate(struct contai
 		return err;
 	if ((err = container_add_file(cont, ss, &cft_spread_slab)) < 0)
 		return err;
+	if ((err = container_add_file(cont, ss, &cft_background_dirty_ratio)) < 0)
+		return err;
+	if ((err = container_add_file(cont, ss, &cft_throttle_dirty_ratio)) < 0)
+		return err;
 	/* memory_pressure_enabled is in root cpuset only */
 	if (err == 0 && !cont->parent)
 		err = container_add_file(cont, ss,
@@ -1272,6 +1325,8 @@ static struct container_subsys_state *cp
 	cs->mems_allowed = NODE_MASK_NONE;
 	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
+	cs->background_dirty_ratio = parent->background_dirty_ratio;
+	cs->throttle_dirty_ratio = parent->throttle_dirty_ratio;
 
 	cs->parent = parent;
 	number_of_cpusets++;
@@ -1755,8 +1810,30 @@ int cpuset_mem_spread_node(void)
 }
 EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
 
-#if MAX_NUMNODES > BITS_PER_LONG
+/*
+ * Determine the dirty ratios for the currently active cpuset
+ */
+void cpuset_get_current_ratios(int *background_ratio, int *throttle_ratio)
+{
+	int background = -1;
+	int throttle = -1;
+	struct task_struct *tsk = current;
+
+	task_lock(tsk);
+	background = task_cs(tsk)->background_dirty_ratio;
+	throttle = task_cs(tsk)->throttle_dirty_ratio;
+	task_unlock(tsk);
 
+	if (background == -1)
+		background = dirty_background_ratio;
+	if (throttle == -1)
+		throttle = vm_dirty_ratio;
+
+	*background_ratio = background;
+	*throttle_ratio = throttle;
+}
+
+#if MAX_NUMNODES > BITS_PER_LONG
 /*
  * Special functions for NUMA systems with a large number of nodes.
  * The nodemask is pointed to from the address space structures.
diff -uprN -X 0/Documentation/dontdiff 5/mm/page-writeback.c 7/mm/page-writeback.c
--- 5/mm/page-writeback.c	2007-09-11 14:50:52.000000000 -0700
+++ 7/mm/page-writeback.c	2007-09-11 14:51:12.000000000 -0700
@@ -221,6 +221,7 @@ get_dirty_limits(struct dirty_limits *dl
 		/* Ensure that we return >= 0 */
 		if (available_memory <= 0)
 			available_memory = 1;
+		cpuset_get_current_ratios(&background_ratio, &dirty_ratio);
 	} else
 #endif
 	{
@@ -231,17 +232,17 @@ get_dirty_limits(struct dirty_limits *dl
 		available_memory = determine_dirtyable_memory();
 		nr_mapped = global_page_state(NR_FILE_MAPPED) +
 			global_page_state(NR_ANON_PAGES);
+		dirty_ratio = vm_dirty_ratio;
+		background_ratio = dirty_background_ratio;
 	}
 
 	unmapped_ratio = 100 - (nr_mapped * 100 / available_memory);
-	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
 		dirty_ratio = unmapped_ratio / 2;
 
 	if (dirty_ratio < 5)
 		dirty_ratio = 5;
 
-	background_ratio = dirty_background_ratio;
 	if (background_ratio >= dirty_ratio)
 		background_ratio = dirty_ratio / 2;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
