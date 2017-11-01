Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1081C6B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 19:45:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b85so3435886pfj.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 16:45:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a26si2118914pgd.582.2017.11.01.16.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 16:44:59 -0700 (PDT)
Subject: Re: [PATCH 4/6] hugetlbfs: implement memfd sealing
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-5-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <622e8bf4-e5bf-be2f-2af2-7a2f7057e912@oracle.com>
Date: Wed, 1 Nov 2017 16:44:51 -0700
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-5-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
> Implements memfd sealing, similar to shmem:
> - WRITE: deny fallocate(PUNCH_HOLE). mmap() write is denied in
>   memfd_add_seals(). write() doesn't exist for hugetlbfs.
> - SHRINK: added similar check as shmem_setattr()
> - GROW: added similar check as shmem_setattr() & shmem_fallocate()
> 
> Except write() operation that doesn't exist with hugetlbfs, that
> should make sealing as close as it can be to shmem support.
> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>

Looks fine to me,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
>  fs/hugetlbfs/inode.c    | 29 +++++++++++++++++++++++++++--
>  include/linux/hugetlb.h |  1 +
>  2 files changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index ea7b10357ac4..62d70b1b1ab9 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -510,8 +510,16 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>  
>  	if (hole_end > hole_start) {
>  		struct address_space *mapping = inode->i_mapping;
> +		struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
>  
>  		inode_lock(inode);
> +
> +		/* protected by i_mutex */
> +		if (info->seals & F_SEAL_WRITE) {
> +			inode_unlock(inode);
> +			return -EPERM;
> +		}
> +
>  		i_mmap_lock_write(mapping);
>  		if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
>  			hugetlb_vmdelete_list(&mapping->i_mmap,
> @@ -529,6 +537,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>  				loff_t len)
>  {
>  	struct inode *inode = file_inode(file);
> +	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
>  	struct address_space *mapping = inode->i_mapping;
>  	struct hstate *h = hstate_inode(inode);
>  	struct vm_area_struct pseudo_vma;
> @@ -560,6 +569,11 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>  	if (error)
>  		goto out;
>  
> +	if ((info->seals & F_SEAL_GROW) && offset + len > inode->i_size) {
> +		error = -EPERM;
> +		goto out;
> +	}
> +
>  	/*
>  	 * Initialize a pseudo vma as this is required by the huge page
>  	 * allocation routines.  If NUMA is configured, use page index
> @@ -650,6 +664,7 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
>  	struct hstate *h = hstate_inode(inode);
>  	int error;
>  	unsigned int ia_valid = attr->ia_valid;
> +	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
>  
>  	BUG_ON(!inode);
>  
> @@ -658,10 +673,17 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
>  		return error;
>  
>  	if (ia_valid & ATTR_SIZE) {
> +		loff_t oldsize = inode->i_size;
> +		loff_t newsize = attr->ia_size;
> +
>  		error = -EINVAL;
> -		if (attr->ia_size & ~huge_page_mask(h))
> +		if (newsize & ~huge_page_mask(h))
>  			return -EINVAL;
> -		error = hugetlb_vmtruncate(inode, attr->ia_size);
> +		/* protected by i_mutex */
> +		if ((newsize < oldsize && (info->seals & F_SEAL_SHRINK)) ||
> +		    (newsize > oldsize && (info->seals & F_SEAL_GROW)))
> +			return -EPERM;
> +		error = hugetlb_vmtruncate(inode, newsize);
>  		if (error)
>  			return error;
>  	}
> @@ -713,6 +735,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  
>  	inode = new_inode(sb);
>  	if (inode) {
> +		struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
> +
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
>  		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
> @@ -720,6 +744,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  		inode->i_mapping->a_ops = &hugetlbfs_aops;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
>  		inode->i_mapping->private_data = resv_map;
> +		info->seals = F_SEAL_SEAL;
>  		switch (mode & S_IFMT) {
>  		default:
>  			init_special_inode(inode, mode, dev);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index f78daf54897d..128ef10902f3 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -281,6 +281,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
>  struct hugetlbfs_inode_info {
>  	struct shared_policy policy;
>  	struct inode vfs_inode;
> +	unsigned int seals;
>  };
>  
>  static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
