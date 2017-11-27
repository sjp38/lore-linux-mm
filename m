Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72D086B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 21:58:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m4so15084506pgc.23
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:58:03 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id e7si22690096plk.481.2017.11.26.18.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 18:58:02 -0800 (PST)
Subject: Re: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop
 under special circumstances.
From: =?UTF-8?B?6YOt6Zuq5qWg?= <guoxuenan@huawei.com>
References: <20171124022757.4991-1-guoxuenan@huawei.com>
 <20171124080507.u76g634hucoxmpov@dhcp22.suse.cz>
 <829af987-4d65-382c-dbd4-0c81222ebb51@huawei.com>
 <20171124130803.hafb3zbhy7gdqkvi@dhcp22.suse.cz>
 <52b8bab4-6656-fe76-ed21-ee3c4682a5e3@huawei.com>
Message-ID: <cef000ae-c74d-f460-64d8-0be23350005b@huawei.com>
Date: Mon, 27 Nov 2017 10:54:39 +0800
MIME-Version: 1.0
In-Reply-To: <52b8bab4-6656-fe76-ed21-ee3c4682a5e3@huawei.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rppt@linux.vnet.ibm.com, yi.zhang@huawei.com, miaoxie@huawei.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com, hillf.zj@alibaba-inc.com, shli@fb.com

Hi,Michal, Whether  need me to modify according your modification and 
resubmit a new patch?

a?? 2017/11/25 9:52, e?-e?aaeJPY  a??e??:
> Yes , your modification is much better! thanks.
> 
> a?? 2017/11/24 21:08, Michal Hocko a??e??:
>> On Fri 24-11-17 20:51:29, e?-e?aaeJPY  wrote:
>>> Sorry,I explained  wrong before. But,I've tested using trinity in DAX
>>> mode,and I'am sure it has possibility of triggering an soft lockup. I 
>>> have
>>> encountered the problem of endless loop here .
>>>
>>> I had a little problem here,I correct it .
>>> under Initial state :
>>> [ start = vam->vm_start < vam->vm_end < end ]
>>>
>>> When [start = vam->vm_start] the program enters  for{;;} loop
>>> ,find_vma_prev() will set the pointer vma and the pointer prev (prev =
>>> vam->vm_prev ). Normally ,madvise_vma() will always move the pointer 
>>> prev
>>> ,but when use DAX mode , it will never update .
>> [...]
>>> if (prev) // here prev not NULL,it will always enter this branch ..
>>>     vma = prev->vm_next;
>>> else    /* madvise_remove dropped mmap_sem */
>>>     vma = find_vma(current->mm, start);
>>
>> You are right! My fault, I managed to confuse myself in the code flow.
>> It really looks like this has been broken for more than 10 years since
>> fe77ba6f4f97 ("[PATCH] xip: madvice/fadvice: execute in place").
>>
>> Maybe the following would be more readable and less error prone?
>> ---
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 375cf32087e4..a631c414f915 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -276,30 +276,26 @@ static long madvise_willneed(struct 
>> vm_area_struct *vma,
>>   {
>>       struct file *file = vma->vm_file;
>> +    *prev = vma;
>>   #ifdef CONFIG_SWAP
>>       if (!file) {
>> -        *prev = vma;
>>           force_swapin_readahead(vma, start, end);
>>           return 0;
>>       }
>> -    if (shmem_mapping(file->f_mapping)) {
>> -        *prev = vma;
>> +    if (shmem_mapping(file->f_mapping))
>>           force_shm_swapin_readahead(vma, start, end,
>>                       file->f_mapping);
>>           return 0;
>> -    }
>>   #else
>>       if (!file)
>>           return -EBADF;
>>   #endif
>> -    if (IS_DAX(file_inode(file))) {
>> +    if (IS_DAX(file_inode(file)))
>>           /* no bad return value, but ignore advice */
>>           return 0;
>> -    }
>> -    *prev = vma;
>>       start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>>       if (end > vma->vm_end)
>>           end = vma->vm_end;
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
