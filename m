Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D93BB6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:19:05 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n7EJJ7PK006383
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 12:19:09 -0700
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by spaceape12.eur.corp.google.com with ESMTP id n7EJJ3hA001669
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 12:19:05 -0700
Received: by pxi33 with SMTP id 33so423841pxi.11
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 12:19:03 -0700 (PDT)
Date: Fri, 14 Aug 2009 12:19:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] hugetlbfs: Allow the creation of files suitable for
 MAP_PRIVATE on the vfs internal mount V3
In-Reply-To: <d2e4f6625a147c1ef6cb26de66849875f57a8155.1250258125.git.ebmunson@us.ibm.com>
Message-ID: <alpine.DEB.2.00.0908141218230.12472@chino.kir.corp.google.com>
References: <cover.1250258125.git.ebmunson@us.ibm.com> <d2e4f6625a147c1ef6cb26de66849875f57a8155.1250258125.git.ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009, Eric B Munson wrote:

> There are two means of creating mappings backed by huge pages:
> 
>         1. mmap() a file created on hugetlbfs
>         2. Use shm which creates a file on an internal mount which essentially
>            maps it MAP_SHARED
> 
> The internal mount is only used for shared mappings but there is very
> little that stops it being used for private mappings. This patch extends
> hugetlbfs_file_setup() to deal with the creation of files that will be
> mapped MAP_PRIVATE on the internal hugetlbfs mount. This extended API is
> used in a subsequent patch to implement the MAP_HUGETLB mmap() flag.
> 
> Signed-off-by: Eric Munson <ebmunson@us.ibm.com>
> ---
> Changes from V2:
>  Rebase to newest linux-2.6 tree
>  Use base 10 value for HUGETLB_SHMFS_INODE instead of hex
> 
> Changes from V1:
>  Rebase to newest linux-2.6 tree
> 
>  fs/hugetlbfs/inode.c    |   22 ++++++++++++++++++----
>  include/linux/hugetlb.h |   10 +++++++++-
>  ipc/shm.c               |    3 ++-
>  3 files changed, 29 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 941c842..361f536 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -506,6 +506,13 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		INIT_LIST_HEAD(&inode->i_mapping->private_list);
>  		info = HUGETLBFS_I(inode);
> +		/*
> +		 * The policy is initialized here even if we are creating a
> +		 * private inode because initialization simply creates an
> +		 * an empty rb tree and calls spin_lock_init(), later when we
> +		 * call mpol_free_shared_policy() it will just return because
> +		 * the rb tree will still be empty.
> +		 */
>  		mpol_shared_policy_init(&info->policy, NULL);
>  		switch (mode & S_IFMT) {
>  		default:
> @@ -930,12 +937,19 @@ static struct file_system_type hugetlbfs_fs_type = {
>  
>  static struct vfsmount *hugetlbfs_vfsmount;
>  
> -static int can_do_hugetlb_shm(void)
> +static int can_do_hugetlb_shm(int creat_flags)
>  {
> -	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
> +	if (!(creat_flags & HUGETLB_SHMFS_INODE))
> +		return 0;

That should be

	if (creat_flags != HUGETLB_SHMFS_INODE)
		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
