Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 617176B007E
	for <linux-mm@kvack.org>; Sun,  8 May 2016 03:03:09 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id e126so76240408vkb.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 00:03:09 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j9si14922292qgj.95.2016.05.08.00.03.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 May 2016 00:03:08 -0700 (PDT)
Message-ID: <572EE0E0.5090904@huawei.com>
Date: Sun, 8 May 2016 14:46:56 +0800
From: zhouchengming <zhouchengming1@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: fix conflict between mmput and scan_get_next_rmap_item
References: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com> <20160505140745.32b100a6d100a86d59f1d11b@linux-foundation.org> <572C0674.9080006@huawei.com> <alpine.LSU.2.11.1605062010260.2310@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1605062010260.2310@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, aarcange@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com

On 2016/5/7 12:04, Hugh Dickins wrote:
> On Fri, 6 May 2016, zhouchengming wrote:
>> On 2016/5/6 5:07, Andrew Morton wrote:
>>> On Thu, 5 May 2016 20:42:56 +0800 Zhou Chengming<zhouchengming1@huawei.com>
>>> wrote:
>>>
>>>> A concurrency issue about KSM in the function scan_get_next_rmap_item.
>>>>
>>>> task A (ksmd):				|task B (the mm's task):
>>>> 					|
>>>> mm = slot->mm;				|
>>>> down_read(&mm->mmap_sem);		|
>>>> 					|
>>>> ...					|
>>>> 					|
>>>> spin_lock(&ksm_mmlist_lock);		|
>>>> 					|
>>>> ksm_scan.mm_slot go to the next slot;	|
>>>> 					|
>>>> spin_unlock(&ksm_mmlist_lock);		|
>>>> 					|mmput() ->
>>>> 					|	ksm_exit():
>>>> 					|
>>>> 					|spin_lock(&ksm_mmlist_lock);
>>>> 					|if (mm_slot&&   ksm_scan.mm_slot !=
>>>> mm_slot) {
>>>> 					|	if (!mm_slot->rmap_list) {
>>>> 					|		easy_to_free = 1;
>>>> 					|		...
>>>> 					|
>>>> 					|if (easy_to_free) {
>>>> 					|	mmdrop(mm);
>>>> 					|	...
>>>> 					|
>>>> 					|So this mm_struct will be freed
>>>> successfully.
>
> Good catch, yes.  Note that the mmdrop(mm) shown above is not the one that
> frees the mm_struct: the whole address space has to be torn down before
> we reach the mmdrop(mm) which actually frees the mm_struct.  But you're
> right that there's no serialization against ksmd in that interval, so if
> ksmd is rescheduled or interrupted for a long time, yes that mm_struct
> might be freed by the time of its up_read() below.
>

Yes, my description above is a little misleading. I will amend it. Thanks
>>>> 					|
>>>> up_read(&mm->mmap_sem);			|
>>>>
>>>> As we can see above, the ksmd thread may access a mm_struct that already
>>>> been freed to the kmem_cache.
>>>> Suppose a fork will get this mm_struct from the kmem_cache, the ksmd
>>>> thread
>>>> then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
>>>> I changed the scan_get_next_rmap_item function refered to the khugepaged
>>>> scan function.
>>>
>>> Thanks.
>>>
>>> We need to decide whether this fix should be backported into earlier
>>> (-stable) kernels.  Can you tell us how easily this is triggered and
>>> share your thoughts on this?
>
> Not easy to trigger at all, I think, and I've never seen it or heard
> a report of it; but possible.  It can only happen when there are one or
> more VM_MERGEABLE areas in the process, but they're all empty or swapped
> out when it exits (the easy_to_free route which presents this problem is
> only taken in that !mm_slot->rmap_list case - intended to minimize the
> drag on quick processes which exit before ksmd even reaches them).
>
> But if ksmd is preempted for a long time in between its spin_unlock
> and its up_read, then yes it can happen.  Fix should go back to
> 2.6.32, I don't think there's been much change here since it went in.
>
>>>
>>>
>>> .
>>>
>>
>> I write a patch that can easily trigger this bug.
>> When ksmd go to sleep, if a fork get this mm_struct, BUG_ON
>> will be triggered.
>
> Please don't use the patch below to test the final version of your fix
> (including latest suggestions from Andrea): mm->owner is updated even
> before the final mmput() which calls ksm_exit(), so BUGging on a
> change of mm->owner says nothing about how likely it would be to
> up_read on a freed mm_struct.
>
> Hugh
>

Thanks, you are right. mm->owner may change before the final mmput() 
which calls ksm_exit(). So I wonder if there is a way to check the
bug happened ?
>>
>>  From eedfdd12eb11858f69ff4a4300acad42946ca260 Mon Sep 17 00:00:00 2001
>> From: Zhou Chengming<zhouchengming1@huawei.com>
>> Date: Thu, 5 May 2016 17:49:22 +0800
>> Subject: [PATCH] ksm: trigger a bug
>>
>> Signed-off-by: Zhou Chengming<zhouchengming1@huawei.com>
>> ---
>>   mm/ksm.c |   17 +++++++++++++++++
>>   1 files changed, 17 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index ca6d2a0..676368c 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -1519,6 +1519,18 @@ static struct rmap_item *get_next_rmap_item(struct
>> mm_slot *mm_slot,
>>   	return rmap_item;
>>   }
>>
>> +static void trigger_a_bug(struct task_struct *p, struct mm_struct *mm)
>> +{
>> +	/* send KILL sig to the task, hope the mm_struct will be freed */
>> +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>> +	/* sleep for 5s, the mm_struct will be freed and another fork
>> +	 * will use this mm_struct
>> +	 */
>> +	schedule_timeout(msecs_to_jiffies(5000));
>> +	/* the mm_struct owned by another task */
>> +	BUG_ON(mm->owner != p);
>> +}
>> +
>>   static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>>   {
>>   	struct mm_struct *mm;
>> @@ -1526,6 +1538,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct
>> page **page)
>>   	struct vm_area_struct *vma;
>>   	struct rmap_item *rmap_item;
>>   	int nid;
>> +	struct task_struct *taskp;
>>
>>   	if (list_empty(&ksm_mm_head.mm_list))
>>   		return NULL;
>> @@ -1636,6 +1649,8 @@ next_mm:
>>   	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);
>>
>>   	spin_lock(&ksm_mmlist_lock);
>> +	/* get the mm's task now in the ksm_mmlist_lock */
>> +	taskp = mm->owner;
>>   	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
>>   						struct mm_slot, mm_list);
>>   	if (ksm_scan.address == 0) {
>> @@ -1651,6 +1666,7 @@ next_mm:
>>   		hash_del(&slot->link);
>>   		list_del(&slot->mm_list);
>>   		spin_unlock(&ksm_mmlist_lock);
>> +		trigger_a_bug(taskp, mm);
>>
>>   		free_mm_slot(slot);
>>   		clear_bit(MMF_VM_MERGEABLE,&mm->flags);
>> @@ -1658,6 +1674,7 @@ next_mm:
>>   		mmdrop(mm);
>>   	} else {
>>   		spin_unlock(&ksm_mmlist_lock);
>> +		trigger_a_bug(taskp, mm);
>>   		up_read(&mm->mmap_sem);
>>   	}
>>
>> --
>> 1.7.7
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
