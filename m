Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 222088E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 11:40:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id m21-v6so27156236oic.7
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:40:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r204-v6si11066851oih.29.2018.09.10.08.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 08:40:32 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <cc772297-5aeb-8410-d902-c224f4717514@i-love.sakura.ne.jp>
 <20180910151127.GM10951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7e123109-fe7d-65cf-883e-74850fd2cf86@i-love.sakura.ne.jp>
Date: Tue, 11 Sep 2018 00:40:23 +0900
MIME-Version: 1.0
In-Reply-To: <20180910151127.GM10951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/11 0:11, Michal Hocko wrote:
> On Mon 10-09-18 23:59:02, Tetsuo Handa wrote:
>> Thank you for proposing a patch.
>>
>> On 2018/09/10 21:55, Michal Hocko wrote:
>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>> index 5f2b2b1..99bb9ce 100644
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -3091,7 +3081,31 @@ void exit_mmap(struct mm_struct *mm)
>>>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
>>>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>>>  	unmap_vmas(&tlb, vma, 0, -1);
>>
>> unmap_vmas() might involve hugepage path. Is it safe to race with the OOM reaper?
>>
>>   i_mmap_lock_write(vma->vm_file->f_mapping);
>>   __unmap_hugepage_range_final(tlb, vma, start, end, NULL);
>>   i_mmap_unlock_write(vma->vm_file->f_mapping);
> 
> We do not unmap hugetlb pages in the oom reaper.
> 

But the OOM reaper can run while __unmap_hugepage_range_final() is in progress.
Then, I worry an overlooked race similar to clearing VM_LOCKED flag.

> 
>>
>>>  	tlb_finish_mmu(&tlb, 0, -1);
>>>  
>>>  	/*
>>
>> Also, how do you plan to give this thread enough CPU resources, for this thread might
>> be SCHED_IDLE priority? Since this thread might not be a thread which is exiting
>> (because this is merely a thread which invoked __mmput()), we can't use boosting
>> approach. CPU resource might be given eventually unless schedule_timeout_*() is used,
>> but it might be deadly slow if allocating threads keep wasting CPU resources.
> 
> This is OOM path which is glacial slow path. This is btw. no different
> from any other low priority tasks sitting on a lot of memory trying to
> release the memory (either by unmapping or exiting). Why should be this
> particular case any different?
> 

Not a problem if not under OOM situation. Since the OOM killer keeps wasting
CPU resources until memory reclaim completes, we want to solve OOM situation
as soon as possible.

>> Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?
> 
> The idea is that the mm is not visible to anybody (except for the oom
> reaper) anymore. So MMF_OOM_SKIP shouldn't matter.
> 

I think it absolutely matters. The OOM killer waits until MMF_OOM_SKIP is set
on a mm which is visible via task_struct->signal->oom_mm .
