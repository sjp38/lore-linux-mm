Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 93B0D6B00E4
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:07:55 -0400 (EDT)
Date: Mon, 24 Aug 2009 13:27:50 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: fix hugetlb bug due to user_shm_unlock call (fwd)
In-Reply-To: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org>
Message-ID: <Pine.LNX.4.64.0908241258070.27704@sister.anvils>
References: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stefan Huber <shuber2@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Meerwald <pmeerw@cosy.sbg.ac.at>, James Morris <jmorris@namei.org>, William Irwin <wli@movementarian.org>, Mel Gorman <mel@csn.ul.ie>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Aug 2009, Stefan Huber wrote:
> We have recently detected a kernel oops bug in the hugetlb code. The bug
> is still present in the current linux-2.6 git branch (tested until [1]).
> We have attached a 'git format-patch'-file that solved problem for us.
> The commit message should describe the logic of the bug. Please contact
> me if you have further questions or comments.
> 
> Sincerely,
> Stefan Huber.
> 
> [1]  linux/kernel/git/torvalds/linux-2.6.git (commit
>      429966b8f644dda2afddb4f834a944e9b46a7645)

That's a valuable discovery, thank you for reporting it.

However, though I can well believe that your patch works well for you,
I don't think it's general enough: there is no guarantee that the tests
in can_do_hugetlb_shm() will give the same answer to the user who ends
up calling shm_destroy() as it did once upon a time to the user who
called hugetlb_file_setup().

So, please could you try this alternative patch below, to see if it
passes your testing too, and let us know the result?  I'm sure we'd
like to get a fix into 2.6.31, and into 2.6.30-stable.

Thanks,
Hugh


[PATCH] mm: fix hugetlb bug due to user_shm_unlock call

2.6.30's commit 8a0bdec194c21c8fdef840989d0d7b742bb5d4bc removed
user_shm_lock() calls in hugetlb_file_setup() but left the
user_shm_unlock call in shm_destroy().

In detail:
Assume that can_do_hugetlb_shm() returns true and hence user_shm_lock()
is not called in hugetlb_file_setup(). However, user_shm_unlock() is
called in any case in shm_destroy() and in the following
atomic_dec_and_lock(&up->__count) in free_uid() is executed and if
up->__count gets zero, also cleanup_user_struct() is scheduled.

Note that sched_destroy_user() is empty if CONFIG_USER_SCHED is not set.
However, the ref counter up->__count gets unexpectedly non-positive and
the corresponding structs are freed even though there are live
references to them, resulting in a kernel oops after a lots of
shmget(SHM_HUGETLB)/shmctl(IPC_RMID) cycles and CONFIG_USER_SCHED set.

Reported-by: Stefan Huber <shuber2@gmail.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: stable@kernel.org
---

 fs/hugetlbfs/inode.c    |   20 ++++++++++++--------
 include/linux/hugetlb.h |    6 ++++--
 ipc/shm.c               |    6 +++---
 3 files changed, 19 insertions(+), 13 deletions(-)

--- 2.6.31-rc7/fs/hugetlbfs/inode.c	2009-06-25 05:18:06.000000000 +0100
+++ linux/fs/hugetlbfs/inode.c	2009-08-24 12:32:01.000000000 +0100
@@ -935,26 +935,28 @@ static int can_do_hugetlb_shm(void)
 	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
 
-struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
+struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag,
+						struct user_struct **user)
 {
 	int error = -ENOMEM;
-	int unlock_shm = 0;
 	struct file *file;
 	struct inode *inode;
 	struct dentry *dentry, *root;
 	struct qstr quick_string;
-	struct user_struct *user = current_user();
 
+	*user = NULL;
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
 
 	if (!can_do_hugetlb_shm()) {
-		if (user_shm_lock(size, user)) {
-			unlock_shm = 1;
+		*user = current_user();
+		if (user_shm_lock(size, *user)) {
 			WARN_ONCE(1,
 			  "Using mlock ulimits for SHM_HUGETLB deprecated\n");
-		} else
+		} else {
+			*user = NULL;
 			return ERR_PTR(-EPERM);
+		}
 	}
 
 	root = hugetlbfs_vfsmount->mnt_root;
@@ -996,8 +998,10 @@ out_inode:
 out_dentry:
 	dput(dentry);
 out_shm_unlock:
-	if (unlock_shm)
-		user_shm_unlock(size, user);
+	if (*user) {
+		user_shm_unlock(size, *user);
+		*user = NULL;
+	}
 	return ERR_PTR(error);
 }
 
--- 2.6.31-rc7/include/linux/hugetlb.h	2009-06-25 05:18:08.000000000 +0100
+++ linux/include/linux/hugetlb.h	2009-08-24 12:32:01.000000000 +0100
@@ -10,6 +10,7 @@
 #include <asm/tlbflush.h>
 
 struct ctl_table;
+struct user_struct;
 
 int PageHuge(struct page *page);
 
@@ -146,7 +147,8 @@ static inline struct hugetlbfs_sb_info *
 
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t, int);
+struct file *hugetlb_file_setup(const char *name, size_t size, int acct,
+						struct user_struct **user);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
 
@@ -168,7 +170,7 @@ static inline void set_file_hugepages(st
 
 #define is_file_hugepages(file)			0
 #define set_file_hugepages(file)		BUG()
-#define hugetlb_file_setup(name,size,acctflag)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(name,size,acct,user)	ERR_PTR(-ENOSYS)
 
 #endif /* !CONFIG_HUGETLBFS */
 
--- 2.6.31-rc7/ipc/shm.c	2009-06-25 05:18:09.000000000 +0100
+++ linux/ipc/shm.c	2009-08-24 12:32:01.000000000 +0100
@@ -174,7 +174,7 @@ static void shm_destroy(struct ipc_names
 	shm_unlock(shp);
 	if (!is_file_hugepages(shp->shm_file))
 		shmem_lock(shp->shm_file, 0, shp->mlock_user);
-	else
+	else if (shp->mlock_user)
 		user_shm_unlock(shp->shm_file->f_path.dentry->d_inode->i_size,
 						shp->mlock_user);
 	fput (shp->shm_file);
@@ -369,8 +369,8 @@ static int newseg(struct ipc_namespace *
 		/* hugetlb_file_setup applies strict accounting */
 		if (shmflg & SHM_NORESERVE)
 			acctflag = VM_NORESERVE;
-		file = hugetlb_file_setup(name, size, acctflag);
-		shp->mlock_user = current_user();
+		file = hugetlb_file_setup(name, size, acctflag,
+							&shp->mlock_user);
 	} else {
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
