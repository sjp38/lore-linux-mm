Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by caduceus.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h17Lhs016306
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 21:43:59 GMT
Received: from fmsmsxv040-1.fm.intel.com (fmsmsxvs040.fm.intel.com [132.233.42.124])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h17Lpbq20835
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 21:51:37 GMT
content-class: urn:content-classes:message
Subject: RE: hugepage patches
Date: Fri, 7 Feb 2003 13:49:48 -0800
Message-ID: <6315617889C99D4BA7C14687DEC8DB4E023D2E6C@fmsmsx402.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, davem@redhat.com, "Seth, Rohit" <rohit.seth@intel.com>, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

New allocation of hugepages is an atomic operation.  Partial allocations
of hugepages is not a possibility.  Agree with the initial bug report
though that i_size could be getting mistakenly updated.  Please apply
this patch instead.

thanks,
rohit

--- fs/hugetlbfs/inode.c.7      Fri Feb  7 13:47:39 2003
+++ fs/hugetlbfs/inode.c        Fri Feb  7 13:48:17 2003
@@ -66,7 +66,7 @@
        vma->vm_ops = &hugetlb_vm_ops;
        ret = hugetlb_prefault(mapping, vma);
        len = (vma->vm_end - vma->vm_start) + (vma->vm_pgoff <<
PAGE_SHIFT);
-       if (inode->i_size < len)
+       if (!ret && (inode->i_size < len))
                inode->i_size = len;
 
        up(&inode->i_sem);

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@digeo.com] 
> Sent: Sunday, February 02, 2003 2:56 AM
> To: davem@redhat.com; rohit.seth@intel.com; 
> davidm@napali.hpl.hp.com; anton@samba.org; 
> wli@holomorphy.com; linux-mm@kvack.org
> Subject: Re: hugepage patches
> 
> 
> 7/4
> 
> hugetlbfs i_size fixes
> 
> 
> We're expanding hugetlbfs i_size in the wrong place.  If 
> someone attempts to mmap more pages than are available, 
> i_size is updated to reflect the attempted mapping size.
> 
> So set i_size only when pages are successfully added to the mapping.
> 
> i_size handling at truncate time is still a bit wrong - if 
> the mapping has pages at (say) page offset 100-200 and the 
> mappng is truncated to (say_ page offset 50, i_size should be 
> set to zero.  But it is instead set to 50*HPAGE_SIZE.  That's 
> harmless.
> 
> 
>  i386/mm/hugetlbpage.c    |    5 +++++
>  ia64/mm/hugetlbpage.c    |    0 
>  sparc64/mm/hugetlbpage.c |    0 
>  x86_64/mm/hugetlbpage.c  |    6 ++++++
>  hugetlbfs/inode.c        |    5 -----
>  5 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff -puN fs/hugetlbfs/inode.c~hugetlbfs-i_size-fix 
> fs/hugetlbfs/inode.c
> --- 25/fs/hugetlbfs/inode.c~hugetlbfs-i_size-fix	
> 2003-02-01 02:07:22.000000000 -0800
> +++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-01 
> 02:07:22.000000000 -0800
> @@ -45,7 +45,6 @@ static int hugetlbfs_file_mmap(struct fi
>  {
>  	struct inode *inode =file->f_dentry->d_inode;
>  	struct address_space *mapping = inode->i_mapping;
> -	size_t len;
>  	int ret;
>  
>  	if (!capable(CAP_IPC_LOCK))
> @@ -66,10 +65,6 @@ static int hugetlbfs_file_mmap(struct fi
>  	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
>  	vma->vm_ops = &hugetlb_vm_ops;
>  	ret = hugetlb_prefault(mapping, vma);
> -	len = (vma->vm_end - vma->vm_start) + (vma->vm_pgoff << 
> PAGE_SHIFT);
> -	if (inode->i_size < len)
> -		inode->i_size = len;
> -
>  	up(&inode->i_sem);
>  	return ret;
>  }
> diff -puN arch/i386/mm/hugetlbpage.c~hugetlbfs-i_size-fix 
> arch/i386/mm/hugetlbpage.c
> --- 25/arch/i386/mm/hugetlbpage.c~hugetlbfs-i_size-fix	
> 2003-02-01 02:07:22.000000000 -0800
> +++ 25-akpm/arch/i386/mm/hugetlbpage.c	2003-02-01 
> 02:07:22.000000000 -0800
> @@ -284,6 +284,7 @@ void zap_hugepage_range(struct vm_area_s  
> int hugetlb_prefault(struct address_space *mapping, struct 
> vm_area_struct *vma)  {
>  	struct mm_struct *mm = current->mm;
> +	struct inode *inode = mapping->host;
>  	unsigned long addr;
>  	int ret = 0;
>  
> @@ -307,6 +308,7 @@ int hugetlb_prefault(struct address_spac
>  			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
>  		page = find_get_page(mapping, idx);
>  		if (!page) {
> +			loff_t i_size;
>  			page = alloc_hugetlb_page();
>  			if (!page) {
>  				ret = -ENOMEM;
> @@ -318,6 +320,9 @@ int hugetlb_prefault(struct address_spac
>  				free_huge_page(page);
>  				goto out;
>  			}
> +			i_size = (loff_t)(idx + 1) * HPAGE_SIZE;
> +			if (i_size > inode->i_size)
> +				inode->i_size = i_size;
>  		}
>  		set_huge_pte(mm, vma, page, pte, vma->vm_flags 
> & VM_WRITE);
>  	}
> diff -puN arch/ia64/mm/hugetlbpage.c~hugetlbfs-i_size-fix 
> arch/ia64/mm/hugetlbpage.c diff -puN 
> arch/sparc64/mm/hugetlbpage.c~hugetlbfs-i_size-fix 
> arch/sparc64/mm/hugetlbpage.c diff -puN 
> arch/x86_64/mm/hugetlbpage.c~hugetlbfs-i_size-fix 
> arch/x86_64/mm/hugetlbpage.c
> --- 25/arch/x86_64/mm/hugetlbpage.c~hugetlbfs-i_size-fix	
> 2003-02-01 02:07:22.000000000 -0800
> +++ 25-akpm/arch/x86_64/mm/hugetlbpage.c	2003-02-01 
> 02:07:22.000000000 -0800
> @@ -205,6 +205,7 @@ void zap_hugepage_range(struct vm_area_s  
> int hugetlb_prefault(struct address_space *mapping, struct 
> vm_area_struct *vma)  {
>  	struct mm_struct *mm = current->mm;
> +	struct inode = mapping->host;
>  	unsigned long addr;
>  	int ret = 0;
>  
> @@ -228,6 +229,8 @@ int hugetlb_prefault(struct address_spac
>  			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
>  		page = find_get_page(mapping, idx);
>  		if (!page) {
> +			loff_t i_size;
> +
>  			page = alloc_hugetlb_page();
>  			if (!page) {
>  				ret = -ENOMEM;
> @@ -239,6 +242,9 @@ int hugetlb_prefault(struct address_spac
>  				free_huge_page(page);
>  				goto out;
>  			}
> +			i_size = (loff_t)(idx + 1) * HPAGE_SIZE;
> +			if (i_size > inode->i_size)
> +				inode->i_size = i_size;
>  		}
>  		set_huge_pte(mm, vma, page, pte, vma->vm_flags 
> & VM_WRITE);
>  	}
> 
> _
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
