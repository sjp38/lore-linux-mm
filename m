Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3116B009D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:59 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 36/43] c/r: support share-memory sysv-ipc
Date: Wed, 27 May 2009 13:33:02 -0400
Message-Id: <1243445589-32388-37-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpoint of sysvipc shared memory is performed in two steps: first,
the entire ipc namespace is dumped as a whole by iterating through all
shm objects and dumping the contents of each one. The shmem inode is
registered in the objhash. Second, for each vma that refers to ipc
shared memory we find the inode in the objhash, and save the objref.

(If we find a new inode, that indicates that the ipc namespace is not
entirely frozen and someone must have manipulated it since step 1).

Handling of shm objects that have been deleted (via IPC_RMID) is left
to a later patch in this series.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/memory.c              |   28 ++++-
 checkpoint/sys.c                 |   10 ++
 include/linux/checkpoint.h       |    3 +
 include/linux/checkpoint_hdr.h   |   19 +++-
 include/linux/checkpoint_types.h |    1 +
 include/linux/shm.h              |    9 ++
 ipc/Makefile                     |    2 +-
 ipc/checkpoint.c                 |    4 +-
 ipc/checkpoint_shm.c             |  261 ++++++++++++++++++++++++++++++++++++++
 ipc/shm.c                        |   73 +++++++++++
 ipc/util.h                       |    4 +-
 11 files changed, 406 insertions(+), 8 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index c163b76..997359f 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -20,6 +20,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
+#include <linux/shm.h>
 #include <linux/proc_fs.h>
 #include <linux/swap.h>
 #include <linux/checkpoint.h>
@@ -459,9 +460,9 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
  * virtual addresses into ctx->pgarr_list page-array chain. Then dump
  * the addresses, followed by the page contents.
  */
-static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
-				      struct vm_area_struct *vma,
-				      struct inode *inode)
+int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+			       struct vm_area_struct *vma,
+			       struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long addr, end;
@@ -1022,6 +1023,13 @@ static int anon_private_restore(struct ckpt_ctx *ctx,
 	return private_vma_restore(ctx, mm, NULL, h);
 }
 
+static int bad_vma_restore(struct ckpt_ctx *ctx,
+			   struct mm_struct *mm,
+			   struct ckpt_hdr_vma *h)
+{
+	return -EINVAL;
+}
+
 /* callbacks to restore vma per its type: */
 struct restore_vma_ops {
 	char *vma_name;
@@ -1074,6 +1082,20 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_SHM_FILE,
 		.restore = filemap_restore,
 	},
+	/* sysvipc shared */
+	{
+		.vma_name = "IPC SHARED",
+		.vma_type = CKPT_VMA_SHM_IPC,
+		/* ipc inode itself is restore by restore_ipc_ns()... */
+		.restore = bad_vma_restore,
+
+	},
+	/* sysvipc shared (skip) */
+	{
+		.vma_name = "IPC SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
+		.restore = ipcshm_restore,
+	},
 };
 
 /**
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index f6cf0ac..ac3bf7c 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -20,6 +20,7 @@
 #include <linux/uaccess.h>
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
+#include <linux/deferqueue.h>
 
 /*
  * ckpt_unpriv_allowed - sysctl controlled, do not allow checkpoints or
@@ -188,8 +189,17 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
+	int ret;
+
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	if (ctx->deferqueue) {
+		ret = deferqueue_run(ctx->deferqueue);
+		if (ret != 0)
+			pr_warning("c/r: deferqueue had %d entries\n", ret);
+		deferqueue_destroy(ctx->deferqueue);
+	}
+
 	if (ctx->file)
 		fput(ctx->file);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d5498bc..064dd25 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -145,6 +145,9 @@ extern unsigned long generic_vma_restore(struct mm_struct *mm,
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
+extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma,
+				      struct inode *inode);
 extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 406b5d6..f7e331d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -278,7 +278,9 @@ enum vma_type {
 	CKPT_VMA_SHM_ANON,	/* shared anonymous */
 	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
 	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
-	CKPT_VMA_MAX
+	CKPT_VMA_SHM_IPC,	/* shared sysvipc */
+	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
+	CKPT_VMA_MAX,
 };
 
 /* vma descriptor */
@@ -328,6 +330,7 @@ struct ckpt_hdr_ipc {
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_perms {
+	struct ckpt_hdr h;
 	__s32 id;
 	__u32 key;
 	__u32 uid;
@@ -339,6 +342,20 @@ struct ckpt_hdr_ipc_perms {
 	__u64 seq;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_shm {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
+	__u64 shm_segsz;
+	__u64 shm_atim;
+	__u64 shm_dtim;
+	__u64 shm_ctim;
+	__s32 shm_cprid;
+	__s32 shm_lprid;
+	__u32 mlock_uid;
+	__u32 flags;
+	__u32 objref;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index f39e1c1..45a0f80 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -50,6 +50,7 @@ struct ckpt_ctx {
 	atomic_t refcount;
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+	struct deferqueue_head *deferqueue;	/* queue of deferred work */
 
 	struct path fs_mnt;     /* container root (FIXME) */
 
diff --git a/include/linux/shm.h b/include/linux/shm.h
index ec36e99..97972eb 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -122,6 +122,15 @@ struct ipc_namespace;
 extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		       struct shmid_ds __user *buf, int version);
 
+#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_SYSVIPC
+extern int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			  struct ckpt_hdr_vma *h);
+#else
+define ipcshm_restart NULL
+#endif
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SHM_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index aa6c8dd..7e23683 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 436be5e..25d2277 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -102,9 +102,9 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 	if (ret < 0)
 		return ret;
 
-#if 0 /* NEXT FEW PATCHES */
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
@@ -214,9 +214,9 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 	ipc_ns->sem_ctls[2] = h->sem_ctl_opm;
 	ipc_ns->sem_ctls[3] = h->sem_ctl_mni;
 
-#if 0 /* NEXT FEW PATCHES */
 	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = ckpt_read_ipc_any(ctx, IPC_MSG_IDS,
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
new file mode 100644
index 0000000..713f910
--- /dev/null
+++ b/ipc/checkpoint_shm.c
@@ -0,0 +1,261 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc shm
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/mm.h>
+#include <linux/shm.h>
+#include <linux/shmem_fs.h>
+#include <linux/hugetlb.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+#include <linux/deferqueue.h>
+
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_shm *h,
+			    struct shmid_kernel *shp)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&shp->shm_perm);
+
+	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+	if (ret < 0)
+		goto unlock;
+
+	h->shm_segsz = shp->shm_segsz;
+	h->shm_atim = shp->shm_atim;
+	h->shm_dtim = shp->shm_dtim;
+	h->shm_ctim = shp->shm_ctim;
+	h->shm_cprid = shp->shm_cprid;
+	h->shm_lprid = shp->shm_lprid;
+
+	if (shp->mlock_user)
+		h->mlock_uid = shp->mlock_user->uid;
+	else
+		h->mlock_uid = (unsigned int) -1;
+
+	h->flags = 0;
+	/* check if shm was setup with SHM_NORESERVE */
+	if (SHMEM_I(shp->shm_file->f_dentry->d_inode)->flags & VM_NORESERVE)
+		h->flags |= SHM_NORESERVE;
+	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
+	if (is_file_hugepages(shp->shm_file)) {
+		pr_warning("c/r: unsupported SHM_HUGETLB\n");
+		ret = -ENOSYS;
+	}
+
+ unlock:
+	ipc_unlock(&shp->shm_perm);
+	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
+
+	return ret;
+}
+
+int checkpoint_ipc_shm(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_shm *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct shmid_kernel *shp;
+	struct inode *inode;
+	int first, objref;
+	int ret;
+
+	shp = container_of(perm, struct shmid_kernel, shm_perm);
+	inode = shp->shm_file->f_dentry->d_inode;
+
+	objref = ckpt_obj_lookup_add(ctx, inode, CKPT_OBJ_INODE, &first);
+	if (objref < 0)
+		return objref;
+	/* this must be the first time we see this region */
+	BUG_ON(!first);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SHM);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_shm_hdr(ctx, h, shp);
+	if (ret < 0)
+		goto out;
+
+	h->objref = objref;
+	ckpt_debug("shm: objref %d\n", h->objref);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_memory_contents(ctx, NULL, inode);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/************************************************************************
+ * ipc restart
+ */
+
+struct dq_ipcshm_del {
+	/*
+	 * XXX: always keep ->ipcns first so that put_ipc_ns() can
+	 * be safely provided as the dtor for this deferqueue object
+	 */
+	struct ipc_namespace *ipcns;
+	int id;
+};
+
+static int ipc_shm_delete(void *data)
+{
+	struct dq_ipcshm_del *dq = (struct dq_ipcshm_del *) data;
+	mm_segment_t old_fs;
+	int ret;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
+	set_fs(old_fs);
+
+	put_ipc_ns(dq->ipcns);
+	return ret;
+}
+
+static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_shm *h,
+			    struct shmid_kernel *shp)
+{
+	int ret;
+
+	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
+
+	if (h->shm_cprid < 0 || h->shm_lprid < 0)
+		return -EINVAL;
+
+	shp->shm_segsz = h->shm_segsz;
+	shp->shm_atim = h->shm_atim;
+	shp->shm_dtim = h->shm_dtim;
+	shp->shm_ctim = h->shm_ctim;
+	shp->shm_cprid = h->shm_cprid;
+	shp->shm_lprid = h->shm_lprid;
+
+	return 0;
+}
+
+int restore_ipc_shm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_shm *h;
+	struct kern_ipc_perm *perms;
+	struct shmid_kernel *shp;
+	struct ipc_ids *shm_ids = &current->nsproxy->ipc_ns->ids[IPC_SHM_IDS];
+	struct file *file;
+	int shmflag;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SHM);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+
+#define CKPT_SHMFL_MASK  (SHM_NORESERVE | SHM_HUGETLB)
+	if (h->flags & ~CKPT_SHMFL_MASK)
+		goto out;
+
+	ret = -ENOSYS;
+	if (h->mlock_uid != (unsigned int) -1)	/* FIXME: support SHM_LOCK */
+		goto out;
+	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
+		goto out;
+
+	/*
+	 * SHM_DEST means that the shm is to be deleted after creation.
+	 * However, deleting before it's actually attached is quite silly.
+	 * Instead, we defer this task to until restart has succeeded.
+	 */
+	if (h->perms.mode & SHM_DEST) {
+		struct dq_ipcshm_del dq;
+
+		/* to not confuse the rest of the code */
+		h->perms.mode &= ~SHM_DEST;
+
+		dq.id = h->perms.id;
+		dq.ipcns = current->nsproxy->ipc_ns;
+		get_ipc_ns(dq.ipcns);
+
+		/* XXX can safely use put_ipc_ns() as dtor, see above */
+		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+				     (deferqueue_func_t) ipc_shm_delete,
+				     (deferqueue_func_t) put_ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
+
+	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
+		 h->shm_segsz, shmflag, h->perms.id);
+	ret = do_shmget(h->perms.key, h->shm_segsz, shmflag, h->perms.id);
+	ckpt_debug("shm: do_shmget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&shm_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(shm_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
+
+	shp = container_of(perms, struct shmid_kernel, shm_perm);
+	file = shp->shm_file;
+	get_file(file);
+
+	ret = load_ipc_shm_hdr(ctx, h, shp);
+	ipc_unlock(perms);
+	if (ret < 0)
+		goto mutex;
+
+	/* deposit in objhash and read contents in */
+	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
+	if (ret < 0)
+		goto mutex;
+	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+ mutex:
+	fput(file);
+	if (ret < 0) {
+		ckpt_debug("shm: need to remove (%d)\n", ret);
+		do_shm_rmid(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&shm_ids->rw_mutex);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/shm.c b/ipc/shm.c
index 8aba22f..0ed6a9d 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -40,6 +40,8 @@
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
 #include <linux/ima.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 
@@ -305,6 +307,74 @@ int is_file_shm_hugepages(struct file *file)
 	return ret;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int ipcshm_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	int ino_objref;
+	int first;
+
+	ino_objref = ckpt_obj_lookup_add(ctx, vma->vm_file->f_dentry->d_inode,
+				       CKPT_OBJ_INODE, &first);
+	if (ino_objref < 0)
+		return ino_objref;
+
+	/*
+	 * This shouldn't happen, because all IPC regions should have
+	 * been already dumped by now via ipc namespaces; It means
+	 * the ipc_ns has been modified recently during checkpoint.
+	 */
+	if (first)
+		return -EBUSY;
+
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_SHM_IPC_SKIP,
+				      0, ino_objref);
+}
+
+int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+		   struct ckpt_hdr_vma *h)
+{
+	struct file *file;
+	int shmid, shmflg = 0;
+	mm_segment_t old_fs;
+	unsigned long start;
+	unsigned long addr;
+	int ret;
+
+	if (!h->ino_objref)
+		return -EINVAL;
+	/* FIX: verify the vm_flags too */
+
+	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file))
+		PTR_ERR(file);
+
+	shmid = file->f_dentry->d_inode->i_ino;
+
+	if (!(h->vm_flags & VM_WRITE))
+		shmflg |= SHM_RDONLY;
+
+	/*
+	 * FIX: do_shmat() has limited interface: all-or-nothing
+	 * mapping. If the vma, however, reflects a partial mapping
+	 * then we need to modify that function to accomplish the
+	 * desired outcome.  Partial mapping can exist due to the user
+	 * call shmat() and then unmapping part of the region.
+	 * Currently, we at least detect this and call it a foul play.
+	 */
+	if (((h->vm_end - h->vm_start) != h->ino_size) || h->vm_pgoff)
+		return -ENOSYS;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	start = h->vm_start;
+	ret = do_shmat(shmid, (char __user *) start, shmflg, &addr);
+	set_fs(old_fs);
+
+	BUG_ON(ret >= 0 && addr != h->vm_start);
+	return ret;
+}
+#endif
+
 static const struct file_operations shm_file_operations = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
@@ -320,6 +390,9 @@ static struct vm_operations_struct shm_vm_ops = {
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
 #endif
+#if defined(CONFIG_CHECKPOINT)
+	.checkpoint = ipcshm_checkpoint,
+#endif
 };
 
 /**
diff --git a/ipc/util.h b/ipc/util.h
index 1356909..5a6373f 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -183,7 +183,9 @@ extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
 extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
-#endif
 
+extern int checkpoint_ipc_shm(int id, void *p, void *data);
+extern int restore_ipc_shm(struct ckpt_ctx *ctx);
+#endif
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
