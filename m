Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A76E76B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 16:11:31 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c130so33537254ioe.19
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 13:11:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g204si22102455ioe.207.2017.04.12.13.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 13:11:30 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
 <CAOMGZ=FmjHrN_Nci_mRWiyqnMRKi12hT1CMi2kp62ip=NtpwTg@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5528ecca-5d36-bf25-77d5-802ef9a234cc@oracle.com>
Date: Wed, 12 Apr 2017 13:04:50 -0700
MIME-Version: 1.0
In-Reply-To: <CAOMGZ=FmjHrN_Nci_mRWiyqnMRKi12hT1CMi2kp62ip=NtpwTg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/12/2017 01:58 AM, Vegard Nossum wrote:
> On 12 April 2017 at 00:51, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>> If mmap() maps a file, it can be passed an offset into the file at
>> which the mapping is to start.  Offset could be a negative value when
>> represented as a loff_t.  The offset plus length will be used to
>> update the file size (i_size) which is also a loff_t.  Validate the
>> value of offset and offset + length to make sure they do not overflow
>> and appear as negative.
>>
>> Found by syzcaller with commit ff8c0c53c475 ("mm/hugetlb.c: don't call
>> region_abort if region_chg fails") applied.  Prior to this commit, the
>> overflow would still occur but we would luckily return ENOMEM.
>> To reproduce:
>> mmap(0, 0x2000, 0, 0x40021, 0xffffffffffffffffULL, 0x8000000000000000ULL);
>>
>> Resulted in,
>> kernel BUG at mm/hugetlb.c:742!
>> Call Trace:
>>  hugetlbfs_evict_inode+0x80/0xa0
>>  ? hugetlbfs_setattr+0x3c0/0x3c0
>>  evict+0x24a/0x620
>>  iput+0x48f/0x8c0
>>  dentry_unlink_inode+0x31f/0x4d0
>>  __dentry_kill+0x292/0x5e0
>>  dput+0x730/0x830
>>  __fput+0x438/0x720
>>  ____fput+0x1a/0x20
>>  task_work_run+0xfe/0x180
>>  exit_to_usermode_loop+0x133/0x150
>>  syscall_return_slowpath+0x184/0x1c0
>>  entry_SYSCALL_64_fastpath+0xab/0xad
>>
>> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> 
> Please use <vegard.nossum@oracle.com> if possible :-)
> 
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 15 ++++++++++++---
>>  1 file changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 7163fe0..dde8613 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>         vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
>>         vma->vm_ops = &hugetlb_vm_ops;
>>
>> +       /*
>> +        * Offset passed to mmap (before page shift) could have been
>> +        * negative when represented as a (l)off_t.
>> +        */
>> +       if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
>> +               return -EINVAL;
>> +
> 
> This is strictly speaking undefined behaviour in C and would get
> flagged by e.g. UBSAN. The kernel does compile with
> -fno-strict-overflow when supported, though, so maybe it's more of a
> theoretical issue.
> 
> Another thing: wouldn't we want to detect all truncations, not just
> the ones that happen to end up negative?
> 
> For example (with -fno-strict-overflow), (0x12345678 << 12) ==
> 0x45678000, which is still a positive integer, but obviously
> truncated.
> 
> We can easily avoid the UB by moving the cast out (since ->vm_pgoff is
> unsigned and unsigned shifts are always defined IIRC), but that still
> doesn't reliably detect the positive-result truncation/overflow.

The value in vm_pgoff was indirectly provided by the user.  This is the
'off_t offset' value provided in the mmap system call.  Before, getting
to this hugetlbfs mmap routine the value is shifted right (>> PAGE_SHIFT)
so that the value in bytes provided by the user is converted to a page
offset.  This shift right is done with an unsigned type so there is no
sign extension.  As a result, I do not think we have to worry about
anything but the negative check here.  Let me know if my thinking is
not valid.

As for the undefined behavior, I guess we can do the shift on the unsigned
type and then cast to loff_t.  The reason for using loff_t is that this
value may eventually be used in the calculation of a value assigned to
i_size which is of this type.

In the patch, I just used the same cast/assignment that previously existed
in the code.  It could be changed to,

if (((loff_t)(vma->vm_pgoff << PAGE_SHIFT)) < 0)

>>         if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>>                 return -EINVAL;
>>
>>         vma_len = (loff_t)(vma->vm_end - vma->vm_start);
>> +       len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>> +       /* check for overflow */
>> +       if (len < vma_len)
>> +               return -EINVAL;
> 
> Also strictly speaking UB. You can avoid it by casting vma_len to
> unsigned and dropping the loff_t cast, but it's admittedly somewhat
> verbose. There also isn't an "unsigned loff_t" AFAIK, but don't we
> have some helpers to safely check for overflows? Surely this isn't the
> only place that does loff_t arithmetic.

I came up empty in my search for helpers.  Actually, I spent more time
trying to figure out how this was handled in other filesystems.  Then I
quickly discovered that hugetlbfs is 'special' and appears to be the
only one which has to deal with this situation.

The only 'similar code' is in the vfs layer when the offset argument to
fallocate is validated.  There it is a simple check for negative value.

I am not sure if it make much sense to eliminate the shifting of signed
values in this patch.  Certainly, this is strictly UB as you say.  But,
after calculating these values the loff_t values are once again shifted
only a few lines later.  I'm afraid this happens is several places in
this code.

>>
>>         inode_lock(inode);
>>         file_accessed(file);
>>
>>         ret = -ENOMEM;
>> -       len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>> -
>>         if (hugetlb_reserve_pages(inode,
>>                                 vma->vm_pgoff >> huge_page_order(h),
>>                                 len >> huge_page_shift(h), vma,
>> @@ -155,7 +164,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>
>>         ret = 0;
>>         if (vma->vm_flags & VM_WRITE && inode->i_size < len)
>> -               inode->i_size = len;
>> +               i_size_write(inode, len);
>>  out:
>>         inode_unlock(inode);
> 
> This hunk seems a bit out of place in the sense that I don't see how
> it relates to the overflow checking. I think this either belongs in a
> separate patch or it deserves a mention in the changelog.

When looking at this bug, I was really concerned that i_size might be set
to a negative value.  It was my hope that the helper routine inode_newsize_ok
would validate the value, but it does not.  I left in the use of this helper,
since the code was already being changed.  I can change as people see fit.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
