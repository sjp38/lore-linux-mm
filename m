Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0A906B0039
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:49:36 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so121609lam.20
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:49:36 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id at8si24349135lac.60.2014.07.03.05.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:49:36 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 4/5] vm_cgroup: shared memory accounting
Date: Thu, 3 Jul 2014 16:48:20 +0400
Message-ID: <5f29efb826a52d4956d24786a29f9cdc0029c3fa.1404383187.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

Address space that contributes to memory overcommit consists of two
parts - private writable mappings and shared memory. This patch adds
shared memory accounting.

Each shmem inode holds a reference to the vm cgroup it is accounted to.
The reference is initialized with the current cgroup on shmem inode
creation and released only on shmem inode destruction. For simplicity,
shmem inodes accounted to a vm cgroup are not re-charged to the parent
on css offline yet, so offline cgroups will be hanging in memory until
all inodes accounted to it die.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/shmem_fs.h  |    6 ++++++
 include/linux/vm_cgroup.h |   32 ++++++++++++++++++++++++++++++++
 mm/shmem.c                |   39 +++++++++++++++++++++++++++++++++------
 mm/vm_cgroup.c            |   36 ++++++++++++++++++++++++++++++++++++
 4 files changed, 107 insertions(+), 6 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 4d1771c2d29f..b87f8b35ad40 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -7,6 +7,8 @@
 #include <linux/percpu_counter.h>
 #include <linux/xattr.h>
 
+struct vm_cgroup;
+
 /* inode in-kernel data */
 
 struct shmem_inode_info {
@@ -21,6 +23,10 @@ struct shmem_inode_info {
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
 	struct inode		vfs_inode;
+#ifdef CONFIG_CGROUP_VM
+	struct vm_cgroup	*vmcg;		/* vm_cgroup this inode is
+						   accounted to */
+#endif
 };
 
 struct shmem_sb_info {
diff --git a/include/linux/vm_cgroup.h b/include/linux/vm_cgroup.h
index 34ed936a0a10..582f051091bd 100644
--- a/include/linux/vm_cgroup.h
+++ b/include/linux/vm_cgroup.h
@@ -2,6 +2,7 @@
 #define _LINUX_VM_CGROUP_H
 
 struct mm_struct;
+struct shmem_inode_info;
 
 #ifdef CONFIG_CGROUP_VM
 static inline bool vm_cgroup_disabled(void)
@@ -17,6 +18,16 @@ extern int vm_cgroup_charge_memory_mm(struct mm_struct *mm,
 				      unsigned long nr_pages);
 extern void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm,
 					 unsigned long nr_pages);
+
+#ifdef CONFIG_SHMEM
+extern void shmem_init_vm_cgroup(struct shmem_inode_info *info);
+extern void shmem_release_vm_cgroup(struct shmem_inode_info *info);
+extern int vm_cgroup_charge_shmem(struct shmem_inode_info *info,
+				  unsigned long nr_pages);
+extern void vm_cgroup_uncharge_shmem(struct shmem_inode_info *info,
+				     unsigned long nr_pages);
+#endif
+
 #else /* !CONFIG_CGROUP_VM */
 static inline bool vm_cgroup_disabled(void)
 {
@@ -42,6 +53,27 @@ static inline void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm,
 						unsigned long nr_pages)
 {
 }
+
+#ifdef CONFIG_SHMEM
+static inline void shmem_init_vm_cgroup(struct shmem_inode_info *info)
+{
+}
+
+static inline void shmem_release_vm_cgroup(struct shmem_inode_info *info)
+{
+}
+
+static inline int vm_cgroup_charge_shmem(struct shmem_inode_info *info,
+					 unsigned long nr_pages)
+{
+}
+
+static inline void vm_cgroup_uncharge_shmem(struct shmem_inode_info *info,
+					    unsigned long nr_pages)
+{
+}
+#endif
+
 #endif /* CONFIG_CGROUP_VM */
 
 #endif /* _LINUX_VM_CGROUP_H */
diff --git a/mm/shmem.c b/mm/shmem.c
index 4e28eb1222cd..3968cdf1d254 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -66,6 +66,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/highmem.h>
 #include <linux/seq_file.h>
 #include <linux/magic.h>
+#include <linux/vm_cgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -130,6 +131,27 @@ static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
 	return sb->s_fs_info;
 }
 
+static inline int __shmem_acct_memory(struct shmem_inode_info *info,
+				      long pages)
+{
+	int ret;
+
+	ret = vm_cgroup_charge_shmem(info, pages);
+	if (ret)
+		return ret;
+	ret = security_vm_enough_memory_mm(current->mm, pages);
+	if (ret)
+		vm_cgroup_uncharge_shmem(info, pages);
+	return ret;
+}
+
+static inline void __shmem_unacct_memory(struct shmem_inode_info *info,
+					 long pages)
+{
+	vm_unacct_memory(pages);
+	vm_cgroup_uncharge_shmem(info, pages);
+}
+
 /*
  * shmem_file_setup pre-accounts the whole fixed size of a VM object,
  * for shared memory and for shared anonymous (/dev/zero) mappings
@@ -141,7 +163,7 @@ static inline int shmem_acct_size(struct inode *inode)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	return (info->flags & VM_NORESERVE) ?
-		0 : security_vm_enough_memory_mm(current->mm, VM_ACCT(inode->i_size));
+		0 : __shmem_acct_memory(info, VM_ACCT(inode->i_size));
 }
 
 static inline void shmem_unacct_size(struct inode *inode)
@@ -149,7 +171,7 @@ static inline void shmem_unacct_size(struct inode *inode)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	if (!(info->flags & VM_NORESERVE))
-		vm_unacct_memory(VM_ACCT(inode->i_size));
+		__shmem_unacct_memory(info, VM_ACCT(inode->i_size));
 }
 
 /*
@@ -163,7 +185,7 @@ static inline int shmem_acct_block(struct inode *inode)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	return (info->flags & VM_NORESERVE) ?
-		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
+		__shmem_acct_memory(info, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
 }
 
 static inline void shmem_unacct_blocks(struct inode *inode, long pages)
@@ -171,7 +193,7 @@ static inline void shmem_unacct_blocks(struct inode *inode, long pages)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	if (info->flags & VM_NORESERVE)
-		vm_unacct_memory(pages * VM_ACCT(PAGE_CACHE_SIZE));
+		__shmem_unacct_memory(info, pages * VM_ACCT(PAGE_CACHE_SIZE));
 }
 
 static const struct super_operations shmem_ops;
@@ -1339,6 +1361,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 			inode->i_fop = &shmem_file_operations;
 			mpol_shared_policy_init(&info->policy,
 						 shmem_get_sbmpol(sbinfo));
+			shmem_init_vm_cgroup(info);
 			break;
 		case S_IFDIR:
 			inc_nlink(inode);
@@ -2590,8 +2613,12 @@ static void shmem_destroy_callback(struct rcu_head *head)
 
 static void shmem_destroy_inode(struct inode *inode)
 {
-	if (S_ISREG(inode->i_mode))
-		mpol_free_shared_policy(&SHMEM_I(inode)->policy);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	if (S_ISREG(inode->i_mode)) {
+		mpol_free_shared_policy(&info->policy);
+		shmem_release_vm_cgroup(info);
+	}
 	call_rcu(&inode->i_rcu, shmem_destroy_callback);
 }
 
diff --git a/mm/vm_cgroup.c b/mm/vm_cgroup.c
index 4dd693b34e33..6642f934540a 100644
--- a/mm/vm_cgroup.c
+++ b/mm/vm_cgroup.c
@@ -3,6 +3,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/rcupdate.h>
+#include <linux/shmem_fs.h>
 #include <linux/vm_cgroup.h>
 
 struct vm_cgroup {
@@ -92,6 +93,41 @@ void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm, unsigned long nr_pages)
 		vm_cgroup_do_uncharge(vmcg, nr_pages);
 }
 
+#ifdef CONFIG_SHMEM
+void shmem_init_vm_cgroup(struct shmem_inode_info *info)
+{
+	if (!vm_cgroup_disabled())
+		info->vmcg = get_vm_cgroup_from_task(current);
+}
+
+void shmem_release_vm_cgroup(struct shmem_inode_info *info)
+{
+	struct vm_cgroup *vmcg = info->vmcg;
+
+	if (vmcg)
+		css_put(&vmcg->css);
+}
+
+int vm_cgroup_charge_shmem(struct shmem_inode_info *info,
+			   unsigned long nr_pages)
+{
+	struct vm_cgroup *vmcg = info->vmcg;
+
+	if (vmcg)
+		return vm_cgroup_do_charge(vmcg, nr_pages);
+	return 0;
+}
+
+void vm_cgroup_uncharge_shmem(struct shmem_inode_info *info,
+			      unsigned long nr_pages)
+{
+	struct vm_cgroup *vmcg = info->vmcg;
+
+	if (vmcg)
+		vm_cgroup_do_uncharge(info->vmcg, nr_pages);
+}
+#endif /* CONFIG_SHMEM */ 
+
 static struct cgroup_subsys_state *
 vm_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
