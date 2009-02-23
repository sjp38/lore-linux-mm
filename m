Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 43A576B00D9
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 14:21:12 -0500 (EST)
Date: Mon, 23 Feb 2009 11:21:04 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 1/2] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090223192104.GB27240@localdomain>
References: <20090221015457.GA32674@localdomain> <20090223110404.GA6740@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090223110404.GA6740@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, wli@movementarian.org, linux-mm@kvack.org, shai@scalex86.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 11:04:05AM +0000, Mel Gorman wrote:
>On Fri, Feb 20, 2009 at 05:54:57PM -0800, Ravikiran G Thirumalai wrote:
>> This is a two patch series to fix a long standing inconsistency with the
>> mechanism to allow non root users allocate hugetlb shm.  The patch changelog
>> is self explanatory.  Here's a link to the previous discussion as well:
>> 
>> 	http://lkml.org/lkml/2009/2/10/89
>> 
>
>checkpatch complains about the () around the check being unnecessary.
>Not a big issue though.
>

Hmm! I could have sworn I ran it through checkpatch.pl (usually I do)
but apparently this time I didn't.  Here's the corrected patch.

Thanks,
Kiran

---

Fix hugetlb subsystem so that non root users belonging to hugetlb_shm_group
can actually allocate hugetlb backed shm.

Currently non root users cannot even map one large page using SHM_HUGETLB
when they belong to the gid in /proc/sys/vm/hugetlb_shm_group.
This is because allocation size is verified against RLIMIT_MEMLOCK resource
limit even if the user belongs to hugetlb_shm_group.

This patch
1. Fixes hugetlb subsystem so that users with CAP_IPC_LOCK and users
   belonging to hugetlb_shm_group don't need to be restricted with
   RLIMIT_MEMLOCK resource limits
2. This patch also disables mlock based rlimit checking (which will
   be reinstated and marked deprecated in a subsequent patch).

Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>
Cc: Wli <wli@movementarian.org>

Index: git.tip/fs/hugetlbfs/inode.c
===================================================================
--- git.tip.orig/fs/hugetlbfs/inode.c	2009-02-19 09:47:58.000000000 -0800
+++ git.tip/fs/hugetlbfs/inode.c	2009-02-23 11:09:46.000000000 -0800
@@ -943,9 +943,7 @@ static struct vfsmount *hugetlbfs_vfsmou
 
 static int can_do_hugetlb_shm(void)
 {
-	return likely(capable(CAP_IPC_LOCK) ||
-			in_group_p(sysctl_hugetlb_shm_group) ||
-			can_do_mlock());
+	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
 
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
@@ -963,9 +961,6 @@ struct file *hugetlb_file_setup(const ch
 	if (!can_do_hugetlb_shm())
 		return ERR_PTR(-EPERM);
 
-	if (!user_shm_lock(size, user))
-		return ERR_PTR(-ENOMEM);
-
 	root = hugetlbfs_vfsmount->mnt_root;
 	quick_string.name = name;
 	quick_string.len = strlen(quick_string.name);
@@ -1004,7 +999,6 @@ out_inode:
 out_dentry:
 	dput(dentry);
 out_shm_unlock:
-	user_shm_unlock(size, user);
 	return ERR_PTR(error);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
