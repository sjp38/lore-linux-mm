Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C17E06B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 20:36:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v16so2262696wrv.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 17:36:11 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x25si5753073wrc.45.2018.03.07.17.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 17:36:09 -0800 (PST)
Subject: Re: [PATCH] hugetlbfs: check for pgoff value overflow
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180307235923.12469-1-mike.kravetz@oracle.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <8a0863a2-1890-11e0-1fc2-c96e1794e809@huawei.com>
Date: Thu, 8 Mar 2018 09:35:52 +0800
MIME-Version: 1.0
In-Reply-To: <20180307235923.12469-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Nic Losby <blurbdust@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike,

On 2018/3/8 7:59, Mike Kravetz wrote:
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
> Reported-by: Nic Losby <blurbdust@gmail.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 8fe1b0aa2896..cb288dec5564 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -127,12 +127,13 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_ops = &hugetlb_vm_ops;
>  
>  	/*
> -	 * Offset passed to mmap (before page shift) could have been
> -	 * negative when represented as a (l)off_t.
> +	 * page based offset in vm_pgoff could be sufficiently large to
> +	 * overflow a (l)off_t when converted to byte offset.
>  	 */
> -	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +	if (vma->vm_pgoff && ((loff_t)vma->vm_pgoff << PAGE_SHIFT) <= 0)
>  		return -EINVAL;

This seems still no the right fix, taking the following case as an example:
 mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
 remap_file_pages(0x20a00000, 0x600000, 0, 0x0020001000000000, 0);

You should just check the highest PAGE_SHIFT+1 bits of pgoff in you want check
at this point, right?

However, region_chg makes me a litter puzzle that when its return value < 0, sometime
adds_in_progress is added like this case, while sometime it is not. so why not just
change at the beginning of region_chg ?
	if (f > t)
		return -EINVAL;

Thanks
Yisheng
>  
> +	/* must be huge page aligned */
>  	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>  		return -EINVAL;
>  
> 
