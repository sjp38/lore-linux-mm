Message-ID: <463FACB2.4010904@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
References: <463F764E.5050009@users.sourceforge.net> <20070507191658.GY31925@holomorphy.com> <20070507194948.GG19966@holomorphy.com>
In-Reply-To: <20070507194948.GG19966@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Date: Tue,  8 May 2007 00:48:46 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Luca Tettamanti <kronos.it@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Mon, May 07, 2007 at 12:16:58PM -0700, William Lee Irwin III wrote:
>> The following stanza occurs often:
>> +       if (!vm_acct_get_config(&v, current->uid)) {
>> +               overcommit_memory = v.overcommit_memory;
>> +               overcommit_ratio = v.overcommit_ratio;
>> +       } else {
>> +               overcommit_memory = sysctl_overcommit_memory;
>> +               overcommit_ratio = sysctl_overcommit_ratio;
>> +       }
>>
>> suggesting that vm_acct_get_config() isn't the proper abstraction.
>> Instead of
>> 	int vm_acct_get_config(struct vm_acct_values *, uid_t);
>> you could just have
>> 	int vm_acct_get_config(struct vm_acct_values *);
>> which conditionally uses current->uid, and then unconditionally use
>> v.overcommit_memory and v.overcommit_ratio vs. sysctl_overcommit_memory
>> and sysctl_overcommit_ratio in the sequel.
> 
> Something like this (untested/uncompiled) may do.

[snip]

I agree with everything, applied all the changes and fixed the bug reported by
Luca (see below). It seems to compile and work without problem. Thanks!

Signed-off-by: Andrea Righi <a.righi@cineca.it>
---

diff -urpN linux-2.6.21/include/linux/mman.h linux-2.6.21-vm-acct-user/include/linux/mman.h
--- linux-2.6.21/include/linux/mman.h	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/include/linux/mman.h	2007-05-07 23:33:16.000000000 +0200
@@ -18,6 +18,20 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern atomic_t vm_committed_space;
+struct vm_acct_values
+{
+	int overcommit_memory;
+	int overcommit_ratio;
+};
+#ifdef CONFIG_VM_ACCT_USER
+extern void vm_acct_get_config(struct vm_acct_values *v);
+#else
+static inline void vm_acct_get_config(struct vm_acct_values *v)
+{
+        v->overcommit_memory = sysctl_overcommit_memory;
+        v->overcommit_ratio = sysctl_overcommit_ratio;
+}
+#endif
 
 #ifdef CONFIG_SMP
 extern void vm_acct_memory(long pages);
diff -urpN linux-2.6.21/ipc/shm.c linux-2.6.21-vm-acct-user/ipc/shm.c
--- linux-2.6.21/ipc/shm.c	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/ipc/shm.c	2007-05-07 23:24:04.000000000 +0200
@@ -370,12 +370,15 @@ static int newseg (struct ipc_namespace 
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;
+		struct vm_acct_values v;
+	
+		vm_acct_get_config(&v);
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
 	 	 * if it's asked for.
 		 */
 		if  ((shmflg & SHM_NORESERVE) &&
-				sysctl_overcommit_memory != OVERCOMMIT_NEVER)
+				v.overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = 0;
 		sprintf (name, "SYSV%08x", key);
 		file = shmem_file_setup(name, size, acctflag);
diff -urpN linux-2.6.21/mm/Kconfig linux-2.6.21-vm-acct-user/mm/Kconfig
--- linux-2.6.21/mm/Kconfig	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/Kconfig	2007-05-07 23:15:51.000000000 +0200
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
--- linux-2.6.21/mm/mmap.c	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/mmap.c	2007-05-07 23:25:56.000000000 +0200
@@ -95,16 +95,18 @@ atomic_t vm_committed_space = ATOMIC_INI
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
-
+	struct vm_acct_values v;
+	
+	vm_acct_get_config(&v);
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (v.overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+	if (v.overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -155,7 +157,7 @@ int __vm_enough_memory(long pages, int c
 	}
 
 	allowed = (totalram_pages - hugetlb_total_pages())
-	       	* sysctl_overcommit_ratio / 100;
+	       	* v.overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */
@@ -901,6 +903,7 @@ unsigned long do_mmap_pgoff(struct file 
 	struct rb_node ** rb_link, * rb_parent;
 	int accountable = 1;
 	unsigned long charged = 0, reqprot = prot;
+	struct vm_acct_values v;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1040,8 +1043,9 @@ munmap_back:
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
+	vm_acct_get_config(&v);
 	if (accountable && (!(flags & MAP_NORESERVE) ||
-			    sysctl_overcommit_memory == OVERCOMMIT_NEVER)) {
+			    v.overcommit_memory == OVERCOMMIT_NEVER)) {
 		if (vm_flags & VM_SHARED) {
 			/* Check memory availability in shmem_file_setup? */
 			vm_flags |= VM_ACCOUNT;
diff -urpN linux-2.6.21/mm/nommu.c linux-2.6.21-vm-acct-user/mm/nommu.c
--- linux-2.6.21/mm/nommu.c	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/nommu.c	2007-05-07 23:27:03.000000000 +0200
@@ -1240,16 +1240,18 @@ EXPORT_SYMBOL(get_unmapped_area);
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
+	struct vm_acct_values v;
 
+	vm_acct_get_config(&v);
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (v.overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+	if (v.overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -1299,7 +1301,7 @@ int __vm_enough_memory(long pages, int c
 		goto error;
 	}
 
-	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
+	allowed = totalram_pages * v.overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */
diff -urpN linux-2.6.21/mm/swap.c linux-2.6.21-vm-acct-user/mm/swap.c
--- linux-2.6.21/mm/swap.c	2007-05-07 20:44:50.000000000 +0200
+++ linux-2.6.21-vm-acct-user/mm/swap.c	2007-05-07 23:33:40.000000000 +0200
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
+void vm_acct_get_config(struct vm_acct_values *v)
+{
+	struct hlist_node *elem;
+	vm_acct_hash_t *p;
+	uid_t uid = current->uid;
+
+	spin_lock_irq(&vm_acct_lock);
+	hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
+			     vm_acct_chain) {
+		if (p->uid == uid) {
+			v->overcommit_memory = p->val.overcommit_memory;
+			v->overcommit_ratio = p->val.overcommit_ratio;
+			spin_unlock_irq(&vm_acct_lock);
+			return;
+		}
+	}
+	spin_unlock_irq(&vm_acct_lock);
+
+	v->overcommit_memory = sysctl_overcommit_memory;
+	v->overcommit_ratio = sysctl_overcommit_ratio;
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
+		return -ENOMEM;
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
+	int ret;
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
+	ret = __vm_acct_set_element((uid_t)simple_strtoul(buf, NULL, 10),
+			    (int)simple_strtol(om, NULL, 10),
+			    (int)simple_strtol(or, NULL, 10));
+	if (ret)
+		return ret;
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
