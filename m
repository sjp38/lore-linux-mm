Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97AC76B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:58:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t189so1300194wmt.9
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:58:11 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id o80si7120279wmi.72.2017.04.12.01.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 01:58:10 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id l28so3153208wre.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:58:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Wed, 12 Apr 2017 10:58:08 +0200
Message-ID: <CAOMGZ=FmjHrN_Nci_mRWiyqnMRKi12hT1CMi2kp62ip=NtpwTg@mail.gmail.com>
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On 12 April 2017 at 00:51, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> If mmap() maps a file, it can be passed an offset into the file at
> which the mapping is to start.  Offset could be a negative value when
> represented as a loff_t.  The offset plus length will be used to
> update the file size (i_size) which is also a loff_t.  Validate the
> value of offset and offset + length to make sure they do not overflow
> and appear as negative.
>
> Found by syzcaller with commit ff8c0c53c475 ("mm/hugetlb.c: don't call
> region_abort if region_chg fails") applied.  Prior to this commit, the
> overflow would still occur but we would luckily return ENOMEM.
> To reproduce:
> mmap(0, 0x2000, 0, 0x40021, 0xffffffffffffffffULL, 0x8000000000000000ULL);
>
> Resulted in,
> kernel BUG at mm/hugetlb.c:742!
> Call Trace:
>  hugetlbfs_evict_inode+0x80/0xa0
>  ? hugetlbfs_setattr+0x3c0/0x3c0
>  evict+0x24a/0x620
>  iput+0x48f/0x8c0
>  dentry_unlink_inode+0x31f/0x4d0
>  __dentry_kill+0x292/0x5e0
>  dput+0x730/0x830
>  __fput+0x438/0x720
>  ____fput+0x1a/0x20
>  task_work_run+0xfe/0x180
>  exit_to_usermode_loop+0x133/0x150
>  syscall_return_slowpath+0x184/0x1c0
>  entry_SYSCALL_64_fastpath+0xab/0xad
>
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>

Please use <vegard.nossum@oracle.com> if possible :-)

> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 7163fe0..dde8613 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>         vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
>         vma->vm_ops = &hugetlb_vm_ops;
>
> +       /*
> +        * Offset passed to mmap (before page shift) could have been
> +        * negative when represented as a (l)off_t.
> +        */
> +       if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +               return -EINVAL;
> +

This is strictly speaking undefined behaviour in C and would get
flagged by e.g. UBSAN. The kernel does compile with
-fno-strict-overflow when supported, though, so maybe it's more of a
theoretical issue.

Another thing: wouldn't we want to detect all truncations, not just
the ones that happen to end up negative?

For example (with -fno-strict-overflow), (0x12345678 << 12) ==
0x45678000, which is still a positive integer, but obviously
truncated.

We can easily avoid the UB by moving the cast out (since ->vm_pgoff is
unsigned and unsigned shifts are always defined IIRC), but that still
doesn't reliably detect the positive-result truncation/overflow.

>         if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>                 return -EINVAL;
>
>         vma_len = (loff_t)(vma->vm_end - vma->vm_start);
> +       len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +       /* check for overflow */
> +       if (len < vma_len)
> +               return -EINVAL;

Also strictly speaking UB. You can avoid it by casting vma_len to
unsigned and dropping the loff_t cast, but it's admittedly somewhat
verbose. There also isn't an "unsigned loff_t" AFAIK, but don't we
have some helpers to safely check for overflows? Surely this isn't the
only place that does loff_t arithmetic.

>
>         inode_lock(inode);
>         file_accessed(file);
>
>         ret = -ENOMEM;
> -       len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> -
>         if (hugetlb_reserve_pages(inode,
>                                 vma->vm_pgoff >> huge_page_order(h),
>                                 len >> huge_page_shift(h), vma,
> @@ -155,7 +164,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>
>         ret = 0;
>         if (vma->vm_flags & VM_WRITE && inode->i_size < len)
> -               inode->i_size = len;
> +               i_size_write(inode, len);
>  out:
>         inode_unlock(inode);

This hunk seems a bit out of place in the sense that I don't see how
it relates to the overflow checking. I think this either belongs in a
separate patch or it deserves a mention in the changelog.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
