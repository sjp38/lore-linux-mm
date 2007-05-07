Message-ID: <463F764E.5050009@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: [RFC][PATCH] VM: per-user overcommit policy
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Date: Mon,  7 May 2007 20:56:39 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allow to define per-UID virtual memory overcommit handling. Configuration is
stored in a hash list in kernel space reachable through /proc/overcommit_uid
(surely there're better ways to do it, i.e. via configfs).

Hash elements are defined using a triple:

uid:overcommit_memory:overcommit_ratio

The overcommit_* values have the same semantic of their respective sysctl
variables.

If a user is not present in the hash, the default system policy will be used
(defined by /proc/sys/vm/overcommit_memory and /proc/sys/vm/overcommit_ratio).

Example:

- Enable "always overcommit" policy for admin:
root@host # echo 0:1:0 > /proc/overcommit_uid

- processes belonging to sshd (uid=100) and ntp (uid=102) users can be quite
  critical, so use a classic heuristic overcommit:
root@host # echo 100:0:50 > /proc/overcommit_uid
root@host # echo 102:0:50 > /proc/overcommit_uid

- allow uid=1001 and uid=1002 (common users) to allocate memory only if the
  total committed space is below the 50% of the physical RAM + the size of
  swap:
root@host # echo 1001:2:50 > /proc/overcommit_uid
root@host # echo 1002:2:50 > /proc/overcommit_uid

- Deny VM allocation to others:
root@host # echo 2 > /proc/sys/vm/overcommit_memory && echo 0 > /proc/sys/vm/overcommit_ratio

TODO:
- GID overcommit policy,
- per-user/group VM accounting,
- VM quotas,
- a lot of improvements,
- more testing...

Signed-off-by: Andrea Righi <a.righi@cineca.it>
---

diff -urpN linux-2.6.21/include/linux/mman.h linux-2.6.21-vm-acct-user/include/linux/mman.h
--- linux-2.6.21/include/linux/mman.h	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/include/linux/mman.h	2007-05-07 20:20:42.000000000 +0200
@@ -18,6 +18,14 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern atomic_t vm_committed_space;
+#ifdef CONFIG_VM_ACCT_USER
+struct vm_acct_values
+{
+	int overcommit_memory;
+	int overcommit_ratio;
+};
+extern int vm_acct_get_config(struct vm_acct_values *v, uid_t uid);
+#endif
 
 #ifdef CONFIG_SMP
 extern void vm_acct_memory(long pages);
diff -urpN linux-2.6.21/ipc/shm.c linux-2.6.21-vm-acct-user/ipc/shm.c
--- linux-2.6.21/ipc/shm.c	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/ipc/shm.c	2007-05-07 20:20:42.000000000 +0200
@@ -370,12 +370,24 @@ static int newseg (struct ipc_namespace 
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;
+#ifdef CONFIG_VM_ACCT_USER
+		int overcommit_memory;
+		struct vm_acct_values v;
+	
+		if (!vm_acct_get_config(&v, current->uid)) {
+			overcommit_memory = v.overcommit_memory;
+		} else {
+			overcommit_memory = sysctl_overcommit_memory;
+		}
+#else 
+#define overcommit_memory sysctl_overcommit_memory
+#endif
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
 	 	 * if it's asked for.
 		 */
 		if  ((shmflg & SHM_NORESERVE) &&
-				sysctl_overcommit_memory != OVERCOMMIT_NEVER)
+				overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = 0;
 		sprintf (name, "SYSV%08x", key);
 		file = shmem_file_setup(name, size, acctflag);
diff -urpN linux-2.6.21/mm/Kconfig linux-2.6.21-vm-acct-user/mm/Kconfig
--- linux-2.6.21/mm/Kconfig	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/Kconfig	2007-05-07 20:21:21.000000000 +0200
@@ -163,3 +163,11 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config VM_ACCT_USER
+	bool "Per-user VM overcommit policy (EXPERIMENTAL)" 
+	depends on PROC_FS && EXPERIMENTAL
+	def_bool n
+	help
+	  Say Y here to enable per-user virtual memory overcommit handling.
+	  Overcommit configuration will be available via /proc/overcommit_uid.
+
diff -urpN linux-2.6.21/mm/mmap.c linux-2.6.21-vm-acct-user/mm/mmap.c
--- linux-2.6.21/mm/mmap.c	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/mmap.c	2007-05-07 20:20:42.000000000 +0200
@@ -95,16 +95,30 @@ atomic_t vm_committed_space = ATOMIC_INI
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
-
+#ifdef CONFIG_VM_ACCT_USER
+	int overcommit_memory, overcommit_ratio;
+	struct vm_acct_values v;
+	
+	if (!vm_acct_get_config(&v, current->uid)) {
+		overcommit_memory = v.overcommit_memory;
+		overcommit_ratio = v.overcommit_ratio;
+	} else {
+		overcommit_memory = sysctl_overcommit_memory;
+		overcommit_ratio = sysctl_overcommit_ratio;
+	}
+#else 
+#define overcommit_memory sysctl_overcommit_memory
+#define overcommit_ratio sysctl_overcommit_ratio
+#endif
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+	if (overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -155,7 +169,7 @@ int __vm_enough_memory(long pages, int c
 	}
 
 	allowed = (totalram_pages - hugetlb_total_pages())
-	       	* sysctl_overcommit_ratio / 100;
+	       	* overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */
@@ -901,6 +915,10 @@ unsigned long do_mmap_pgoff(struct file 
 	struct rb_node ** rb_link, * rb_parent;
 	int accountable = 1;
 	unsigned long charged = 0, reqprot = prot;
+#ifdef CONFIG_VM_ACCT_USER
+	int overcommit_memory;
+	struct vm_acct_values v;
+#endif
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1040,8 +1058,15 @@ munmap_back:
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
+#ifdef CONFIG_VM_ACCT_USER
+	if (!vm_acct_get_config(&v, current->uid)) {
+		overcommit_memory = v.overcommit_memory;
+	} else {
+		overcommit_memory = sysctl_overcommit_memory;
+	}
+#endif
 	if (accountable && (!(flags & MAP_NORESERVE) ||
-			    sysctl_overcommit_memory == OVERCOMMIT_NEVER)) {
+			    overcommit_memory == OVERCOMMIT_NEVER)) {
 		if (vm_flags & VM_SHARED) {
 			/* Check memory availability in shmem_file_setup? */
 			vm_flags |= VM_ACCOUNT;
diff -urpN linux-2.6.21/mm/nommu.c linux-2.6.21-vm-acct-user/mm/nommu.c
--- linux-2.6.21/mm/nommu.c	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/nommu.c	2007-05-07 20:20:42.000000000 +0200
@@ -1240,16 +1240,31 @@ EXPORT_SYMBOL(get_unmapped_area);
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
+#ifdef CONFIG_VM_ACCT_USER
+	int overcommit_memory, overcommit_ratio;
+	struct vm_acct_values v;
+
+	if (!vm_acct_get_config(&v, current->uid)) {
+		overcommit_memory = v.overcommit_memory;
+		overcommit_ratio = v.overcommit_ratio;
+	} else {
+		overcommit_memory = sysctl_overcommit_memory;
+		overcommit_ratio = sysctl_overcommit_ratio;
+	}
+#else
+#define overcommit_memory sysctl_overcommit_memory
+#define overcommit_ratio sysctl_overcommit_ratio
+#endif
 
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+	if (overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -1299,7 +1314,7 @@ int __vm_enough_memory(long pages, int c
 		goto error;
 	}
 
-	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
+	allowed = totalram_pages * overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */
diff -urpN linux-2.6.21/mm/swap.c linux-2.6.21-vm-acct-user/mm/swap.c
--- linux-2.6.21/mm/swap.c	2007-05-07 20:20:24.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/swap.c	2007-05-07 20:20:42.000000000 +0200
@@ -30,6 +30,10 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/hash.h>
+#include <linux/seq_file.h>
+#include <linux/kernel.h>
+#include <linux/proc_fs.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -455,6 +459,196 @@ unsigned pagevec_lookup_tag(struct pagev
 
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
+#ifdef CONFIG_VM_ACCT_USER
+
+#define VM_ACCT_HASH_SHIFT	10
+#define VM_ACCT_HASH_SIZE	(1UL << VM_ACCT_HASH_SHIFT)
+#define vm_acct_hashfn(uid) hash_long((unsigned long)uid, VM_ACCT_HASH_SHIFT)
+
+/* User VM overcommit configuration */
+typedef struct vm_acct_hash_struct
+{
+	uid_t uid;
+	struct vm_acct_values val;
+	struct hlist_node vm_acct_chain;
+} vm_acct_hash_t;
+
+/* Hash list used to store per-user VM overcommit configurations */
+static struct hlist_head *vm_acct_hash;
+
+/* VM overcommit hash table spinlock */
+static __cacheline_aligned_in_smp DEFINE_SPINLOCK(vm_acct_lock);
+
+/*
+ * Get user VM configuration from the hash list.
+ */
+int vm_acct_get_config(struct vm_acct_values *v, uid_t uid)
+{
+	struct hlist_node *elem;
+	vm_acct_hash_t *p;
+
+	spin_lock_irq(&vm_acct_lock);
+	hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
+			     vm_acct_chain) {
+		if (p->uid == uid) {
+			v->overcommit_memory = p->val.overcommit_memory;
+			v->overcommit_ratio = p->val.overcommit_ratio;
+			spin_unlock_irq(&vm_acct_lock);
+			return 0;
+		}
+	}
+	spin_unlock_irq(&vm_acct_lock);
+
+	return -ENOENT;
+}
+
+/*
+ * Create a new element in the VM configuration hash list.
+ */
+static int __vm_acct_set_element(uid_t uid,
+			int overcommit_memory, int overcommit_ratio)
+{
+	struct hlist_node *elem;
+	vm_acct_hash_t *p;
+	int ret = 0;
+
+	spin_lock_irq(&vm_acct_lock);
+	hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
+			     vm_acct_chain) {
+		if (p->uid == uid) {
+			p->val.overcommit_memory = overcommit_memory;
+			p->val.overcommit_ratio = overcommit_ratio;
+			goto out;
+		}
+	}
+	spin_unlock_irq(&vm_acct_lock);
+
+	/* Allocate new element */
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	if (unlikely(!p)) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	p->uid = uid;
+	p->val.overcommit_memory = overcommit_memory;
+	p->val.overcommit_ratio = overcommit_ratio;
+
+	spin_lock_irq(&vm_acct_lock);
+	hlist_add_head(&p->vm_acct_chain, &vm_acct_hash[vm_acct_hashfn(uid)]);
+out:
+	spin_unlock_irq(&vm_acct_lock);
+	return ret;
+}
+
+/*
+ * Set VM user parameters via /proc/overcommit_uid.
+ */
+static int vm_acct_set(struct file *filp, const char __user *buffer,
+		       size_t count, loff_t *data)
+{
+	char buf[128];
+	char *om, *or;
+	int __ret;
+
+	/*
+	 * Parse ':'-separated arguments
+	 *     uid:overcommit_memory:overcommit_ratio
+	 */
+	if (count > sizeof(buf) - 1)
+		return -EFAULT;
+
+	if (copy_from_user(buf, buffer, count))
+		return -EFAULT;
+
+	buf[sizeof(buf) - 1] = '\0';
+
+	om = strstr(buf, ":");
+	if ((om == NULL) || (*++om == '\0')) {
+		return -EINVAL;
+	}
+
+	or = strstr(om, ":");
+	if ((or == NULL) || (*++or == '\0')) {
+		return -EINVAL;
+	}
+
+	/* Set VM configuration */
+	__ret = __vm_acct_set_element((uid_t)simple_strtoul(buf, NULL, 10),
+			    (int)simple_strtol(om, NULL, 10),
+			    (int)simple_strtol(or, NULL, 10));
+	if (__ret)
+		return __ret;
+
+	return count;
+}
+
+/*
+ * Print VM overcommit configurations.
+ */
+static int vm_acct_show(struct seq_file *m, void *v)
+{
+	struct hlist_node *elem;
+	vm_acct_hash_t *p;
+	int i;
+
+	spin_lock_irq(&vm_acct_lock);
+	for (i = 0; i < VM_ACCT_HASH_SIZE; i++) {
+		if (!&vm_acct_hash[i])
+			continue;
+		hlist_for_each_entry(p, elem, &vm_acct_hash[i],
+				vm_acct_chain) {
+			seq_printf(m, "%i:%i:%i\n",
+				   p->uid, p->val.overcommit_memory,
+				   p->val.overcommit_ratio);
+		}
+	}
+	spin_unlock_irq(&vm_acct_lock);
+
+	return 0;
+}
+
+static int vm_acct_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, vm_acct_show, NULL);
+}
+
+static struct file_operations vm_acct_ops = {
+	.open		= vm_acct_open,
+	.read		= seq_read,
+	.write		= vm_acct_set,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init init_vm_acct(void)
+{
+	struct proc_dir_entry *pe;
+	int i;
+
+	vm_acct_hash = kmalloc(VM_ACCT_HASH_SIZE * sizeof(*(vm_acct_hash)),
+			       GFP_KERNEL);
+	if (!vm_acct_hash)
+		return -ENOMEM;
+
+	printk(KERN_INFO "vm_acct_uid hash table entries: %lu\n",
+	       VM_ACCT_HASH_SIZE / sizeof(*(vm_acct_hash)));
+
+	spin_lock_irq(&vm_acct_lock);
+	for (i = 0; i < VM_ACCT_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&vm_acct_hash[i]);
+	spin_unlock_irq(&vm_acct_lock);
+
+	pe = create_proc_entry("overcommit_uid", 0600, NULL);
+	if (!pe)
+		return -ENOMEM;
+	pe->proc_fops = &vm_acct_ops;
+
+	return 0;
+}
+__initcall(init_vm_acct);
+
+#endif /* CONFIG_VM_ACCT_USER */
+
 #ifdef CONFIG_SMP
 /*
  * We tolerate a little inaccuracy to avoid ping-ponging the counter between

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
