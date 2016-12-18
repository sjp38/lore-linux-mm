Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19FC26B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:49:32 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g187so63388565itc.2
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 05:49:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w10si7772573itf.56.2016.12.18.05.49.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Dec 2016 05:49:30 -0800 (PST)
Subject: Re: crash during oom reaper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz> <20161216104438.GD27758@node>
 <20161216114243.GG13940@dhcp22.suse.cz> <20161216123555.GE27758@node>
 <20161216125650.GJ13940@dhcp22.suse.cz> <20161216130730.GF27758@node>
 <20161216131427.GM13940@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <7918aa6b-8517-956b-5258-616ef1df6338@I-love.SAKURA.ne.jp>
Date: Sun, 18 Dec 2016 22:47:07 +0900
MIME-Version: 1.0
In-Reply-To: <20161216131427.GM13940@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2016/12/16 22:14, Michal Hocko wrote:
> On Fri 16-12-16 16:07:30, Kirill A. Shutemov wrote:
>> On Fri, Dec 16, 2016 at 01:56:50PM +0100, Michal Hocko wrote:
>>> On Fri 16-12-16 15:35:55, Kirill A. Shutemov wrote:
>>>> On Fri, Dec 16, 2016 at 12:42:43PM +0100, Michal Hocko wrote:
>>>>> On Fri 16-12-16 13:44:38, Kirill A. Shutemov wrote:
>>>>>> On Fri, Dec 16, 2016 at 11:11:13AM +0100, Michal Hocko wrote:
>>>>>>> On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
>>>>>>> [...]
>>>>>>>> I don't think it's a bug in the OOM reaper itself, but either of the
>>>>>>>> following two patches will fix the problem (without my understand how or
>>>>>>>> why):
>>>>>>>>
>>>>>>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>>>>>>> index ec9f11d4f094..37b14b2e2af4 100644
>>>>>>>> --- a/mm/oom_kill.c
>>>>>>>> +++ b/mm/oom_kill.c
>>>>>>>> @@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
>>>>>>>> struct mm_struct *mm)
>>>>>>>>  	 */
>>>>>>>>  	mutex_lock(&oom_lock);
>>>>>>>>
>>>>>>>> -	if (!down_read_trylock(&mm->mmap_sem)) {
>>>>>>>> +	if (!down_write_trylock(&mm->mmap_sem)) {
>>>>>>>
>>>>>>> __oom_reap_task_mm is basically the same thing as MADV_DONTNEED and that
>>>>>>> doesn't require the exlusive mmap_sem. So this looks correct to me.
>>>>>>
>>>>>> BTW, shouldn't we filter out all VM_SPECIAL VMAs there? Or VM_PFNMAP at
>>>>>> least.
>>>>>>
>>>>>> MADV_DONTNEED doesn't touch VM_PFNMAP, but I don't see anything matching
>>>>>> on __oom_reap_task_mm() side.
>>>>>
>>>>> I guess you are right and we should match the MADV_DONTNEED behavior
>>>>> here. Care to send a patch?
>>>>
>>>> Below. Testing required.
>>>>
>>>>>> Other difference is that you use unmap_page_range() witch doesn't touch
>>>>>> mmu_notifiers. MADV_DONTNEED goes via zap_page_range(), which invalidates
>>>>>> the range. Not sure if it can make any difference here.
>>>>>
>>>>> Which mmu notifier would care about this? I am not really familiar with
>>>>> those users so I might miss something easily.
>>>>
>>>> No idea either.
>>>>
>>>> Is there any reason not to use zap_page_range here too?
>>>
>>> Yes, zap_page_range is much more heavy and performs operations which
>>> might lock AFAIR which I really would like to prevent from.
>>
>> What exactly can block there? I don't see anything with that potential.
> 
> I would have to rememeber all the details. This is mostly off-topic for
> this particular thread so I think it would be better if you could send a
> full patch separatelly and we can discuss it there?
> 

zap_page_range() calls mmu_notifier_invalidate_range_start().
mmu_notifier_invalidate_range_start() calls __mmu_notifier_invalidate_range_start().
__mmu_notifier_invalidate_range_start() calls srcu_read_lock()/srcu_read_unlock().
This means that zap_page_range() might sleep.

I don't know what individual notifier will do, but for example

  static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
          .invalidate_range_start = i915_gem_userptr_mn_invalidate_range_start,
  };

i915_gem_userptr_mn_invalidate_range_start() calls flush_workqueue()
which means that we can OOM livelock if work item involves memory allocation.
Some of other notifiers call mutex_lock()/mutex_unlock().

Even if none of currently in-tree notifier users are blocked on memory
allocation, I think it is not guaranteed that future changes/users won't be
blocked on memory allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
