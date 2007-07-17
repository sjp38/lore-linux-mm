Message-ID: <469D369A.8000208@google.com>
Date: Tue, 17 Jul 2007 14:37:30 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 6/6] cpuset dirty limits
References: <469D3342.3080405@google.com>
In-Reply-To: <469D3342.3080405@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, Christoph Lameter <clameter@sgi.com>
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

Patch against 2.6.22-rc6-mm1

diff -uprN -X 0/Documentation/dontdiff 6/include/linux/cpuset.h 7/include/linux/cpuset.h
--- 6/include/linux/cpuset.h	2007-07-11 21:17:08.000000000 -0700
+++ 7/include/linux/cpuset.h	2007-07-11 21:17:41.000000000 -0700
@@ -76,6 +76,7 @@ extern void cpuset_track_online_nodes(vo
 
 extern int current_cpuset_is_being_rebound(void);
 
+extern void cpuset_get_current_ratios(int *background, int *ratio);
 /*
  * We need macros since struct address_space is not defined yet
  */
diff -uprN -X 0/Documentation/dontdiff 6/kernel/cpuset.c 7/kernel/cpuset.c
--- 6/kernel/cpuset.c	2007-07-12 12:15:20.000000000 -0700
+++ 7/kernel/cpuset.c	2007-07-12 12:15:34.000000000 -0700
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
 
 /* Update the cpuset for a container */
@@ -175,6 +179,8 @@ static struct cpuset top_cpuset = {
 	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
 	.cpus_allowed = CPU_MASK_ALL,
 	.mems_allowed = NODE_MASK_ALL,
+	.background_dirty_ratio = -1,
+	.throttle_dirty_ratio = -1,
 };
 
 /*
@@ -776,6 +782,21 @@ static int update_flag(cpuset_flagbits_t
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
@@ -924,6 +945,8 @@ typedef enum {
 	FILE_MEMORY_PRESSURE,
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
+	FILE_THROTTLE_DIRTY_RATIO,
+	FILE_BACKGROUND_DIRTY_RATIO,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct container *cont,
@@ -988,6 +1011,12 @@ static ssize_t cpuset_common_file_write(
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
@@ -1081,6 +1110,12 @@ static ssize_t cpuset_common_file_read(s
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
@@ -1164,6 +1199,20 @@ static struct cftype cft_spread_slab = {
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
 int cpuset_populate(struct container_subsys *ss, struct container *cont)
 {
 	int err;
@@ -1184,6 +1233,10 @@ int cpuset_populate(struct container_sub
 		return err;
 	if ((err = container_add_file(cont, &cft_spread_slab)) < 0)
 		return err;
+	if ((err = container_add_file(cont, &cft_background_dirty_ratio)) < 0)
+		return err;
+	if ((err = container_add_file(cont, &cft_throttle_dirty_ratio)) < 0)
+		return err;
 	/* memory_pressure_enabled is in root cpuset only */
 	if (err == 0 && !cont->parent)
 		err = container_add_file(cont, &cft_memory_pressure_enabled);
@@ -1262,6 +1315,8 @@ int cpuset_create(struct container_subsy
 	cs->mems_allowed = NODE_MASK_NONE;
 	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
+	cs->background_dirty_ratio = parent->background_dirty_ratio;
+	cs->throttle_dirty_ratio = parent->throttle_dirty_ratio;
 
 	cs->parent = parent;
 	set_container_cs(cont, cs);
@@ -1729,8 +1784,30 @@ int cpuset_mem_spread_node(void)
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
diff -uprN -X 0/Documentation/dontdiff 6/mm/page-writeback.c 7/mm/page-writeback.c
--- 6/mm/page-writeback.c	2007-07-16 18:32:20.000000000 -0700
+++ 7/mm/page-writeback.c	2007-07-17 13:17:31.000000000 -0700
@@ -219,6 +219,7 @@ get_dirty_limits(struct dirty_limits *dl
 		/* Ensure that we return >= 0 */
 		if (available_memory <= 0)
 			available_memory = 1;
+		cpuset_get_current_ratios(&background_ratio, &dirty_ratio);
 	} else
 #endif
 	{
@@ -229,17 +230,17 @@ get_dirty_limits(struct dirty_limits *dl
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
