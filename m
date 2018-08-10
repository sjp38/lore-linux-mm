Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA1B6B0006
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 13:01:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y16-v6so4738096pgv.23
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 10:01:12 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id x1-v6si11537181pgx.60.2018.08.10.10.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 10:01:11 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 4/4] mm: unmap special vmas with regular
 do_munmap()
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
 <93bbbf91-2bae-b5f1-17d3-72a13efc3ec6@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a1f54170-7c8d-9f67-0e64-5937afadfbb2@linux.alibaba.com>
Date: Fri, 10 Aug 2018 10:00:45 -0700
MIME-Version: 1.0
In-Reply-To: <93bbbf91-2bae-b5f1-17d3-72a13efc3ec6@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/10/18 3:46 AM, Vlastimil Babka wrote:
> On 08/10/2018 01:36 AM, Yang Shi wrote:
>> Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
>> have uprobes set, need get done with write mmap_sem held since
>> they may update vm_flags.
>>
>> So, it might be not safe enough to deal with these kind of special
>> mappings with read mmap_sem. Deal with such mappings with regular
>> do_munmap() call.
>>
>> Michal suggested to make this as a separate patch for safer and more
>> bisectable sake.
>>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/mmap.c | 24 ++++++++++++++++++++++++
>>   1 file changed, 24 insertions(+)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 2234d5a..06cb83c 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2766,6 +2766,16 @@ static inline void munlock_vmas(struct vm_area_struct *vma,
>>   	}
>>   }
>>   
>> +static inline bool can_zap_with_rlock(struct vm_area_struct *vma)
>> +{
>> +	if ((vma->vm_file &&
>> +	     vma_has_uprobes(vma, vma->vm_start, vma->vm_end)) |
> vma_has_uprobes() seems to be rather expensive check with e.g.
> unconditional spinlock. uprobe_munmap() seems to have some precondition
> cheaper checks for e.g. cases when there's no uprobes in the system
> (should be common?).

I think they are common, i.e. checking vm prot since uprobes are 
typically installed for VM_EXEC vmas. We could use those checks to save 
some cycles.

>
> BTW, uprobe_munmap() touches mm->flags, not vma->flags, so it should be
> evaluated more carefully for being called under mmap sem for reading, as
> having vmas already detached is no guarantee.

We might just leave uprobe vmas to use regular do_munmap? I'm supposed 
they should be not very common. And, uprobes just can be installed for 
VM_EXEC vma, although there may be large text segments, typically 
VM_EXEC vmas are unmapped when process exits, so the latency might be fine.

>
>> +	     (vma->vm_flags | (VM_HUGETLB | VM_PFNMAP)))
> 			    ^ I think replace '|' with '&' here?

Yes, thanks for catching this.

>
>> +		return false;
>> +
>> +	return true;
>> +}
>> +
>>   /*
>>    * Zap pages with read mmap_sem held
>>    *
>> @@ -2808,6 +2818,17 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>>   			goto out;
>>   	}
>>   
>> +	/*
>> +	 * Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
>> +	 * have uprobes set, need get done with write mmap_sem held since
>> +	 * they may update vm_flags. Deal with such mappings with regular
>> +	 * do_munmap() call.
>> +	 */
>> +	for (vma = start_vma; vma && vma->vm_start < end; vma = vma->vm_next) {
>> +		if (!can_zap_with_rlock(vma))
>> +			goto regular_path;
>> +	}
>> +
>>   	/* Handle mlocked vmas */
>>   	if (mm->locked_vm) {
>>   		vma = start_vma;
>> @@ -2828,6 +2849,9 @@ static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>>   
>>   	return 0;
>>   
>> +regular_path:
> I think it's missing a down_write_* here.

No, the jump is called before downgrade_write.

Thanks,
Yang

>
>> +	ret = do_munmap(mm, start, len, uf);
>> +
>>   out:
>>   	up_write(&mm->mmap_sem);
>>   	return ret;
>>
