Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id EED0F6B049B
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 08:03:05 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id o8-v6so10749284iom.6
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 05:03:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t21-v6si14929450ioc.106.2018.10.30.05.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 05:03:04 -0700 (PDT)
Subject: Re: [RFC PATCH v2 3/3] mm, oom: hand over MMF_OOM_SKIP to exit path
 if it is guranteed to finish
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181025082403.3806-4-mhocko@kernel.org>
 <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
 <20181030063136.GU32673@dhcp22.suse.cz>
 <95cb93ec-2421-3c5d-fd1e-91d9696b0f5a@I-love.SAKURA.ne.jp>
 <20181030113915.GB32673@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ca390ac1-2f10-b734-fff7-56767253e8c5@i-love.sakura.ne.jp>
Date: Tue, 30 Oct 2018 21:02:40 +0900
MIME-Version: 1.0
In-Reply-To: <20181030113915.GB32673@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/30 20:39, Michal Hocko wrote:
> On Tue 30-10-18 18:47:43, Tetsuo Handa wrote:
>> On 2018/10/30 15:31, Michal Hocko wrote:
>>> On Tue 30-10-18 13:45:22, Tetsuo Handa wrote:
>>>> Michal Hocko wrote:
>>>>> @@ -3156,6 +3166,13 @@ void exit_mmap(struct mm_struct *mm)
>>>>>                 vma = remove_vma(vma);
>>>>>         }
>>>>>         vm_unacct_memory(nr_accounted);
>>>>> +
>>>>> +       /*
>>>>> +        * Now that the full address space is torn down, make sure the
>>>>> +        * OOM killer skips over this task
>>>>> +        */
>>>>> +       if (oom)
>>>>> +               set_bit(MMF_OOM_SKIP, &mm->flags);
>>>>>  }
>>>>>
>>>>>  /* Insert vm structure into process list sorted by address
>>>>
>>>> I don't like setting MMF_OOF_SKIP after remove_vma() loop. 50 users might
>>>> call vma->vm_ops->close() from remove_vma(). Some of them are doing fs
>>>> writeback, some of them might be doing GFP_KERNEL allocation from
>>>> vma->vm_ops->open() with a lock also held by vma->vm_ops->close().
>>>>
>>>> I don't think that waiting for completion of remove_vma() loop is safe.
>>>
>>> What do you mean by 'safe' here?
>>>
>>
>> safe = "Does not cause OOM lockup."
>>
>> remove_vma() is allowed to sleep, and some users might depend on memory
>> allocation when the OOM killer is waiting for remove_vma() to complete.
> 
> But MMF_OOF_SKIP is set after we are done with remove_vma. In fact it is
> the very last thing in exit_mmap. So I do not follow what you mean.
> 

So what? Think the worst case. Quite obvious bug here.

What happens if memory reclaimed by up to __free_pgtables() was consumed by somebody
else, and then some vma->vm_ops->close() started waiting for memory allocation due to
dependency? It is called "OOM lockup" because the OOM killer cannot be enabled because
MMF_OOM_SKIP cannot be set because vma->vm_ops->close() is waiting for the OOM killer
due to memory allocation dependency in vma->vm_ops->close() from remove_vma()...
