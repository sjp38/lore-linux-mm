Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5E1EB8D001E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 12:14:36 -0400 (EDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH v2] Make transparent hugepages cpuset aware
Date: Tue, 11 Jun 2013 11:14:04 -0500
Message-Id: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

This patch adds the ability to control THPs on a per cpuset basis.  Please see
the additions to Documentation/cgroups/cpusets.txt for more information.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Reviewed-by: Robin Holt <holt@sgi.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-doc@vger.kernel.org
Cc: linux-mm@kvack.org
---
Changes since last patch version:
	- Modified transparent_hugepage_enable to always check the vma for the
	  VM_NOHUGEPAGE flag and to always check is_vma_temporary_stack.
	- Moved cpuset_update_child_thp_flags above cpuset_update_top_thp_flags

 Documentation/cgroups/cpusets.txt |  50 ++++++++++-
 include/linux/cpuset.h            |   5 ++
 include/linux/huge_mm.h           |  27 +++++-
 kernel/cpuset.c                   | 181 ++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                  |   3 +
 5 files changed, 263 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/cpusets.txt b/Documentation/cgroups/cpusets.txt
index 12e01d4..b7b2c83 100644
--- a/Documentation/cgroups/cpusets.txt
+++ b/Documentation/cgroups/cpusets.txt
@@ -22,12 +22,14 @@ CONTENTS:
   1.6 What is memory spread ?
   1.7 What is sched_load_balance ?
   1.8 What is sched_relax_domain_level ?
-  1.9 How do I use cpusets ?
+  1.9 What is thp_enabled ?
+  1.10 How do I use cpusets ?
 2. Usage Examples and Syntax
   2.1 Basic Usage
   2.2 Adding/removing cpus
   2.3 Setting flags
   2.4 Attaching processes
+  2.5 Setting thp_enabled flags
 3. Questions
 4. Contact
 
@@ -581,7 +583,34 @@ If your situation is:
 then increasing 'sched_relax_domain_level' would benefit you.
 
 
-1.9 How do I use cpusets ?
+1.9 What is thp_enabled ?
+-----------------------
+
+The thp_enabled file contained within each cpuset controls how transparent
+hugepages are handled within that cpuset.
+
+The root cpuset's thp_enabled flags mirror the flags set in
+/sys/kernel/mm/transparent_hugepage/enabled.  The flags in the root cpuset can
+only be modified by changing /sys/kernel/mm/transparent_hugepage/enabled. The
+thp_enabled file for the root cpuset is read only.  These flags cause the
+root cpuset to behave as one might expect:
+
+- When set to always, THPs are used whenever practical
+- When set to madvise, THPs are used only on chunks of memory that have the
+  MADV_HUGEPAGE flag set
+- When set to never, THPs are never allowed for tasks in this cpuset
+
+The behavior of thp_enabled for children of the root cpuset is where things
+become a bit more interesting.  The child cpusets accept the same flags as the
+root, but also have a default flag, which, when set, causes a cpuset to use the
+behavior of its parent.  When a child cpuset is created, its default flag is
+always initially set.
+
+Since the flags on child cpusets are allowed to differ from the flags on their
+parents, we are able to enable THPs for tasks in specific cpusets, and disable
+them in others.
+
+1.10 How do I use cpusets ?
 --------------------------
 
 In order to minimize the impact of cpusets on critical kernel
@@ -733,6 +762,7 @@ cpuset.cpus            cpuset.sched_load_balance
 cpuset.mem_exclusive   cpuset.sched_relax_domain_level
 cpuset.mem_hardwall    notify_on_release
 cpuset.memory_migrate  tasks
+thp_enabled
 
 Reading them will give you information about the state of this cpuset:
 the CPUs and Memory Nodes it can use, the processes that are using
@@ -814,6 +844,22 @@ If you have several tasks to attach, you have to do it one after another:
 	...
 # /bin/echo PIDn > tasks
 
+2.5 Setting thp_enabled flags
+-----------------------------
+
+The syntax for setting these flags is similar to setting thp flags in
+/sys/kernel/mm/transparent_hugepage/enabled.  In order to change the flags you
+simply echo the name of the flag you want to set to the thp_enabled file of the
+desired cpuset:
+
+# /bin/echo always > thp_enabled	-> always use THPs when practical
+# /bin/echo madvise > thp_enabled	-> only use THPs in madvise sections
+# /bin/echo never > thp_enabled		-> never use THPs
+# /bin/echo default > thp_enabled	-> use parent cpuset's THP flags
+
+Note that the flags on the root cpuset cannot be changed in /dev/cpuset.  These
+flags are mirrored from /sys/kernel/mm/transparent_hugepage/enabled and can only
+be modified there.
 
 3. Questions
 ============
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index cc1b01c..624aafd 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -19,9 +19,12 @@ extern int number_of_cpusets;	/* How many cpusets are defined in system? */
 
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
+extern void cpuset_update_top_thp_flags(void);
 extern void cpuset_update_active_cpus(bool cpu_online);
 extern void cpuset_cpus_allowed(struct task_struct *p, struct cpumask *mask);
 extern void cpuset_cpus_allowed_fallback(struct task_struct *p);
+extern int cpuset_thp_always(struct task_struct *p);
+extern int cpuset_thp_madvise(struct task_struct *p);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 #define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
@@ -122,6 +125,8 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
+static inline void cpuset_update_top_thp_flags(void) {}
+
 static inline void cpuset_update_active_cpus(bool cpu_online)
 {
 	partition_sched_domains(1, NULL, NULL);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 528454c..d6a8bb3 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -66,7 +66,7 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
-#define transparent_hugepage_enabled(__vma)				\
+#define _transparent_hugepage_enabled(__vma)				\
 	((transparent_hugepage_flags &					\
 	  (1<<TRANSPARENT_HUGEPAGE_FLAG) ||				\
 	  (transparent_hugepage_flags &					\
@@ -177,6 +177,31 @@ static inline struct page *compound_trans_head(struct page *page)
 	return page;
 }
 
+#ifdef CONFIG_CPUSETS
+extern int cpuset_thp_always(struct task_struct *p);
+extern int cpuset_thp_madvise(struct task_struct *p);
+
+static inline int transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	if (cpuset_thp_always(current) &&
+	    !((vma)->vm_flags & VM_NOHUGEPAGE) &&
+	    !is_vma_temporary_stack(vma))
+		return 1;
+	else if (cpuset_thp_madvise(current) &&
+		 ((vma)->vm_flags & VM_HUGEPAGE) &&
+		 !((vma)->vm_flags & VM_NOHUGEPAGE) &&
+		 !is_vma_temporary_stack(vma))
+		return 1;
+	else
+		return 0;
+}
+#else
+static inline int transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	return _transparent_hugepage_enabled(vma);
+}
+#endif
+
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 64b3f79..d596e50 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -150,6 +150,9 @@ typedef enum {
 	CS_SCHED_LOAD_BALANCE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_THP_MADVISE,
+	CS_THP_ALWAYS,
+	CS_THP_DEFAULT,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -193,6 +196,56 @@ static inline int is_spread_slab(const struct cpuset *cs)
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
+static inline int is_thp_always(const struct cpuset *cs)
+{
+	return test_bit(CS_THP_ALWAYS, &cs->flags);
+}
+
+static inline int is_thp_madvise(const struct cpuset *cs)
+{
+	return test_bit(CS_THP_MADVISE, &cs->flags);
+}
+
+static inline int is_thp_default(const struct cpuset *cs)
+{
+	return test_bit(CS_THP_DEFAULT, &cs->flags);
+}
+
+/* convenient sets for thp flags */
+static inline void set_thp_always(struct cpuset *cs)
+{
+	set_bit(CS_THP_ALWAYS, &cs->flags);
+	clear_bit(CS_THP_MADVISE, &cs->flags);
+}
+
+static inline void set_thp_madvise(struct cpuset *cs)
+{
+	set_bit(CS_THP_MADVISE, &cs->flags);
+	clear_bit(CS_THP_ALWAYS, &cs->flags);
+}
+
+static inline void set_thp_never(struct cpuset *cs)
+{
+	clear_bit(CS_THP_ALWAYS, &cs->flags);
+	clear_bit(CS_THP_MADVISE, &cs->flags);
+}
+
+static inline void copy_thp_flags(struct cpuset *source_cs,
+				  struct cpuset *dest_cs)
+{
+	/*
+	 * The CS_THP_DEFAULT flag isn't copied here because it is
+	 * set by default when a new cpuset is created, and after
+	 * that point, should only be changed by the user.
+	 */
+	if (is_thp_always(source_cs))
+		set_thp_always(dest_cs);
+	else if (is_thp_madvise(source_cs))
+		set_thp_madvise(dest_cs);
+	else
+		set_thp_never(dest_cs);
+}
+
 static struct cpuset top_cpuset = {
 	.flags = ((1 << CS_ONLINE) | (1 << CS_CPU_EXCLUSIVE) |
 		  (1 << CS_MEM_EXCLUSIVE)),
@@ -1496,6 +1549,7 @@ typedef enum {
 	FILE_MEMORY_PRESSURE,
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
+	FILE_THP_ENABLED,
 } cpuset_filetype_t;
 
 static int cpuset_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
@@ -1624,6 +1678,71 @@ out_unlock:
 	return retval;
 }
 
+static void cpuset_update_child_thp_flags(struct cpuset *parent_cs)
+{
+	struct cpuset *child_cs;
+	struct cgroup *pos_cg;
+
+	rcu_read_lock();
+	cpuset_for_each_child(child_cs, pos_cg, parent_cs) {
+		if (test_bit(CS_THP_DEFAULT, &child_cs->flags)) {
+			copy_thp_flags(parent_cs, child_cs);
+			cpuset_update_child_thp_flags(child_cs);
+		}
+	}
+	rcu_read_unlock();
+}
+
+void cpuset_update_top_thp_flags(void)
+{
+	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
+		set_thp_always(&top_cpuset);
+	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
+		   &transparent_hugepage_flags)) {
+		set_thp_madvise(&top_cpuset);
+	} else {
+		set_thp_never(&top_cpuset);
+	}
+
+	cpuset_update_child_thp_flags(&top_cpuset);
+}
+
+static int cpuset_thp_enabled_write(struct cgroup *cgrp, struct cftype *cft,
+					const char *buf)
+{
+	struct cpuset *cs = cgroup_cs(cgrp);
+	int retval = strlen(buf) + 1;
+
+	if (cs == &top_cpuset) {
+		retval = -EPERM;
+		goto out;
+	}
+
+	if (cft->private == FILE_THP_ENABLED) {
+		if (!memcmp("always", buf, sizeof("always")-1)) {
+			clear_bit(CS_THP_DEFAULT, &cs->flags);
+			set_thp_always(cs);
+		} else if (!memcmp("madvise", buf, sizeof("madvise")-1)) {
+			clear_bit(CS_THP_DEFAULT, &cs->flags);
+			set_thp_madvise(cs);
+		} else if (!memcmp("never", buf, sizeof("never")-1)) {
+			clear_bit(CS_THP_DEFAULT, &cs->flags);
+			set_thp_never(cs);
+		} else if (!memcmp("default", buf, sizeof("default")-1)) {
+			set_bit(CS_THP_DEFAULT, &cs->flags);
+			copy_thp_flags(parent_cs(cs), cs);
+		} else {
+			retval = -EINVAL;
+			goto out;
+		}
+	}
+
+	cpuset_update_child_thp_flags(cs);
+
+out:
+	return retval;
+}
+
 /*
  * These ascii lists should be read in a single call, by using a user
  * buffer large enough to hold the entire map.  If read in smaller
@@ -1658,6 +1777,39 @@ static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
 	return count;
 }
 
+static size_t cpuset_sprintf_thp(char *buf, struct cpuset *cs)
+{
+	if (test_bit(CS_THP_ALWAYS, &cs->flags)) {
+		VM_BUG_ON(test_bit(CS_THP_MADVISE, &cs->flags));
+		return sprintf(buf, "[always] madvise never %s",
+			       test_bit(CS_THP_DEFAULT, &cs->flags) ?
+			       "(default from parent)" :
+			       "(overrides parent)");
+	} else if (test_bit(CS_THP_MADVISE, &cs->flags)) {
+		VM_BUG_ON(test_bit(CS_THP_ALWAYS, &cs->flags));
+		return sprintf(buf, "always [madvise] never %s",
+			       test_bit(CS_THP_DEFAULT, &cs->flags) ?
+			       "(default from parent)" :
+			       "(overrides parent)");
+	} else
+		return sprintf(buf, "always madvise [never] %s",
+			       test_bit(CS_THP_DEFAULT, &cs->flags) ?
+			       "(default from parent)" :
+			       "(overrides parent)");
+}
+
+static size_t cpuset_sprintf_thp_top(char *buf, struct cpuset *cs)
+{
+	if (test_bit(CS_THP_ALWAYS, &cs->flags)) {
+		VM_BUG_ON(test_bit(CS_THP_MADVISE, &cs->flags));
+		return sprintf(buf, "[always] madvise never");
+	} else if (test_bit(CS_THP_MADVISE, &cs->flags)) {
+		VM_BUG_ON(test_bit(CS_THP_ALWAYS, &cs->flags));
+		return sprintf(buf, "always [madvise] never");
+	} else
+		return sprintf(buf, "always madvise [never]");
+}
+
 static ssize_t cpuset_common_file_read(struct cgroup *cont,
 				       struct cftype *cft,
 				       struct file *file,
@@ -1682,6 +1834,12 @@ static ssize_t cpuset_common_file_read(struct cgroup *cont,
 	case FILE_MEMLIST:
 		s += cpuset_sprintf_memlist(s, cs);
 		break;
+	case FILE_THP_ENABLED:
+		if (&top_cpuset == cs)
+			s += cpuset_sprintf_thp_top(s, cs);
+		else
+			s += cpuset_sprintf_thp(s, cs);
+		break;
 	default:
 		retval = -EINVAL;
 		goto out;
@@ -1834,6 +1992,13 @@ static struct cftype files[] = {
 		.private = FILE_MEMORY_PRESSURE_ENABLED,
 	},
 
+	{
+		.name = "thp_enabled",
+		.read = cpuset_common_file_read,
+		.write_string = cpuset_thp_enabled_write,
+		.private = FILE_THP_ENABLED,
+	},
+
 	{ }	/* terminate */
 };
 
@@ -1880,11 +2045,14 @@ static int cpuset_css_online(struct cgroup *cgrp)
 	mutex_lock(&cpuset_mutex);
 
 	set_bit(CS_ONLINE, &cs->flags);
+	set_bit(CS_THP_DEFAULT, &cs->flags);
 	if (is_spread_page(parent))
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
 
+	copy_thp_flags(parent, cs);
+
 	number_of_cpusets++;
 
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags))
@@ -1982,6 +2150,9 @@ int __init cpuset_init(void)
 
 	fmeter_init(&top_cpuset.fmeter);
 	set_bit(CS_SCHED_LOAD_BALANCE, &top_cpuset.flags);
+
+	cpuset_update_top_thp_flags();
+
 	top_cpuset.relax_domain_level = -1;
 
 	err = register_filesystem(&cpuset_fs_type);
@@ -2276,6 +2447,16 @@ void cpuset_cpus_allowed_fallback(struct task_struct *tsk)
 	 */
 }
 
+int cpuset_thp_always(struct task_struct *p)
+{
+	return is_thp_always(task_cs(p));
+}
+
+int cpuset_thp_madvise(struct task_struct *p)
+{
+	return is_thp_madvise(task_cs(p));
+}
+
 void cpuset_init_current_mems_allowed(void)
 {
 	nodes_setall(current->mems_allowed);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 03a89a2..d48f0b5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -21,6 +21,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/cpuset.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -268,6 +269,8 @@ static ssize_t double_flag_store(struct kobject *kobj,
 	} else
 		return -EINVAL;
 
+	cpuset_update_top_thp_flags();
+
 	return count;
 }
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
