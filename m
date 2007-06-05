Date: Tue, 5 Jun 2007 13:15:00 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] numa: mempolicy: Allow tunable policy for system init.
Message-ID: <20070605041500.GB2480@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The current default behaviour for system init (via numa_policy_init())
is to use MPOL_INTERLEAVE across the online nodes in order to avoid a
preference for node 0. This tends to be undesirable for small nodes that
really would rather prefer to keep as many allocations on node 0 as
possible.

As tmpfs already provides a parser for the policy and nodelist --
shmem_parse_mpol(), we generalize this and wrap in to it via an mpolinit=
(for lack of a better name) setup param. Other code that wishes to do
mempolicy parsing for itself can use the new mpol_parse_options().

As an example, for small nodes, one might prefer to boot with
'mpolinit=prefer:0'. numa_default_policy() will still overload this
with MPOL_DEFAULT later on anyways, so this is only useful for system
init.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 Documentation/kernel-parameters.txt |    6 ++
 include/linux/mempolicy.h           |    8 +++
 mm/mempolicy.c                      |   81 +++++++++++++++++++++++++++++++++---
 mm/shmem.c                          |   52 -----------------------
 4 files changed, 91 insertions(+), 56 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index ce91560..1b77073 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1070,6 +1070,12 @@ and is between 256 and 4096 characters. It is defined in the file
 	mousedev.yres=	[MOUSE] Vertical screen resolution, used for devices
 			reporting absolute coordinates, such as tablets
 
+	mpolinit=	[KNL,NUMA]
+			Format: <policy>,[:<nodelist>]
+			Sets the default memory policy to be used at system
+			init time. Defaults to MPOL_INTERLEAVE between online
+			nodes.
+
 	mpu401=		[HW,OSS]
 			Format: <io>,<irq>
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index daabb3a..471fd25 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -148,6 +148,8 @@ extern void mpol_rebind_task(struct task_struct *tsk,
 					const nodemask_t *new);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 extern void mpol_fix_fork_child_flag(struct task_struct *p);
+extern int mpol_parse_options(char *value, int *policy,
+			      nodemask_t *policy_nodes);
 #define set_cpuset_being_rebound(x) (cpuset_being_rebound = (x))
 
 #ifdef CONFIG_CPUSETS
@@ -253,6 +255,12 @@ static inline void mpol_fix_fork_child_flag(struct task_struct *p)
 {
 }
 
+static inline int mpol_parse_options(char *value, int *policy,
+				     nodemask_t *policy_nodes)
+{
+	return 1;
+}
+
 #define set_cpuset_being_rebound(x) do {} while (0)
 
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d76e8eb..f5c5e04 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -89,7 +89,7 @@
 #include <linux/migrate.h>
 #include <linux/rmap.h>
 #include <linux/security.h>
-
+#include <linux/ctype.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
@@ -1594,9 +1594,72 @@ void mpol_free_shared_policy(struct shared_policy *p)
 	spin_unlock(&p->lock);
 }
 
+int mpol_parse_options(char *value, int *policy, nodemask_t *policy_nodes)
+{
+	char *nodelist = strchr(value, ':');
+	int err = 1;
+
+	if (nodelist) {
+		/* NUL-terminate policy string */
+		*nodelist++ = '\0';
+		if (nodelist_parse(nodelist, *policy_nodes))
+			goto out;
+	}
+	if (!strcmp(value, "default")) {
+		*policy = MPOL_DEFAULT;
+		/* Don't allow a nodelist */
+		if (!nodelist)
+			err = 0;
+	} else if (!strcmp(value, "prefer")) {
+		*policy = MPOL_PREFERRED;
+		/* Insist on a nodelist of one node only */
+		if (nodelist) {
+			char *rest = nodelist;
+			while (isdigit(*rest))
+				rest++;
+			if (!*rest)
+				err = 0;
+		}
+	} else if (!strcmp(value, "bind")) {
+		*policy = MPOL_BIND;
+		/* Insist on a nodelist */
+		if (nodelist)
+			err = 0;
+	} else if (!strcmp(value, "interleave")) {
+		*policy = MPOL_INTERLEAVE;
+		/* Default to nodes online if no nodelist */
+		if (!nodelist)
+			*policy_nodes = node_online_map;
+		err = 0;
+	}
+out:
+	/* Restore string for error message */
+	if (nodelist)
+		*--nodelist = ':';
+	return err;
+}
+
+/* Set interleaving policy for system init. This way not all
+   the data structures allocated at system boot end up in node zero. */
+static nodemask_t nmask_sysinit __initdata;
+static int policy_sysinit __initdata = MPOL_INTERLEAVE;
+
+static int __init setup_mpol_sysinit(char *str)
+{
+	if (mpol_parse_options(str, &policy_sysinit, &nmask_sysinit)) {
+		printk("mpolinit failed, falling back on interleave\n");
+		return 0;
+	}
+
+	return 1;
+}
+__setup("mpolinit=", setup_mpol_sysinit);
+
 /* assumes fs == KERNEL_DS */
 void __init numa_policy_init(void)
 {
+	nodemask_t *nmask;
+
 	policy_cache = kmem_cache_create("numa_policy",
 					 sizeof(struct mempolicy),
 					 0, SLAB_PANIC, NULL, NULL);
@@ -1605,11 +1668,19 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL, NULL);
 
-	/* Set interleaving policy for system init. This way not all
-	   the data structures allocated at system boot end up in node zero. */
+	/*
+	 * Use the specified nodemask for init, or fall back to
+	 * node_online_map.
+	 */
+	if (policy_sysinit == MPOL_DEFAULT)
+		nmask = NULL;
+	else if (!nodes_empty(nmask_sysinit))
+		nmask = &nmask_sysinit;
+	else
+		nmask = &node_online_map;
 
-	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
-		printk("numa_policy_init: interleaving failed\n");
+	if (do_set_mempolicy(policy_sysinit, nmask))
+		printk("numa_policy_init: setting init policy failed\n");
 }
 
 /* Reset policy of current process to default */
diff --git a/mm/shmem.c b/mm/shmem.c
index e537317..ca3f59d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -957,51 +957,6 @@ redirty:
 }
 
 #ifdef CONFIG_NUMA
-static inline int shmem_parse_mpol(char *value, int *policy, nodemask_t *policy_nodes)
-{
-	char *nodelist = strchr(value, ':');
-	int err = 1;
-
-	if (nodelist) {
-		/* NUL-terminate policy string */
-		*nodelist++ = '\0';
-		if (nodelist_parse(nodelist, *policy_nodes))
-			goto out;
-	}
-	if (!strcmp(value, "default")) {
-		*policy = MPOL_DEFAULT;
-		/* Don't allow a nodelist */
-		if (!nodelist)
-			err = 0;
-	} else if (!strcmp(value, "prefer")) {
-		*policy = MPOL_PREFERRED;
-		/* Insist on a nodelist of one node only */
-		if (nodelist) {
-			char *rest = nodelist;
-			while (isdigit(*rest))
-				rest++;
-			if (!*rest)
-				err = 0;
-		}
-	} else if (!strcmp(value, "bind")) {
-		*policy = MPOL_BIND;
-		/* Insist on a nodelist */
-		if (nodelist)
-			err = 0;
-	} else if (!strcmp(value, "interleave")) {
-		*policy = MPOL_INTERLEAVE;
-		/* Default to nodes online if no nodelist */
-		if (!nodelist)
-			*policy_nodes = node_online_map;
-		err = 0;
-	}
-out:
-	/* Restore string for error message */
-	if (nodelist)
-		*--nodelist = ':';
-	return err;
-}
-
 static struct page *shmem_swapin_async(struct shared_policy *p,
 				       swp_entry_t entry, unsigned long idx)
 {
@@ -1054,11 +1009,6 @@ shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
 	return page;
 }
 #else
-static inline int shmem_parse_mpol(char *value, int *policy, nodemask_t *policy_nodes)
-{
-	return 1;
-}
-
 static inline struct page *
 shmem_swapin(struct shmem_inode_info *info,swp_entry_t entry,unsigned long idx)
 {
@@ -2184,7 +2134,7 @@ static int shmem_parse_options(char *options, int *mode, uid_t *uid,
 			if (*rest)
 				goto bad_val;
 		} else if (!strcmp(this_char,"mpol")) {
-			if (shmem_parse_mpol(value,policy,policy_nodes))
+			if (mpol_parse_options(value,policy,policy_nodes))
 				goto bad_val;
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
