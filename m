Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 968166B0006
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:15:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y145so138343wmd.4
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:15:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i89si15555351wri.445.2018.03.08.14.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 14:15:37 -0800 (PST)
Date: Thu, 8 Mar 2018 14:15:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] hugetlbfs: check for pgoff value overflow
Message-Id: <20180308141533.d16e43f5f559215089e522ae@linux-foundation.org>
In-Reply-To: <20180308210502.15952-1-mike.kravetz@oracle.com>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
	<20180308210502.15952-1-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, stable@vger.kernel.org

On Thu,  8 Mar 2018 13:05:02 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

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
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -111,6 +111,7 @@ static void huge_pagevec_release(struct pagevec *pvec)
>  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  {
>  	struct inode *inode = file_inode(file);
> +	unsigned long ovfl_mask;
>  	loff_t len, vma_len;
>  	int ret;
>  	struct hstate *h = hstate_file(file);
> @@ -127,12 +128,16 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_ops = &hugetlb_vm_ops;
>  
>  	/*
> -	 * Offset passed to mmap (before page shift) could have been
> -	 * negative when represented as a (l)off_t.
> +	 * page based offset in vm_pgoff could be sufficiently large to
> +	 * overflow a (l)off_t when converted to byte offset.
>  	 */
> -	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +	ovfl_mask = (1UL << (PAGE_SHIFT + 1)) - 1;
> +	ovfl_mask <<= ((sizeof(unsigned long) * BITS_PER_BYTE) -
> +		       (PAGE_SHIFT + 1));

That's a compile-time constant.  The compiler will indeed generate an
immediate load, but I think it would be better to make the code look
more like we know that it's a constant, if you get what I mean. 
Something like

/*
 * If a pgoff_t is to be converted to a byte index, this is the max value it
 * can have to avoid overflow in that conversion.
 */
#define PGOFF_T_MAX	<long string of crap>

And I bet that this constant could be used elsewhere - surely it's a
very common thing to be checking for.


Also, the expression seems rather complicated.  Why are we adding 1 to
PAGE_SHIFT?  Isn't there a logical way of using PAGE_MASK?

The resulting constant is 0xfff8000000000000 on 64-bit.  We could just
use along the lines of

	1UL << (BITS_PER_LONG - PAGE_SHIFT - 1)

But why the -1?  We should be able to handle a pgoff_t of
0xfff0000000000000 in this code?


Also, we later to

	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
	/* check for overflow */
	if (len < vma_len)
		return -EINVAL;

which is ungainly: even if we passed the PGOFF_T_MAX test, there can
still be an overflow which we still must check for.  Is that avoidable?
Probably not...
