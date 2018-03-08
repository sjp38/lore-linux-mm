Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5576B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:38:11 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c76so1021864qke.19
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:38:11 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q126si5784750qkb.218.2018.03.08.15.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:38:10 -0800 (PST)
Subject: Re: [PATCH v2] hugetlbfs: check for pgoff value overflow
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180308210502.15952-1-mike.kravetz@oracle.com>
 <20180308141533.d16e43f5f559215089e522ae@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a5e3c0c4-d41e-6ffd-935d-63cce2527d0f@oracle.com>
Date: Thu, 8 Mar 2018 15:37:57 -0800
MIME-Version: 1.0
In-Reply-To: <20180308141533.d16e43f5f559215089e522ae@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, stable@vger.kernel.org

On 03/08/2018 02:15 PM, Andrew Morton wrote:
> On Thu,  8 Mar 2018 13:05:02 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
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
>> The previous overflow fix to this code was incomplete and did not
>> take the remap_file_pages system call into account.
>>
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -111,6 +111,7 @@ static void huge_pagevec_release(struct pagevec *pvec)
>>  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>  {
>>  	struct inode *inode = file_inode(file);
>> +	unsigned long ovfl_mask;
>>  	loff_t len, vma_len;
>>  	int ret;
>>  	struct hstate *h = hstate_file(file);
>> @@ -127,12 +128,16 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>>  	vma->vm_ops = &hugetlb_vm_ops;
>>  
>>  	/*
>> -	 * Offset passed to mmap (before page shift) could have been
>> -	 * negative when represented as a (l)off_t.
>> +	 * page based offset in vm_pgoff could be sufficiently large to
>> +	 * overflow a (l)off_t when converted to byte offset.
>>  	 */
>> -	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
>> +	ovfl_mask = (1UL << (PAGE_SHIFT + 1)) - 1;
>> +	ovfl_mask <<= ((sizeof(unsigned long) * BITS_PER_BYTE) -
>> +		       (PAGE_SHIFT + 1));
> 
> That's a compile-time constant.  The compiler will indeed generate an
> immediate load, but I think it would be better to make the code look
> more like we know that it's a constant, if you get what I mean. 
> Something like
> 
> /*
>  * If a pgoff_t is to be converted to a byte index, this is the max value it
>  * can have to avoid overflow in that conversion.
>  */
> #define PGOFF_T_MAX	<long string of crap>

Ok

> And I bet that this constant could be used elsewhere - surely it's a
> very common thing to be checking for.
> 
> 
> Also, the expression seems rather complicated.  Why are we adding 1 to
> PAGE_SHIFT?  Isn't there a logical way of using PAGE_MASK?

The + 1 is there because this value will eventually be converted to
a loff_t which is signed.  So, we need to take that sign bit into
account or we could end up with a negative value.

For PAGE_SHIFT == 12, PAGE_MASK is 0xfffffffffffff000.  Our target
mask is  0xfff8000000000000 (for the sign bit).  So, we could do
PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1)

This legacy hugetlbfs code may be a little different than other areas
in the use of loff_t.  When doing some previous work in this area, I
did not find enough common used to make this more general purpose.  See,
https://lkml.org/lkml/2017/4/12/793

> The resulting constant is 0xfff8000000000000 on 64-bit.  We could just
> use along the lines of
> 
> 	1UL << (BITS_PER_LONG - PAGE_SHIFT - 1)

Ah yes, BITS_PER_LONG is better than (sizeof(unsigned long) * BITS_PER_BYTE

> But why the -1?  We should be able to handle a pgoff_t of
> 0xfff0000000000000 in this code?

I'm not exactly sure what you are asking/suggesting here and in the line
above.  It is because of the conversion to a signed value that we have to
go with 0xfff8000000000000 instead of 0xfff0000000000000.

Here are a couple options for computing the mask.  I changed the name
you suggested to make it more obvious that the mask is being used to
check for loff_t overflow.

If we want to explicitly comptue the mask as in code above.
#define PGOFF_LOFFT_MAX \
	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))

Or, we use PAGE_MASK
#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))

In either case, we need a big comment explaining the mask and
how we have that extra bit +/- 1 because the offset will be converted
to a signed value.
	
> Also, we later to
> 
> 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> 	/* check for overflow */
> 	if (len < vma_len)
> 		return -EINVAL;
> 
> which is ungainly: even if we passed the PGOFF_T_MAX test, there can
> still be an overflow which we still must check for.  Is that avoidable?
> Probably not...

Yes, it is required.  That check takes into account the length argument
which is added to page offset.  So, yes you can pass the first check and
fail this one.

-- 
Mike Kravetz
