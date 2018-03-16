Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1C366B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:18:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u188so4882868pfb.6
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 03:18:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j12si4825754pgn.770.2018.03.16.03.18.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 03:18:01 -0700 (PDT)
Date: Fri, 16 Mar 2018 11:17:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] hugetlbfs: check for pgoff value overflow
Message-ID: <20180316101757.GE23100@dhcp22.suse.cz>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180309002726.7248-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180309002726.7248-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Thu 08-03-18 16:27:26, Mike Kravetz wrote:
> A vma with vm_pgoff large enough to overflow a loff_t type when
> converted to a byte offset can be passed via the remap_file_pages
> system call.  The hugetlbfs mmap routine uses the byte offset to
> calculate reservations and file size.
> 
> A sequence such as:
>   mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
>   remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);
> will result in the following when task exits/file closed,
>   kernel BUG at mm/hugetlb.c:749!
> Call Trace:
>   hugetlbfs_evict_inode+0x2f/0x40
>   evict+0xcb/0x190
>   __dentry_kill+0xcb/0x150
>   __fput+0x164/0x1e0
>   task_work_run+0x84/0xa0
>   exit_to_usermode_loop+0x7d/0x80
>   do_syscall_64+0x18b/0x190
>   entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> 
> The overflowed pgoff value causes hugetlbfs to try to set up a
> mapping with a negative range (end < start) that leaves invalid
> state which causes the BUG.
> 
> The previous overflow fix to this code was incomplete and did not
> take the remap_file_pages system call into account.
> 
> Fixes: 045c7a3f53d9 ("hugetlbfs: fix offset overflow in hugetlbfs mmap")
> Cc: <stable@vger.kernel.org>
> Reported-by: Nic Losby <blurbdust@gmail.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

OK, looks good to me. Hairy but seems to be the easiest way around this.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changes in v3
>   * Use a simpler mask computation as suggested by Andrew Morton
> Changes in v2
>   * Use bitmask for overflow check as suggested by Yisheng Xie
>   * Add explicit (from > to) check when setting up reservations
>   * Cc stable
> 
>  fs/hugetlbfs/inode.c | 16 +++++++++++++---
>  mm/hugetlb.c         |  6 ++++++
>  2 files changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 8fe1b0aa2896..e46117dc006a 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -108,6 +108,15 @@ static void huge_pagevec_release(struct pagevec *pvec)
>  	pagevec_reinit(pvec);
>  }
>  
> +/*
> + * Mask used when checking the page offset value passed in via system
> + * calls.  This value will be converted to a loff_t which is signed.
> + * Therefore, we want to check the upper PAGE_SHIFT + 1 bits of the
> + * value.  The extra bit (- 1 in the shift value) is to take the sign
> + * bit into account.
> + */
> +#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
> +
>  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  {
>  	struct inode *inode = file_inode(file);
> @@ -127,12 +136,13 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_ops = &hugetlb_vm_ops;
>  
>  	/*
> -	 * Offset passed to mmap (before page shift) could have been
> -	 * negative when represented as a (l)off_t.
> +	 * page based offset in vm_pgoff could be sufficiently large to
> +	 * overflow a (l)off_t when converted to byte offset.
>  	 */
> -	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +	if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
>  		return -EINVAL;
>  
> +	/* must be huge page aligned */
>  	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>  		return -EINVAL;
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7c204e3d132b..8eeade0a0b7a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4374,6 +4374,12 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	struct resv_map *resv_map;
>  	long gbl_reserve;
>  
> +	/* This should never happen */
> +	if (from > to) {
> +		VM_WARN(1, "%s called with a negative range\n", __func__);
> +		return -EINVAL;
> +	}
> +
>  	/*
>  	 * Only apply hugepage reservation if asked. At fault time, an
>  	 * attempt will be made for VM_NORESERVE to allocate a page
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs
