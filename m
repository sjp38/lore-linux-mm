Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 683376B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 23:25:31 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id m37so4450856iti.9
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 20:25:31 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p133si10616377ite.93.2018.03.07.20.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 20:25:30 -0800 (PST)
Subject: Re: [PATCH] hugetlbfs: check for pgoff value overflow
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180307235923.12469-1-mike.kravetz@oracle.com>
 <8a0863a2-1890-11e0-1fc2-c96e1794e809@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c41368dd-1566-c69f-ee98-8e89fdc16eeb@oracle.com>
Date: Wed, 7 Mar 2018 20:25:14 -0800
MIME-Version: 1.0
In-Reply-To: <8a0863a2-1890-11e0-1fc2-c96e1794e809@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Nic Losby <blurbdust@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 03/07/2018 05:35 PM, Yisheng Xie wrote:
> Hi Mike,
> 
> On 2018/3/8 7:59, Mike Kravetz wrote:
>> A vma with vm_pgoff large enough to overflow a loff_t type when
>> converted to a byte offset can be passed via the remap_file_pages
>> system call.  The hugetlbfs mmap routine uses the byte offset to
>> calculate reservations and file size.
>>
>> A sequence such as:
>>   mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
>>   remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);
>> will result in the following when task exits/file closed,
>>   kernel BUG at mm/hugetlb.c:749!
>> Call Trace:
>>   hugetlbfs_evict_inode+0x2f/0x40
>>   evict+0xcb/0x190
>>   __dentry_kill+0xcb/0x150
>>   __fput+0x164/0x1e0
>>   task_work_run+0x84/0xa0
>>   exit_to_usermode_loop+0x7d/0x80
>>   do_syscall_64+0x18b/0x190
>>   entry_SYSCALL_64_after_hwframe+0x3d/0xa2
>>
>> The overflowed pgoff value causes hugetlbfs to try to set up a
>> mapping with a negative range (end < start) that leaves invalid
>> state which causes the BUG.
>>
>> Reported-by: Nic Losby <blurbdust@gmail.com>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 7 ++++---
>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 8fe1b0aa2896..cb288dec5564 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -127,12 +127,13 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>  	vma->vm_ops = &hugetlb_vm_ops;
>>  
>>  	/*
>> -	 * Offset passed to mmap (before page shift) could have been
>> -	 * negative when represented as a (l)off_t.
>> +	 * page based offset in vm_pgoff could be sufficiently large to
>> +	 * overflow a (l)off_t when converted to byte offset.
>>  	 */
>> -	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
>> +	if (vma->vm_pgoff && ((loff_t)vma->vm_pgoff << PAGE_SHIFT) <= 0)
>>  		return -EINVAL;
> 
> This seems still no the right fix, taking the following case as an example:
>  mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
>  remap_file_pages(0x20a00000, 0x600000, 0, 0x0020001000000000, 0);
> 
> You should just check the highest PAGE_SHIFT+1 bits of pgoff in you want check
> at this point, right?

Yes, thank you!
That would be the correct check and also much simpler.  Something like,

	unsigned long ovfl_mask;

	ovfl_mask = (1UL << (PAGE_SHIFT + 1)) - 1;
	ovfl_mask <<= ((sizeof(unsigned long) * BITS_PER_BYTE) -
		      (PAGE_SHIFT + 1));
	if (vma->vm_pgoff & ovfl_mask)
		return -EINVAL;



> However, region_chg makes me a litter puzzle that when its return value < 0, sometime
> adds_in_progress is added like this case, while sometime it is not. so why not just
> change at the beginning of region_chg ?
> 	if (f > t)
> 		return -EINVAL;

If region_chg returns a value < 0, this indicates an error and adds_in_progress
should not be incremented.  In the case of this bug, region_chg was passed
values where f > t.  Of course, this should never happen.  But, because it
assumed f <= t, it returned a negative count needed huge page reservations.
The calling code interpreted the negative value as an error and a subsequent
region_add or region_abort.

I am not opposed to adding the suggested "if (f > t)".  However, the
region tracking routines are simple helpers only used by the hugetlbfs
code and the assumption is that they are being called correctly.  As
such, I would prefer to leave off the check.  But, this is the second
time they have been called incorrectly due to insufficient argument
checking.  If we do add this to region_chg, I would also add the check
to all region_* routines for consistency.

I will send out a V2 of this patch tomorrow with the corrected overflow
checking and possibly checks added to the region_* routines.
-- 
Mike Kravetz
