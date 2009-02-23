Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA2856B0092
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 06:22:02 -0500 (EST)
Date: Mon, 23 Feb 2009 11:21:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 2/2] mm: Reintroduce and deprecate rlimit based access
	for SHM_HUGETLB
Message-ID: <20090223112156.GB6740@csn.ul.ie>
References: <20090221015457.GA32674@localdomain> <20090221015748.GB32674@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090221015748.GB32674@localdomain>
Sender: owner-linux-mm@kvack.org
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: akpm@linux-foundation.org, wli@movementarian.org, linux-mm@kvack.org, shai@scalex86.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 20, 2009 at 05:57:48PM -0800, Ravikiran G Thirumalai wrote:
> Allow non root users with sufficient mlock rlimits to be able to allocate
> hugetlb backed shm for now.  Deprecate this though.  This is being
> deprecated because the mlock based rlimit checks for SHM_HUGETLB
> is not consistent with mmap based huge page allocations.
> 
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wli <wli@movementarian.org>
> 
> Index: linux-2.6-tip/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux-2.6-tip.orig/fs/hugetlbfs/inode.c	2009-02-10 13:30:05.000000000 -0800
> +++ linux-2.6-tip/fs/hugetlbfs/inode.c	2009-02-11 21:58:23.000000000 -0800
> @@ -948,6 +948,7 @@ static int can_do_hugetlb_shm(void)
>  struct file *hugetlb_file_setup(const char *name, size_t size)
>  {
>  	int error = -ENOMEM;
> +	int unlock_shm = 0;
>  	struct file *file;
>  	struct inode *inode;
>  	struct dentry *dentry, *root;
> @@ -957,8 +958,14 @@ struct file *hugetlb_file_setup(const ch
>  	if (!hugetlbfs_vfsmount)
>  		return ERR_PTR(-ENOENT);
>  
> -	if (!can_do_hugetlb_shm())
> -		return ERR_PTR(-EPERM);
> +	if (!can_do_hugetlb_shm()) {
> +		if (user_shm_lock(size, user)) {
> +			unlock_shm = 1;
> +			WARN_ONCE(1,
> +			  "Using mlock ulimits for SHM_HUGETLB deprecated\n");
> +		} else
> +			return ERR_PTR(-EPERM);
> +	}
>  

Seems to do what is promised by the patch and basic tests worked out for
me. I think the behaviour has changed slightly in that we are getting EPERM
now where we might have seen ENOMEM before but that should be ok.

>  	root = hugetlbfs_vfsmount->mnt_root;
>  	quick_string.name = name;
> @@ -997,6 +1004,8 @@ out_inode:
>  out_dentry:
>  	dput(dentry);
>  out_shm_unlock:
> +	if (unlock_shm)
> +		user_shm_unlock(size, user);
>  	return ERR_PTR(error);
>  }
>  
> Index: linux-2.6-tip/Documentation/feature-removal-schedule.txt
> ===================================================================
> --- linux-2.6-tip.orig/Documentation/feature-removal-schedule.txt	2009-02-09 16:45:47.000000000 -0800
> +++ linux-2.6-tip/Documentation/feature-removal-schedule.txt	2009-02-11 21:35:28.000000000 -0800
> @@ -335,3 +335,14 @@ Why:	In 2.6.18 the Secmark concept was i
>  	Secmark, it is time to deprecate the older mechanism and start the
>  	process of removing the old code.
>  Who:	Paul Moore <paul.moore@hp.com>
> +---------------------------
> +
> +What:	Ability for non root users to shm_get hugetlb pages based on mlock
> +	resource limits
> +When:	2.6.31
> +Why:	Non root users need to be part of /proc/sys/vm/hugetlb_shm_group or
> +	have CAP_IPC_LOCK to be able to allocate shm segments backed by
> +	huge pages.  The mlock based rlimit check to allow shm hugetlb is
> +	inconsistent with mmap based allocations.  Hence it is being
> +	deprecated.
> +Who:	Ravikiran Thirumalai <kiran@scalex86.org>
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
