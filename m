From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:53:35 -0400
Message-Id: <20070625195335.21210.82618.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 10/11] Shared Policy: per cpuset shared file policy control
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Mapped File Policy 10/11 per cpuset shared file policy control

Against 2.6.22-rc4-mm2

Add a per cpuset "shared_file_policy" control file to enable 
shared file policy for tasks in the cpuset.  Default is disabled,
resulting in the old behavior--i.e., we continue to ignore
mbind() on address ranges backed by shared file mappings.
The "shared_file_policy" file depends on CONFIG_NUMA.

Subsequent patch that "hooks up" generic file .{set|get}_policy
vm_ops will only install a shared policy on a memory mapped file
if the capability has been enabled for the caller's cpuset.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
 
 include/linux/sched.h |    1 +
 kernel/cpuset.c       |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

Index: Linux/include/linux/sched.h
===================================================================
--- Linux.orig/include/linux/sched.h	2007-06-22 14:33:03.000000000 -0400
+++ Linux/include/linux/sched.h	2007-06-22 14:34:28.000000000 -0400
@@ -1119,6 +1119,7 @@ struct task_struct {
 #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
 	short il_next;
+	short shared_file_policy_enabled;
 #endif
 #ifdef CONFIG_CPUSETS
 	nodemask_t mems_allowed;
Index: Linux/kernel/cpuset.c
===================================================================
--- Linux.orig/kernel/cpuset.c	2007-06-22 14:33:03.000000000 -0400
+++ Linux/kernel/cpuset.c	2007-06-22 14:34:28.000000000 -0400
@@ -121,6 +121,7 @@ typedef enum {
 	CS_MEMORY_MIGRATE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_SHARED_FILE_POLICY,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -149,6 +150,13 @@ static inline int is_spread_slab(const s
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
+#ifdef CONFIG_NUMA
+static inline int is_shared_file_policy(const struct cpuset *cs)
+{
+	return test_bit(CS_SHARED_FILE_POLICY, &cs->flags);
+}
+#endif
+
 /*
  * Increment this integer everytime any cpuset changes its
  * mems_allowed value.  Users of cpusets can track this generation
@@ -409,6 +417,12 @@ void cpuset_update_task_memory_state(voi
 			tsk->flags |= PF_SPREAD_SLAB;
 		else
 			tsk->flags &= ~PF_SPREAD_SLAB;
+#ifdef CONFIG_NUMA
+		if (is_shared_file_policy(cs))
+			tsk->shared_file_policy_enabled = 1;
+		else
+			tsk->shared_file_policy_enabled = 0;
+#endif
 		task_unlock(tsk);
 		mutex_unlock(&callback_mutex);
 		mpol_rebind_task(tsk, &tsk->mems_allowed);
@@ -923,6 +937,7 @@ typedef enum {
 	FILE_MEMORY_PRESSURE,
 	FILE_SPREAD_PAGE,
 	FILE_SPREAD_SLAB,
+	FILE_SHARED_FILE_POLICY,
 } cpuset_filetype_t;
 
 static ssize_t cpuset_common_file_write(struct container *cont,
@@ -987,6 +1002,12 @@ static ssize_t cpuset_common_file_write(
 		retval = update_flag(CS_SPREAD_SLAB, cs, buffer);
 		cs->mems_generation = cpuset_mems_generation++;
 		break;
+#ifdef CONFIG_NUMA
+	case FILE_SHARED_FILE_POLICY:
+		retval = update_flag(CS_SHARED_FILE_POLICY, cs, buffer);
+		cs->mems_generation = cpuset_mems_generation++;
+		break;
+#endif
 	default:
 		retval = -EINVAL;
 		goto out2;
@@ -1080,6 +1101,11 @@ static ssize_t cpuset_common_file_read(s
 	case FILE_SPREAD_SLAB:
 		*s++ = is_spread_slab(cs) ? '1' : '0';
 		break;
+#ifdef CONFIG_NUMA
+	case FILE_SHARED_FILE_POLICY:
+		*s++ = is_shared_file_policy(cs) ? '1' : '0';
+		break;
+#endif
 	default:
 		retval = -EINVAL;
 		goto out;
@@ -1163,6 +1189,14 @@ static struct cftype cft_spread_slab = {
 	.private = FILE_SPREAD_SLAB,
 };
 
+#ifdef CONFIG_NUMA
+static struct cftype cft_shared_file_policy = {
+	.name = "shared_file_policy",
+	.read = cpuset_common_file_read,
+	.write = cpuset_common_file_write,
+	.private = FILE_SHARED_FILE_POLICY,
+};
+#endif
 int cpuset_populate(struct container_subsys *ss, struct container *cont)
 {
 	int err;
@@ -1183,6 +1217,10 @@ int cpuset_populate(struct container_sub
 		return err;
 	if ((err = container_add_file(cont, &cft_spread_slab)) < 0)
 		return err;
+#ifdef CONFIG_NUMA
+	if ((err = container_add_file(cont, &cft_shared_file_policy)) < 0)
+		return err;
+#endif
 	/* memory_pressure_enabled is in root cpuset only */
 	if (err == 0 && !cont->parent)
 		err = container_add_file(cont, &cft_memory_pressure_enabled);
@@ -1221,6 +1259,10 @@ int cpuset_create(struct container_subsy
 		set_bit(CS_SPREAD_PAGE, &cs->flags);
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
+#ifdef CONFIG_NUMA
+	if (is_shared_file_policy(parent))
+		set_bit(CS_SHARED_FILE_POLICY, &cs->flags);
+#endif
 	cs->cpus_allowed = CPU_MASK_NONE;
 	cs->mems_allowed = NODE_MASK_NONE;
 	cs->mems_generation = cpuset_mems_generation++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
