Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8BA36B026E
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:10 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id p9so71113467vkd.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:10 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i22si2480518uab.64.2016.12.16.10.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:09 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 12/14] mm: add mmap and shmat arch hooks for shared context
Date: Fri, 16 Dec 2016 10:35:35 -0800
Message-Id: <1481913337-9331-13-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Shared context will require some additional checking and processing
when mappings are created.  To faciliate this, add new mmap hooks
arch_pre_mmap_flags and arch_post_mmap to generic mm_hooks.  For
shmat, a new hook arch_shmat_check is added.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/powerpc/include/asm/mmu_context.h   | 12 ++++++++++++
 arch/s390/include/asm/mmu_context.h      | 12 ++++++++++++
 arch/unicore32/include/asm/mmu_context.h | 12 ++++++++++++
 arch/x86/include/asm/mmu_context.h       | 12 ++++++++++++
 include/asm-generic/mm_hooks.h           | 18 +++++++++++++++---
 ipc/shm.c                                | 13 +++++++++++++
 mm/mmap.c                                | 10 ++++++++++
 7 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 5c45114..d5ce33a 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -133,6 +133,18 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
 #endif
 }
 
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return 0;	/* no errors */
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags)
+{
+}
+
 static inline void arch_dup_mmap(struct mm_struct *oldmm,
 				 struct mm_struct *mm)
 {
diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
index 515fea5..0a2322d 100644
--- a/arch/s390/include/asm/mmu_context.h
+++ b/arch/s390/include/asm/mmu_context.h
@@ -129,6 +129,18 @@ static inline void activate_mm(struct mm_struct *prev,
 	set_user_asce(next);
 }
 
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return 0;	/* no errors */
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags)
+{
+}
+
 static inline void arch_dup_mmap(struct mm_struct *oldmm,
 				 struct mm_struct *mm)
 {
diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index 62dfc64..8b57b9d 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -81,6 +81,18 @@ do { \
 	} \
 } while (0)
 
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return 0;	/* no errors */
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags)
+{
+}
+
 static inline void arch_dup_mmap(struct mm_struct *oldmm,
 				 struct mm_struct *mm)
 {
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 8e0a9fe..fe60309 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -151,6 +151,18 @@ do {						\
 } while (0)
 #endif
 
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return 0;	/* no errors */
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags)
+{
+}
+
 static inline void arch_dup_mmap(struct mm_struct *oldmm,
 				 struct mm_struct *mm)
 {
diff --git a/include/asm-generic/mm_hooks.h b/include/asm-generic/mm_hooks.h
index cc5d9a1..c742e52 100644
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -1,11 +1,23 @@
 /*
- * Define generic no-op hooks for arch_dup_mmap, arch_exit_mmap
- * and arch_unmap to be included in asm-FOO/mmu_context.h for any
- * arch FOO which doesn't need to hook these.
+ * Define generic no-op hooks for mmap and protection related routines
+ * to be included in asm-FOO/mmu_context.h for any arch FOO which doesn't
+ * need to hook these.
  */
 #ifndef _ASM_GENERIC_MM_HOOKS_H
 #define _ASM_GENERIC_MM_HOOKS_H
 
+static inline unsigned long arch_pre_mmap_flags(struct file *file,
+						unsigned long flags,
+						vm_flags_t *vm_flags)
+{
+	return 0;	/* no errors */
+}
+
+static inline void arch_post_mmap(struct mm_struct *mm, unsigned long addr,
+					vm_flags_t vm_flags)
+{
+}
+
 static inline void arch_dup_mmap(struct mm_struct *oldmm,
 				 struct mm_struct *mm)
 {
diff --git a/ipc/shm.c b/ipc/shm.c
index dbac886..dab6cd1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -72,6 +72,14 @@ static void shm_destroy(struct ipc_namespace *ns, struct shmid_kernel *shp);
 static int sysvipc_shm_proc_show(struct seq_file *s, void *it);
 #endif
 
+#ifndef arch_shmat_check
+#define arch_shmat_check(file, shmflg, flags) (0)
+#endif
+
+#ifndef arch_shmat_check
+#define arch_shmat_check(file, shmflg, flags) (0)
+#endif
+
 void shm_init_ns(struct ipc_namespace *ns)
 {
 	ns->shm_ctlmax = SHMMAX;
@@ -1149,6 +1157,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		goto out_unlock;
 	}
 
+	/* arch specific check and possible flag modification */
+	err = arch_shmat_check(shp->shm_file, shmflg, &flags);
+	if (err)
+		goto out_unlock;
+
 	err = -EACCES;
 	if (ipcperms(ns, &shp->shm_perm, acc_mode))
 		goto out_unlock;
diff --git a/mm/mmap.c b/mm/mmap.c
index 1af87c1..7fc946b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1307,6 +1307,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			unsigned long pgoff, unsigned long *populate)
 {
 	struct mm_struct *mm = current->mm;
+	unsigned long ret;
 	int pkey = 0;
 
 	*populate = 0;
@@ -1314,6 +1315,11 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	if (!len)
 		return -EINVAL;
 
+	/* arch specific check and possible modification of vm_flags */
+	ret = arch_pre_mmap_flags(file, flags, &vm_flags);
+	if (ret)
+		return ret;
+
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
 	 *
@@ -1452,6 +1458,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
 		*populate = len;
+
+	if (!IS_ERR_VALUE(addr))
+		arch_post_mmap(mm, addr, vm_flags);
+
 	return addr;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
