Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30FE96B0038
	for <linux-mm@kvack.org>; Sat, 15 Apr 2017 19:01:40 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p80so34804424iop.16
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 16:01:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 137si3241577ith.47.2017.04.15.16.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 16:01:39 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
 <20170414033210.GA12973@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c5c80a74-b4a8-6987-188e-ab63420f5362@oracle.com>
Date: Sat, 15 Apr 2017 15:58:59 -0700
MIME-Version: 1.0
In-Reply-To: <20170414033210.GA12973@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/13/2017 08:32 PM, Naoya Horiguchi wrote:
> On Tue, Apr 11, 2017 at 03:51:58PM -0700, Mike Kravetz wrote:
> ...
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 7163fe0..dde8613 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>  	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
>>  	vma->vm_ops = &hugetlb_vm_ops;
>>  
>> +	/*
>> +	 * Offset passed to mmap (before page shift) could have been
>> +	 * negative when represented as a (l)off_t.
>> +	 */
>> +	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
>> +		return -EINVAL;
>> +
>>  	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>>  		return -EINVAL;
>>  
>>  	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
>> +	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>> +	/* check for overflow */
>> +	if (len < vma_len)
>> +		return -EINVAL;
> 
> Andrew sent this patch to Linus today, so I know it's a little too late, but
> I think that getting len directly from vma like below might be a simpler fix.
> 
>   len = (loff_t)(vma->vm_end - vma->vm_start + (vma->vm_pgoff << PAGE_SHIFT)); 
> 
> This shouldn't overflow because vma->vm_{end|start|pgoff} are unsigned long,
> but if worried you can add VM_BUG_ON_VMA(len < 0, vma).

Thanks Naoya,

I am pretty sure the checks are necessary.  You are correct in that
vma->vm_{end|start|pgoff} are unsigned long.  However,  pgoff can be
a REALLY big value that becomes negative when shifted.

Note that pgoff is simply the off_t offset value passed from the user cast
to unsigned long and shifted right by PAGE_SHIFT.  There is nothing to
prevent a user from passing a 'signed' negative value.  In the reproducer
provided, the value passed from user space is 0x8000000000000000ULL.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
