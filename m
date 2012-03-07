Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id BFF4C6B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 18:30:07 -0500 (EST)
Message-ID: <4F57EF6F.2010408@utoronto.ca>
Date: Wed, 07 Mar 2012 18:29:51 -0500
From: Steven Truelove <steven.truelove@utoronto.ca>
MIME-Version: 1.0
Subject: Re: [PATCH] Correct alignment of huge page requests.
References: <1330830176-19449-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1330830176-19449-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: wli@holomorphy.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/03/2012 10:02 PM, Naoya Horiguchi wrote:
> On Thu, Mar 01, 2012 at 09:58:41PM -0500, Steven Truelove wrote:
>> When calling shmget() with SHM_HUGETLB, shmget aligns the request size to PAGE_SIZE, but this is not sufficient.  Modified hugetlb_file_setup() to align requests to the huge page size, and to accept an address argument so that all alignment checks can be performed in hugetlb_file_setup(), rather than in its callers.  Changed newseg and mmap_pgoff to match new prototype and eliminated a now redundant alignment check.
> I think only rounding up request size in shmget() is not sufficient,
> because later shmat() also have alignment check and fails to mmap()
> to unaligned address.
> Maybe file->f_op->get_unmapped_area() (or hugetlb_get_unmapped_area())
> should have round up code, I think.
> Could you try it?

Because the allocation is done in shmget() and the the address is not 
provided until shmat(), I don't see a way to make this work reasonably.  
I would argue that only allowing aligned addresses, or allowing the 
kernel to choose the address, is a reasonable restriction on SHM_HUGETLB 
usage.

Regarding your other comments, I will submit a revised patch.

Thanks,

Steven Truelove


> And a few comments below,
>
>> Signed-off-by: Steven Truelove<steven.truelove@utoronto.ca>
>> ---
>>   fs/hugetlbfs/inode.c    |   12 ++++++++----
>>   include/linux/hugetlb.h |    3 ++-
>>   ipc/shm.c               |    2 +-
>>   mm/mmap.c               |    6 +++---
>>   4 files changed, 14 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 1e85a7a..a97b7cc 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -928,7 +928,7 @@ static int can_do_hugetlb_shm(void)
>>   	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
>>   }
>>
>> -struct file *hugetlb_file_setup(const char *name, size_t size,
>> +struct file *hugetlb_file_setup(const char *name, unsigned long addr, size_t size,
> Just a nitpick, this line is over 80 characters.
> checkpatch.pl should warn.
>
>>   				vm_flags_t acctflag,
>>   				struct user_struct **user, int creat_flags)
>>   {
>> @@ -938,6 +938,8 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
>>   	struct path path;
>>   	struct dentry *root;
>>   	struct qstr quick_string;
>> +	struct hstate *hstate;
>> +	int num_pages;
> Is unsigned long better?
>
> Thanks,
> Naoya
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
