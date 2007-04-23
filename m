Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l3NNY77A031240
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:34:07 -0700
Received: from smtp.corp.google.com (spacemonkey3.corp.google.com [192.168.120.116])
	by zps78.corp.google.com with ESMTP id l3NNXsCr025644
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:33:54 -0700
Received: from [10.253.168.165] (m682a36d0.tmodns.net [208.54.42.104])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id l3NNXqtO020610
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 16:33:53 -0700
Message-ID: <462D425E.2000004@google.com>
Date: Mon, 23 Apr 2007 16:33:50 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 7/7] cpuset dirty limits
References: <462D3F4C.2040007@google.com>
In-Reply-To: <462D3F4C.2040007@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
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

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 6/include/linux/cpuset.h 7/include/linux/cpuset.h
--- 6/include/linux/cpuset.h	2007-04-23 14:38:07.000000000 -0700
+++ 7/include/linux/cpuset.h	2007-04-23 14:38:39.000000000 -0700
@@ -75,6 +75,7 @@ static inline int cpuset_do_slab_mem_spr
 
 extern void cpuset_track_online_nodes(void);
 
+extern void cpuset_get_current_ratios(int *background, int *ratio);
 /*
  * We need macros since struct address_space is not defined yet
  */
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 6/kernel/cpuset.c 7/kernel/cpuset.c
--- 6/kernel/cpuset.c	2007-04-23 14:38:08.000000000 -0700
+++ 7/kernel/cpuset.c	2007-04-23 14:38:39.000000000 -0700
@@ -50,6 +50,7 @@
 #include <linux/time.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/writeback.h>
 
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
@@ -100,6 +101,9 @@ struct cpuset {
 	int mems_generation;
 
 	struct fmeter fmeter;		/* memory_pressure filter */
+
+	int background_dirty_ratio;
+	int throttle_dirty_ratio;
 };
 
 /* bits in struct cpuset flags field */
@@ -177,6 +181,8 @@ static struct cpuset top_cpuset = {
 	.count = ATOMIC_INIT(0),
 	.sibling = LIST_HEAD_INIT(top_cpuset.sibling),
 	.children = LIST_HEAD_INIT(top_cpuset.children),
+	.background_dirty_ratio = -1,
+	.throttle_dirty_ratio = -1,
 };
 
 static struct vfsmount *cpuset_mount;
@@ -1009,6 +1015,21 @@ static int update_flag(cpuset_flagbits_t
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
@@ -1217,6 +1238,8 @@ typedef enum {
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
 	FILE_TASKLIST,
+	FILE_THROTTLE_DIRTY_RATIO,
+	FILE_BACKGROUND_DIRTY_RATIO,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct file *file,
@@ -1287,6 +1310,12 @@ static ssize_t cpuset_common_file_write(
 	case FILE_TASKLIST:
 		retval = attach_task(cs, buffer, &pathbuf);
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
@@ -1399,6 +1428,12 @@ static ssize_t cpuset_common_file_read(s
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
@@ -1772,6 +1807,16 @@ static struct cftype cft_spread_slab = {
 	.private = FILE_SPREAD_SLAB,
 };
 
+static struct cftype cft_background_dirty_ratio = {
+	.name = "background_dirty_ratio",
+	.private = FILE_BACKGROUND_DIRTY_RATIO,
+};
+
+static struct cftype cft_throttle_dirty_ratio = {
+	.name = "throttle_dirty_ratio",
+	.private = FILE_THROTTLE_DIRTY_RATIO,
+};
+
 static int cpuset_populate_dir(struct dentry *cs_dentry)
 {
 	int err;
@@ -1794,6 +1839,10 @@ static int cpuset_populate_dir(struct de
 		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_spread_slab)) < 0)
 		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_background_dirty_ratio)) < 0)
+		return err;
+	if ((err = cpuset_add_file(cs_dentry, &cft_throttle_dirty_ratio)) < 0)
+		return err;
 	if ((err = cpuset_add_file(cs_dentry, &cft_tasks)) < 0)
 		return err;
 	return 0;
@@ -1833,6 +1882,8 @@ static long cpuset_create(struct cpuset 
 	INIT_LIST_HEAD(&cs->children);
 	cs->mems_generation = cpuset_mems_generation++;
 	fmeter_init(&cs->fmeter);
+	cs->background_dirty_ratio = parent->background_dirty_ratio;
+	cs->throttle_dirty_ratio = parent->throttle_dirty_ratio;
 
 	cs->parent = parent;
 
@@ -2451,8 +2502,30 @@ int cpuset_mem_spread_node(void)
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
+	background = tsk->cpuset->background_dirty_ratio;
+	throttle = tsk->cpuset->throttle_dirty_ratio;
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
diff -uprN -X linux-2.6.21-rc4-mm1/Documentation/dontdiff 6/mm/page-writeback.c 7/mm/page-writeback.c
--- 6/mm/page-writeback.c	2007-04-23 15:14:25.000000000 -0700
+++ 7/mm/page-writeback.c	2007-04-23 15:16:54.000000000 -0700
@@ -216,6 +216,7 @@ get_dirty_limits(struct dirty_limits *dl
 		}
 		dirtyable_memory -= highmem_dirtyable_memory(nodes,
 							     dirtyable_memory);
+		cpuset_get_current_ratios(&background_ratio, &dirty_ratio);
 	} else
 #endif
 	{
@@ -226,19 +227,19 @@ get_dirty_limits(struct dirty_limits *dl
 		dirtyable_memory = determine_dirtyable_memory();
 		nr_mapped = global_page_state(NR_FILE_MAPPED) +
 			global_page_state(NR_ANON_PAGES);
+		dirty_ratio = vm_dirty_ratio;
+		background_ratio = dirty_background_ratio;
 	}
 
 	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES)) * 100) /
 					vm_total_pages;
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
