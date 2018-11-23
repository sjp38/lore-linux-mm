Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D672B6B30A4
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:14:47 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so9669344wrw.4
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:14:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h140-v6sor4463419wma.16.2018.11.23.02.14.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 02:14:46 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [PATCH 2/3] mm, notifier: Catch sleeping/blocking for !blockable
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-3-daniel.vetter@ffwll.ch>
 <f9c39a9a-5afd-4aed-c9ad-0c3fef34a449@amd.com>
 <20181123084609.GH4266@phenom.ffwll.local>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <59f25d62-904a-86cf-3daf-88e38d526dcf@gmail.com>
Date: Fri, 23 Nov 2018 11:14:44 +0100
MIME-Version: 1.0
In-Reply-To: <20181123084609.GH4266@phenom.ffwll.local>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Koenig, Christian" <Christian.Koenig@amd.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

Am 23.11.18 um 09:46 schrieb Daniel Vetter:
> On Thu, Nov 22, 2018 at 06:55:17PM +0000, Koenig, Christian wrote:
>> Am 22.11.18 um 17:51 schrieb Daniel Vetter:
>>> We need to make sure implementations don't cheat and don't have a
>>> possible schedule/blocking point deeply burried where review can't
>>> catch it.
>>>
>>> I'm not sure whether this is the best way to make sure all the
>>> might_sleep() callsites trigger, and it's a bit ugly in the code flow.
>>> But it gets the job done.
>>>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: David Rientjes <rientjes@google.com>
>>> Cc: "Christian König" <christian.koenig@amd.com>
>>> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
>>> Cc: "Jérôme Glisse" <jglisse@redhat.com>
>>> Cc: linux-mm@kvack.org
>>> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>>> ---
>>>    mm/mmu_notifier.c | 8 +++++++-
>>>    1 file changed, 7 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
>>> index 59e102589a25..4d282cfb296e 100644
>>> --- a/mm/mmu_notifier.c
>>> +++ b/mm/mmu_notifier.c
>>> @@ -185,7 +185,13 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>>>    	id = srcu_read_lock(&srcu);
>>>    	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>>>    		if (mn->ops->invalidate_range_start) {
>>> -			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
>>> +			int _ret;
>>> +
>>> +			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
>>> +				preempt_disable();
>>> +			_ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
>>> +			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
>>> +				preempt_enable();
>> Just for the sake of better documenting this how about adding this to
>> include/linux/kernel.h right next to might_sleep():
>>
>> #define disallow_sleeping_if(cond)    for((cond) ? preempt_disable() :
>> (void)0; (cond); preempt_disable())
>>
>> (Just from the back of my head, might contain peanuts and/or hints of
>> errors).
> I think these magic for blocks aren't used in the kernel. goto breaks
> them, and we use goto a lot.

Yeah, good argument.

> I think a disallow/allow_sleep() pair with
> the conditional preept_disable/enable() calls would be nice though. I can
> do that if the overall idea sticks.

Sounds like a good idea to me as well.

Christian.

> -Daniel
>
>> Christian.
>>
>>>    			if (_ret) {
>>>    				pr_info("%pS callback failed with %d in %sblockable context.\n",
>>>    						mn->ops->invalidate_range_start, _ret,
