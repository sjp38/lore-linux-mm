Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 139136B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 08:14:51 -0400 (EDT)
Date: Tue, 15 Sep 2009 13:14:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Identification of huge pages mapping (Take 3)
Message-ID: <20090915121456.GB31840@csn.ul.ie>
References: <202cde0e0909132216l79aae251ya3a6685587c7692c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0909132216l79aae251ya3a6685587c7692c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I suggest a subject change to

"Identify huge page mappings from address_space->flags instead of file_operations comparison"

for the purposes of having an easier-to-understand changelog.


On Mon, Sep 14, 2009 at 05:16:13PM +1200, Alexey Korolev wrote:
> This patch changes a little bit the procedures of huge pages file
> identification. We need this because we may have huge page mapping for
> files which are not on hugetlbfs (the same case in ipc/shm.c).

Is this strictly-speaking true as there is still a file on hugetlbfs for
the driver? Maybe something like

This patch identifies whether a mapping uses huge pages based on the
address_space flags instead of the file operations. A later patch allows
a driver to manage an underlying hugetlbfs file while exposing it via a
different file_operations structure.

I haven't read the rest of the series yet so take the suggestion with a
grain of salt.

> Just file operations check will not work as drivers should have own
> file operations. So if we need to identify if file has huge pages
> mapping, we need to check the file mapping flags.
> New identification procedure obsoletes existing workaround for hugetlb
> file identification in ipc/shm.c
> Also having huge page mapping for files which are not on hugetlbfs do
> not allow us to get hstate based on file dentry, we need to be based
> on file mapping instead.
> 

Can you clarify this a bit more? I think the reasoning is as follows but
confirmation would be nice.

"As part of this, the hstate for a given file as implemented by hstate_file()
must be based on file mapping instead of dentry. Even if a driver is
maintaining an underlying hugetlbfs file, the mmap() operation is still
taking place on a device-specific file. That dentry is unlikely to be on
a hugetlbfs file. A device driver must ensure that file->f_mapping->host
resolves correctly."

If this is accurate, a comment in hstate_file() wouldn't hurt in case
someone later decides that dentry really was the way to go.

> fs/hugetlbfs/inode.c    |    1 +
> include/linux/hugetlb.h |   15 ++-------------
> include/linux/pagemap.h |   13 +++++++++++++
> ipc/shm.c               |   12 ------------
> 4 files changed, 16 insertions(+), 25 deletions(-)
> 
> ---
> Signed-off-by: Alexey Korolev <akorolev@infradead.org>
> 
> diff -aurp clean/fs/hugetlbfs/inode.c patched/fs/hugetlbfs/inode.c
> --- clean/fs/hugetlbfs/inode.c	2009-09-10 17:48:38.000000000 +1200
> +++ patched/fs/hugetlbfs/inode.c	2009-09-11 15:12:17.000000000 +1200
> @@ -521,6 +521,7 @@ static struct inode *hugetlbfs_get_inode
>  		case S_IFREG:
>  			inode->i_op = &hugetlbfs_inode_operations;
>  			inode->i_fop = &hugetlbfs_file_operations;
> +			mapping_set_hugetlb(inode->i_mapping);
>  			break;
>  		case S_IFDIR:
>  			inode->i_op = &hugetlbfs_dir_inode_operations;
> diff -aurp clean/include/linux/hugetlb.h patched/include/linux/hugetlb.h
> --- clean/include/linux/hugetlb.h	2009-09-10 17:48:28.000000000 +1200
> +++ patched/include/linux/hugetlb.h	2009-09-11 15:15:30.000000000 +1200
> @@ -169,22 +169,11 @@ void hugetlb_put_quota(struct address_sp
> 
>  static inline int is_file_hugepages(struct file *file)
>  {
> -	if (file->f_op == &hugetlbfs_file_operations)
> -		return 1;
> -	if (is_file_shm_hugepages(file))
> -		return 1;
> -
> -	return 0;
> -}
> -
> -static inline void set_file_hugepages(struct file *file)
> -{
> -	file->f_op = &hugetlbfs_file_operations;
> +	return mapping_hugetlb(file->f_mapping);
>  }
>  #else /* !CONFIG_HUGETLBFS */
> 
>  #define is_file_hugepages(file)			0
> -#define set_file_hugepages(file)		BUG()
>  #define hugetlb_file_setup(name,size,acct,user,creat)	ERR_PTR(-ENOSYS)
> 

Why do you remove this BUG()? It still seems to be a valid check.

>  #endif /* !CONFIG_HUGETLBFS */
> @@ -245,7 +234,7 @@ static inline struct hstate *hstate_inod
> 
>  static inline struct hstate *hstate_file(struct file *f)
>  {
> -	return hstate_inode(f->f_dentry->d_inode);
> +	return hstate_inode(f->f_mapping->host);
>  }
> 
>  static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> diff -aurp clean/include/linux/pagemap.h patched/include/linux/pagemap.h
> --- clean/include/linux/pagemap.h	2009-09-06 11:38:12.000000000 +1200
> +++ patched/include/linux/pagemap.h	2009-09-11 15:17:04.000000000 +1200
> @@ -23,6 +23,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_HUGETLB	= __GFP_BITS_SHIFT + 4,	/* under HUGE TLB */
>  };
> 
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -52,6 +53,18 @@ static inline int mapping_unevictable(st
>  	return !!mapping;
>  }
> 
> +static inline void mapping_set_hugetlb(struct address_space *mapping)
> +{
> +	set_bit(AS_HUGETLB, &mapping->flags);
> +}
> +
> +static inline int mapping_hugetlb(struct address_space *mapping)
> +{
> +	if (likely(mapping))
> +		return test_bit(AS_HUGETLB, &mapping->flags);
> +	return 0;
> +}

Is mapping_hugetlb necessary? Why not just make that the implementation
of is_file_hugepages()

> +
>  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
>  {
>  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> diff -aurp clean/ipc/shm.c patched/ipc/shm.c
> --- clean/ipc/shm.c	2009-09-10 17:48:23.000000000 +1200
> +++ patched/ipc/shm.c	2009-09-11 15:17:04.000000000 +1200
> @@ -293,18 +293,6 @@ static unsigned long shm_get_unmapped_ar
>  	return get_unmapped_area(sfd->file, addr, len, pgoff, flags);
>  }
> 
> -int is_file_shm_hugepages(struct file *file)
> -{
> -	int ret = 0;
> -
> -	if (file->f_op == &shm_file_operations) {
> -		struct shm_file_data *sfd;
> -		sfd = shm_file_data(file);
> -		ret = is_file_hugepages(sfd->file);
> -	}
> -	return ret;
> -}

What about the declarations and definitions in include/linux/shm.h?

> -
>  static const struct file_operations shm_file_operations = {
>  	.mmap		= shm_mmap,
>  	.fsync		= shm_fsync,
> 

Still some ironing to do but I think this part of the series is getting
there.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
