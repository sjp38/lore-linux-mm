Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C757D6B264B
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 16:51:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2-v6so1642085pgp.4
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:51:57 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id v33-v6si2579260pga.439.2018.08.22.13.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 13:51:56 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 2/5] uprobes: introduce has_uprobes helper
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-3-git-send-email-yang.shi@linux.alibaba.com>
 <e7147e14-bc38-03d0-90a4-5e0ca7e40050@suse.cz>
 <20180822150718.GB52756@linux.vnet.ibm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a8d4cb9b-eac2-2e11-d5c2-f5d57c1be537@linux.alibaba.com>
Date: Wed, 22 Aug 2018 13:51:31 -0700
MIME-Version: 1.0
In-Reply-To: <20180822150718.GB52756@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, liu.song.a23@gmail.com, ravi.bangoria@linux.ibm.com, linux-kernel@vger.kernel.org



On 8/22/18 8:07 AM, Srikar Dronamraju wrote:
> * Vlastimil Babka <vbabka@suse.cz> [2018-08-22 12:55:59]:
>
>> On 08/15/2018 08:49 PM, Yang Shi wrote:
>>> We need check if mm or vma has uprobes in the following patch to check
>>> if a vma could be unmapped with holding read mmap_sem. The checks and
>>> pre-conditions used by uprobe_munmap() look just suitable for this
>>> purpose.
>>>
>>> Extracting those checks into a helper function, has_uprobes().
>>>
>>> Cc: Peter Zijlstra <peterz@infradead.org>
>>> Cc: Ingo Molnar <mingo@redhat.com>
>>> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
>>> Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
>>> Cc: Jiri Olsa <jolsa@redhat.com>
>>> Cc: Namhyung Kim <namhyung@kernel.org>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>>   include/linux/uprobes.h |  7 +++++++
>>>   kernel/events/uprobes.c | 23 ++++++++++++++++-------
>>>   2 files changed, 23 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
>>> index 0a294e9..418764e 100644
>>> --- a/include/linux/uprobes.h
>>> +++ b/include/linux/uprobes.h
>>> @@ -149,6 +149,8 @@ struct uprobes_state {
>>>   extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
>>>   extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
>>>   					 void *src, unsigned long len);
>>> +extern bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
>>> +			unsigned long end);
>>>   #else /* !CONFIG_UPROBES */
>>>   struct uprobes_state {
>>>   };
>>> @@ -203,5 +205,10 @@ static inline void uprobe_copy_process(struct task_struct *t, unsigned long flag
>>>   static inline void uprobe_clear_state(struct mm_struct *mm)
>>>   {
>>>   }
>>> +static inline bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
>>> +			       unsgined long end)
>>> +{
>>> +	return false;
>>> +}
>>>   #endif /* !CONFIG_UPROBES */
>>>   #endif	/* _LINUX_UPROBES_H */
>>> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
>>> index aed1ba5..568481c 100644
>>> --- a/kernel/events/uprobes.c
>>> +++ b/kernel/events/uprobes.c
>>> @@ -1114,22 +1114,31 @@ int uprobe_mmap(struct vm_area_struct *vma)
>>>   	return !!n;
>>>   }
>>>   
>>> -/*
>>> - * Called in context of a munmap of a vma.
>>> - */
>>> -void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
>>> +bool
>>> +has_uprobes(struct vm_area_struct *vma, unsigned long start, unsigned long end)
>> The name is not really great...
> I too feel the name is not apt.
> Can you make this vma_has_uprobes and convert the current
> vma_has_uprobes to __vma_has_uprobes?

It sounds good to me.

>
>>>   {
>>>   	if (no_uprobe_events() || !valid_vma(vma, false))
>>> -		return;
>>> +		return false;
>>>   
>>>   	if (!atomic_read(&vma->vm_mm->mm_users)) /* called by mmput() ? */
>>> -		return;
>>> +		return false;
>>>   
>>>   	if (!test_bit(MMF_HAS_UPROBES, &vma->vm_mm->flags) ||
>>>   	     test_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags))
>> This means that vma might have uprobes, but since RECALC is already set,
>> we don't need to set it again. That's different from "has uprobes".
>>
>> Perhaps something like vma_needs_recalc_uprobes() ?
>>
>> But I also worry there might be a race where we initially return false
>> because of MMF_RECALC_UPROBES, then the flag is cleared while vma's
>> still have uprobes, then we downgrade mmap_sem and skip uprobe_munmap().
>> Should be checked if e.g. mmap_sem and vma visibility changes protects
>> this case from happening.
> That is a very good observation.
>
> One think we can probably do is pass an extra parameter to
> has_uprobes(), depending on which we should skip this check.
> such that when we call from uprobes_munmap(), we continue as is
> but when calling from do_munmap_zap_rlock(), we skip the check.

Yes, it sounds good to solve the race issue. When we need decide if we 
should jump to regular path for uprobes mapping, we don't check if 
MMF_RECALC_UPROBES is set or not. It looks not harmful to set this flag 
twice.

Thanks,
Yang

>
>
>>> -		return;
>>> +		return false;
>>>   
>>>   	if (vma_has_uprobes(vma, start, end))
>>> +		return true;
>>> +
>>> +	return false;
>> Simpler:
>> 	return vma_has_uprobes(vma, start, end);
>>
>>> +}
>>> +
>>> +/*
>>> + * Called in context of a munmap of a vma.
>>> + */
>>> +void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
>>> +{
>>> +	if (has_uprobes(vma, start, end))
>>>   		set_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags);
>>>   }
