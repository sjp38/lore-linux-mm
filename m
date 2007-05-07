Date: Mon, 7 May 2007 12:49:48 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
Message-ID: <20070507194948.GG19966@holomorphy.com>
References: <463F764E.5050009@users.sourceforge.net> <20070507191658.GY31925@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070507191658.GY31925@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 07, 2007 at 12:16:58PM -0700, William Lee Irwin III wrote:
> The following stanza occurs often:
> +       if (!vm_acct_get_config(&v, current->uid)) {
> +               overcommit_memory = v.overcommit_memory;
> +               overcommit_ratio = v.overcommit_ratio;
> +       } else {
> +               overcommit_memory = sysctl_overcommit_memory;
> +               overcommit_ratio = sysctl_overcommit_ratio;
> +       }
> 
> suggesting that vm_acct_get_config() isn't the proper abstraction.
> Instead of
> 	int vm_acct_get_config(struct vm_acct_values *, uid_t);
> you could just have
> 	int vm_acct_get_config(struct vm_acct_values *);
> which conditionally uses current->uid, and then unconditionally use
> v.overcommit_memory and v.overcommit_ratio vs. sysctl_overcommit_memory
> and sysctl_overcommit_ratio in the sequel.

Something like this (untested/uncompiled) may do.


Index: righi/include/linux/mman.h
===================================================================
--- righi.orig/include/linux/mman.h	2007-05-07 12:36:05.897386369 -0700
+++ righi/include/linux/mman.h	2007-05-07 12:42:29.803263919 -0700
@@ -18,14 +18,13 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern atomic_t vm_committed_space;
-#ifdef CONFIG_VM_ACCT_USER
+
 struct vm_acct_values
 {
 	int overcommit_memory;
 	int overcommit_ratio;
 };
-extern int vm_acct_get_config(struct vm_acct_values *v, uid_t uid);
-#endif
+void vm_acct_get_config(struct vm_acct_values *v);
 
 #ifdef CONFIG_SMP
 extern void vm_acct_memory(long pages);
Index: righi/mm/swap.c
===================================================================
--- righi.orig/mm/swap.c	2007-05-07 12:37:13.965265337 -0700
+++ righi/mm/swap.c	2007-05-07 12:42:14.914415451 -0700
@@ -482,10 +482,11 @@
 /*
  * Get user VM configuration from the hash list.
  */
-int vm_acct_get_config(struct vm_acct_values *v, uid_t uid)
+void vm_acct_get_config(struct vm_acct_values *v)
 {
 	struct hlist_node *elem;
 	vm_acct_hash_t *p;
+	uid_t uid = current->uid;
 
 	spin_lock_irq(&vm_acct_lock);
 	hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
@@ -494,12 +495,12 @@
 			v->overcommit_memory = p->val.overcommit_memory;
 			v->overcommit_ratio = p->val.overcommit_ratio;
 			spin_unlock_irq(&vm_acct_lock);
-			return 0;
+			return;
 		}
 	}
 	spin_unlock_irq(&vm_acct_lock);
-
-	return -ENOENT;
+	v->overcommit_memory = sysctl_overcommit_memory;
+	v->overcommit_ratio = sysctl_overcommit_ratio;
 }
 
 /*
@@ -646,8 +647,13 @@
 	return 0;
 }
 __initcall(init_vm_acct);
-
-#endif /* CONFIG_VM_ACCT_USER */
+#else /* !CONFIG_VM_ACCT_USER */
+void vm_acct_get_config(struct vm_acct_values *v)
+{
+	v->overcommit_memory = sysctl_overcommit_memory;
+	v->overcommit_ratio = sysctl_overcommit_ratio;
+}
+#endif /* !CONFIG_VM_ACCT_USER */
 
 #ifdef CONFIG_SMP
 /*
Index: righi/ipc/shm.c
===================================================================
--- righi.orig/ipc/shm.c	2007-05-07 12:40:35.576754521 -0700
+++ righi/ipc/shm.c	2007-05-07 12:43:32.714849046 -0700
@@ -370,24 +370,15 @@
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;
-#ifdef CONFIG_VM_ACCT_USER
-		int overcommit_memory;
 		struct vm_acct_values v;
 
-		if (!vm_acct_get_config(&v, current->uid)) {
-			overcommit_memory = v.overcommit_memory;
-		} else {
-			overcommit_memory = sysctl_overcommit_memory;
-		}
-#else
-#define overcommit_memory sysctl_overcommit_memory
-#endif
+		vm_acct_get_config(&v);
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
 	 	 * if it's asked for.
 		 */
 		if  ((shmflg & SHM_NORESERVE) &&
-				overcommit_memory != OVERCOMMIT_NEVER)
+				v.overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = 0;
 		sprintf (name, "SYSV%08x", key);
 		file = shmem_file_setup(name, size, acctflag);
Index: righi/mm/mmap.c
===================================================================
--- righi.orig/mm/mmap.c	2007-05-07 12:43:48.143728287 -0700
+++ righi/mm/mmap.c	2007-05-07 12:46:02.775400509 -0700
@@ -96,30 +96,18 @@
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
-#ifdef CONFIG_VM_ACCT_USER
-	int overcommit_memory, overcommit_ratio;
 	struct vm_acct_values v;
 
-	if (!vm_acct_get_config(&v, current->uid)) {
-		overcommit_memory = v.overcommit_memory;
-		overcommit_ratio = v.overcommit_ratio;
-	} else {
-		overcommit_memory = sysctl_overcommit_memory;
-		overcommit_ratio = sysctl_overcommit_ratio;
-	}
-#else
-#define overcommit_memory sysctl_overcommit_memory
-#define overcommit_ratio sysctl_overcommit_ratio
-#endif
+	vm_acct_get_config(&v);
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (v.overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (overcommit_memory == OVERCOMMIT_GUESS) {
+	if (v.overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -170,7 +158,7 @@
 	}
 
 	allowed = (totalram_pages - hugetlb_total_pages())
-	       	* overcommit_ratio / 100;
+	       	* v.overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */
@@ -916,10 +904,7 @@
 	struct rb_node ** rb_link, * rb_parent;
 	int accountable = 1;
 	unsigned long charged = 0, reqprot = prot;
-#ifdef CONFIG_VM_ACCT_USER
-	int overcommit_memory;
 	struct vm_acct_values v;
-#endif
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1059,15 +1044,9 @@
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
-#ifdef CONFIG_VM_ACCT_USER
-	if (!vm_acct_get_config(&v, current->uid)) {
-		overcommit_memory = v.overcommit_memory;
-	} else {
-		overcommit_memory = sysctl_overcommit_memory;
-	}
-#endif
+	vm_acct_get_config(&v);
 	if (accountable && (!(flags & MAP_NORESERVE) ||
-			    overcommit_memory == OVERCOMMIT_NEVER)) {
+			    v.overcommit_memory == OVERCOMMIT_NEVER)) {
 		if (vm_flags & VM_SHARED) {
 			/* Check memory availability in shmem_file_setup? */
 			vm_flags |= VM_ACCOUNT;
Index: righi/mm/nommu.c
===================================================================
--- righi.orig/mm/nommu.c	2007-05-07 12:46:09.667793284 -0700
+++ righi/mm/nommu.c	2007-05-07 12:46:52.490233596 -0700
@@ -1240,31 +1240,18 @@
 int __vm_enough_memory(long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
-#ifdef CONFIG_VM_ACCT_USER
-	int overcommit_memory, overcommit_ratio;
 	struct vm_acct_values v;
 
-	if (!vm_acct_get_config(&v, current->uid)) {
-		overcommit_memory = v.overcommit_memory;
-		overcommit_ratio = v.overcommit_ratio;
-	} else {
-		overcommit_memory = sysctl_overcommit_memory;
-		overcommit_ratio = sysctl_overcommit_ratio;
-	}
-#else
-#define overcommit_memory sysctl_overcommit_memory
-#define overcommit_ratio sysctl_overcommit_ratio
-#endif
-
+	vm_acct_get_config(&v);
 	vm_acct_memory(pages);
 
 	/*
 	 * Sometimes we want to use more memory than we have
 	 */
-	if (overcommit_memory == OVERCOMMIT_ALWAYS)
+	if (v.overcommit_memory == OVERCOMMIT_ALWAYS)
 		return 0;
 
-	if (overcommit_memory == OVERCOMMIT_GUESS) {
+	if (v.overcommit_memory == OVERCOMMIT_GUESS) {
 		unsigned long n;
 
 		free = global_page_state(NR_FILE_PAGES);
@@ -1314,7 +1301,7 @@
 		goto error;
 	}
 
-	allowed = totalram_pages * overcommit_ratio / 100;
+	allowed = totalram_pages * v.overcommit_ratio / 100;
 	/*
 	 * Leave the last 3% for root
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
