Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2A8AE6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 21:17:28 -0400 (EDT)
Message-ID: <51F1CE0B.7070502@huawei.com>
Date: Fri, 26 Jul 2013 09:16:59 +0800
From: Libin <huawei.libin@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix potential NULL pointer dereference
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com> <20130724042208.GJ22680@hacker.(null)> <20130724043531.GA22357@hacker.(null)>
In-Reply-To: <20130724043531.GA22357@hacker.(null)>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

On 2013/7/24 12:35, Wanpeng Li wrote:
> On Wed, Jul 24, 2013 at 12:22:08PM +0800, Wanpeng Li wrote:
>> On Wed, Jul 24, 2013 at 11:48:19AM +0800, Libin wrote:
>>> find_vma may return NULL, thus check the return
>>> value to avoid NULL pointer dereference.
>>>
>>
>> When can this happen since down_read(&mm->mmap_sem) is held?
>>
> 
> Between mmap_sem read lock released and write lock held I think.
> 

Yes, In khugepaged_alloc_page mmap_sem read lock was released.
Thanks for your reply.
Libin.

>>> Signed-off-by: Libin <huawei.libin@huawei.com>
>>> ---
>>> mm/huge_memory.c | 2 ++
>>> 1 file changed, 2 insertions(+)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 243e710..d4423f4 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>>> 		goto out;
>>>
>>> 	vma = find_vma(mm, address);
>>> +	if (!vma)
>>> +		goto out;
>>> 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>>> 	hend = vma->vm_end & HPAGE_PMD_MASK;
>>> 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>>> -- 
>>> 1.8.2.1
>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
