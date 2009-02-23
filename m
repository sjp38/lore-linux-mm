Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAF66B0089
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 06:04:10 -0500 (EST)
Date: Mon, 23 Feb 2009 11:04:05 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 1/2] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090223110404.GA6740@csn.ul.ie>
References: <20090221015457.GA32674@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090221015457.GA32674@localdomain>
Sender: owner-linux-mm@kvack.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: akpm@linux-foundation.org, wli@movementarian.org, linux-mm@kvack.org, shai@scalex86.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 20, 2009 at 05:54:57PM -0800, Ravikiran G Thirumalai wrote:
> This is a two patch series to fix a long standing inconsistency with the
> mechanism to allow non root users allocate hugetlb shm.  The patch changelog
> is self explanatory.  Here's a link to the previous discussion as well:
> 
> 	http://lkml.org/lkml/2009/2/10/89
> 
> ---
> Fix hugetlb subsystem so that non root users belonging to hugetlb_shm_group
> can actually allocate hugetlb backed shm.
> 
> Currently non root users cannot even map one large page using SHM_HUGETLB
> when they belong to the gid in /proc/sys/vm/hugetlb_shm_group.
> This is because allocation size is verified against RLIMIT_MEMLOCK resource
> limit even if the user belongs to hugetlb_shm_group.
> 
> This patch
> 1. Fixes hugetlb subsystem so that users with CAP_IPC_LOCK and users
>    belonging to hugetlb_shm_group don't need to be restricted with
>    RLIMIT_MEMLOCK resource limits
> 2. This patch also disables mlock based rlimit checking (which will
>    be reinstated and marked deprecated in a subsequent patch).
> 
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wli <wli@movementarian.org>
> 
> Index: linux-2.6-tip/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux-2.6-tip.orig/fs/hugetlbfs/inode.c	2009-02-10 13:24:56.000000000 -0800
> +++ linux-2.6-tip/fs/hugetlbfs/inode.c	2009-02-10 13:30:05.000000000 -0800
> @@ -942,9 +942,7 @@ static struct vfsmount *hugetlbfs_vfsmou
>  
>  static int can_do_hugetlb_shm(void)
>  {
> -	return likely(capable(CAP_IPC_LOCK) ||
> -			in_group_p(sysctl_hugetlb_shm_group) ||
> -			can_do_mlock());
> +	return (capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group));
>  }
>  

checkpatch complains about the () around the check being unnecessary.
Not a big issue though.

>  struct file *hugetlb_file_setup(const char *name, size_t size)
> @@ -962,9 +960,6 @@ struct file *hugetlb_file_setup(const ch
>  	if (!can_do_hugetlb_shm())
>  		return ERR_PTR(-EPERM);
>  
> -	if (!user_shm_lock(size, user))
> -		return ERR_PTR(-ENOMEM);
> -
>  	root = hugetlbfs_vfsmount->mnt_root;
>  	quick_string.name = name;
>  	quick_string.len = strlen(quick_string.name);
> @@ -1002,7 +997,6 @@ out_inode:
>  out_dentry:
>  	dput(dentry);
>  out_shm_unlock:
> -	user_shm_unlock(size, user);
>  	return ERR_PTR(error);
>  }
>  

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
