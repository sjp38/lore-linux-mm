Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 354F66B0085
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:24:38 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v3
Date: Wed,  3 Oct 2012 15:24:23 -0700
Message-Id: <1349303063-12766-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
References: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

There was some desire in large applications using MAP_HUGETLB/SHM_HUGETLB
to use 1GB huge pages on some mappings, and stay with 2MB on others. This
is useful together with NUMA policy: use 2MB interleaving on some mappings,
but 1GB on local mappings.

This patch extends the IPC/SHM syscall interfaces slightly to allow specifying
the page size.

It borrows some upper bits in the existing flag arguments and allows encoding
the log of the desired page size in addition to the *_HUGETLB flag.
When 0 is specified the default size is used, this makes the change fully
compatible.

Extending the internal hugetlb code to handle this is straight forward. Instead
of a single mount it just keeps an array of them and selects the right
mount based on the specified page size.

I also exported the new flags to the user headers
(they were previously under __KERNEL__). Right now only symbols
for x86 and some other architecture for 1GB and 2MB are defined.
The interface should already work for all other architectures
though.

v2: Port to new tree. Fix unmount.
v3: Ported to latest tree.
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 arch/x86/include/asm/mman.h |    3 ++
 fs/hugetlbfs/inode.c        |   63 ++++++++++++++++++++++++++++++++++---------
 include/asm-generic/mman.h  |   13 +++++++++
 include/linux/hugetlb.h     |   12 +++++++-
 include/linux/shm.h         |   19 +++++++++++++
 ipc/shm.c                   |    3 +-
 mm/mmap.c                   |    5 ++-
 7 files changed, 100 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/mman.h b/arch/x86/include/asm/mman.h
index 593e51d..513b05f 100644
--- a/arch/x86/include/asm/mman.h
+++ b/arch/x86/include/asm/mman.h
@@ -3,6 +3,9 @@
 
 #define MAP_32BIT	0x40		/* only give out 32bit addresses */
 
+#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
+#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)
+
 #include <asm-generic/mman.h>
 
 #endif /* _ASM_X86_MMAN_H */
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9460120..f6fb699 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -924,7 +924,7 @@ static struct file_system_type hugetlbfs_fs_type = {
 	.kill_sb	= kill_litter_super,
 };
 
-static struct vfsmount *hugetlbfs_vfsmount;
+static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
 
 static int can_do_hugetlb_shm(void)
 {
@@ -933,9 +933,22 @@ static int can_do_hugetlb_shm(void)
 	return capable(CAP_IPC_LOCK) || in_group_p(shm_group);
 }
 
+static int get_hstate_idx(int page_size_log)
+{
+	struct hstate *h;
+
+	if (!page_size_log)
+		return default_hstate_idx;
+	h = size_to_hstate(1 << page_size_log);
+	if (!h)
+		return -1;
+	return h - hstates;
+}
+
 struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 				size_t size, vm_flags_t acctflag,
-				struct user_struct **user, int creat_flags)
+				struct user_struct **user,
+				int creat_flags, int page_size_log)
 {
 	int error = -ENOMEM;
 	struct file *file;
@@ -945,9 +958,14 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 	struct qstr quick_string;
 	struct hstate *hstate;
 	unsigned long num_pages;
+	int hstate_idx;
+
+	hstate_idx = get_hstate_idx(page_size_log);
+	if (hstate_idx < 0)
+		return ERR_PTR(-ENODEV);
 
 	*user = NULL;
-	if (!hugetlbfs_vfsmount)
+	if (!hugetlbfs_vfsmount[hstate_idx])
 		return ERR_PTR(-ENOENT);
 
 	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
@@ -964,7 +982,7 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 		}
 	}
 
-	root = hugetlbfs_vfsmount->mnt_root;
+	root = hugetlbfs_vfsmount[hstate_idx]->mnt_root;
 	quick_string.name = name;
 	quick_string.len = strlen(quick_string.name);
 	quick_string.hash = 0;
@@ -972,7 +990,7 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 	if (!path.dentry)
 		goto out_shm_unlock;
 
-	path.mnt = mntget(hugetlbfs_vfsmount);
+	path.mnt = mntget(hugetlbfs_vfsmount[hstate_idx]);
 	error = -ENOSPC;
 	inode = hugetlbfs_get_inode(root->d_sb, NULL, S_IFREG | S_IRWXUGO, 0);
 	if (!inode)
@@ -1012,8 +1030,9 @@ out_shm_unlock:
 
 static int __init init_hugetlbfs_fs(void)
 {
+	struct hstate *h;
 	int error;
-	struct vfsmount *vfsmount;
+	int i;
 
 	error = bdi_init(&hugetlbfs_backing_dev_info);
 	if (error)
@@ -1030,14 +1049,26 @@ static int __init init_hugetlbfs_fs(void)
 	if (error)
 		goto out;
 
-	vfsmount = kern_mount(&hugetlbfs_fs_type);
+	i = 0;
+	for_each_hstate (h) {
+		char buf[50];
+		unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
 
-	if (!IS_ERR(vfsmount)) {
-		hugetlbfs_vfsmount = vfsmount;
-		return 0;
-	}
+		snprintf(buf, sizeof buf, "pagesize=%uK", ps_kb);
+		hugetlbfs_vfsmount[i] = kern_mount_data(&hugetlbfs_fs_type,
+							buf);
 
-	error = PTR_ERR(vfsmount);
+		if (IS_ERR(hugetlbfs_vfsmount[i])) {
+				pr_err(
+			"hugetlb: Cannot mount internal hugetlbfs for page size %uK",
+			       ps_kb);
+			error = PTR_ERR(hugetlbfs_vfsmount[i]);
+		}
+		i++;
+	}
+	/* Non default hstates are optional */
+	if (hugetlbfs_vfsmount[default_hstate_idx])
+		return 0;
 
  out:
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
@@ -1048,13 +1079,19 @@ static int __init init_hugetlbfs_fs(void)
 
 static void __exit exit_hugetlbfs_fs(void)
 {
+	struct hstate *h;
+	int i;
+
+
 	/*
 	 * Make sure all delayed rcu free inodes are flushed before we
 	 * destroy cache.
 	 */
 	rcu_barrier();
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
-	kern_unmount(hugetlbfs_vfsmount);
+	i = 0;
+	for_each_hstate (h)
+		kern_unmount(hugetlbfs_vfsmount[i++]);
 	unregister_filesystem(&hugetlbfs_fs_type);
 	bdi_destroy(&hugetlbfs_backing_dev_info);
 }
diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
index 32c8bd6..d2f35d8 100644
--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -13,6 +13,19 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
+/* Bits [26:31] are reserved */
+
+/*
+ * When MAP_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
+ * This gives us 6 bits, which is enough until someone invents 128 bit address
+ * spaces.
+ *
+ * Assume these are all power of twos.
+ * When 0 use the default page size.
+ */
+#define MAP_HUGE_SHIFT  26
+#define MAP_HUGE_MASK   0x3f
+
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2251648..c626a2a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -183,7 +183,13 @@ extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 				size_t size, vm_flags_t acct,
-				struct user_struct **user, int creat_flags);
+				struct user_struct **user, int creat_flags,
+				int page_size_log);
+int hugetlb_get_quota(struct address_space *mapping, long delta);
+void hugetlb_put_quota(struct address_space *mapping, long delta);
+
+int hugetlb_get_quota(struct address_space *mapping, long delta);
+void hugetlb_put_quota(struct address_space *mapping, long delta);
 
 static inline int is_file_hugepages(struct file *file)
 {
@@ -195,12 +201,14 @@ static inline int is_file_hugepages(struct file *file)
 	return 0;
 }
 
+
 #else /* !CONFIG_HUGETLBFS */
 
 #define is_file_hugepages(file)			0
 static inline struct file *
 hugetlb_file_setup(const char *name, unsigned long addr, size_t size,
-		vm_flags_t acctflag, struct user_struct **user, int creat_flags)
+		vm_flags_t acctflag, struct user_struct **user, int creat_flags,
+		int page_size_log)
 {
 	return ERR_PTR(-ENOSYS);
 }
diff --git a/include/linux/shm.h b/include/linux/shm.h
index edd0868..d2b0ce0 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -100,12 +100,31 @@ struct shmid_kernel /* private to the kernel */
 	struct task_struct	*shm_creator;
 };
 
+#endif
+
 /* shm_mode upper byte flags */
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
 #define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
 #define SHM_NORESERVE   010000  /* don't check for reservations */
 
+/* Bits [26:31] are reserved */
+
+/*
+ * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
+ * This gives us 6 bits, which is enough until someone invents 128 bit address
+ * spaces.
+ *
+ * Assume these are all power of twos.
+ * When 0 use the default page size.
+ */
+#define SHM_HUGE_SHIFT  26
+#define SHM_HUGE_MASK   0x3f
+#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
+#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
+
+#ifdef __KERNEL__
+
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr,
 	      unsigned long shmlba);
diff --git a/ipc/shm.c b/ipc/shm.c
index dff40c9..4fa6d8f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -495,7 +495,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 		if (shmflg & SHM_NORESERVE)
 			acctflag = VM_NORESERVE;
 		file = hugetlb_file_setup(name, 0, size, acctflag,
-					&shp->mlock_user, HUGETLB_SHMFS_INODE);
+				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
+				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
 	} else {
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
diff --git a/mm/mmap.c b/mm/mmap.c
index 872441e..5eb3ba7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1127,8 +1127,9 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		 * memory so no accounting is necessary
 		 */
 		file = hugetlb_file_setup(HUGETLB_ANON_FILE, addr, len,
-						VM_NORESERVE, &user,
-						HUGETLB_ANONHUGE_INODE);
+				VM_NORESERVE,
+				&user, HUGETLB_ANONHUGE_INODE,
+				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
 		if (IS_ERR(file))
 			return PTR_ERR(file);
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
