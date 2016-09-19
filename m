Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7C8D6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:16:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so312843459pfv.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:16:48 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id x25si24950904pfa.224.2016.09.19.00.16.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 00:16:48 -0700 (PDT)
Message-ID: <57DF907B.7020802@huawei.com>
Date: Mon, 19 Sep 2016 15:15:07 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <20160914084219.GA1612@dhcp22.suse.cz> <20160914085227.GB1612@dhcp22.suse.cz> <57D91771.9050108@huawei.com> <7edef3e0-b7cd-426a-5ed7-b1dad822733a@I-love.SAKURA.ne.jp> <57D95620.8000404@huawei.com> <201609181500.HIC05206.QJOFMOFHOFtLVS@I-love.SAKURA.ne.jp>
In-Reply-To: <201609181500.HIC05206.QJOFMOFHOFtLVS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, qiuxishi@huawei.com, guohanjun@huawei.com, hughd@google.com

On 2016/9/18 14:00, Tetsuo Handa wrote:
> zhong jiang wrote:
>> On 2016/9/14 19:29, Tetsuo Handa wrote:
>>> On 2016/09/14 18:25, zhong jiang wrote:
>>>> On 2016/9/14 16:52, Michal Hocko wrote:
>>>>> On Wed 14-09-16 10:42:19, Michal Hocko wrote:
>>>>>> [Let's CC Hugh]
>>>>> now for real...
>>>>>
>>>>>> On Wed 14-09-16 15:13:50, zhong jiang wrote:
>>>>>> [...]
>>>>>>>   hi, Michal
>>>>>>>
>>>>>>>   Recently, I hit the same issue when run a OOM case of the LTP and ksm enable.
>>>>>>>  
>>>>>>> [  601.937145] Call trace:
>>>>>>> [  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
>>>>>>> [  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
>>>>>>> [  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
>>>>>>> [  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
>>>>>>> [  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
>>>>>>> [  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
>>>>>>> [  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
>>>>>>> [  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
>>>>>>> [  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
>>>>>>> [  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
>>>>>>> [  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
>>>>>>> [  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
>>> Please be sure to include exact kernel version (e.g. "uname -r",
>>> "cat /proc/version") when reporting.
>>>
>>> You are reporting a bug in 4.1-stable kernel, which was prone to
>>> OOM livelock because the OOM reaper is not available.
>>> ( http://lkml.kernel.org/r/57D8012F.7080508@huawei.com )
>>>
>>> I think we no longer can reproduce this bug using 4.8-rc6 (or linux-next),
>>> but it will be a nice thing to backport __GFP_NORETRY patch to stable
>>> kernels which do not have the OOM reaper.
>>   No, OOM reaper can not  solve the issue completely , As had disscussed with Michal.
>>   The conclusion is that we need come up with a better method to fix it.
>>
>>    Thanks
>>   zhongjiang
> I still think we no longer can reproduce this bug using 4.8-rc6 (or linux-next).
>
> As of 4.1-stable, this bug caused OOM livelock situation because TIF_MEMDIE was
> cleared only after returning from mmput() from exit_mm() from do_exit(). Since
> there is a TIF_MEMDIE thread waiting at mmput() exists, the OOM killer does not
> select next OOM victim because oom_scan_process_thread() returns OOM_SCAN_ABORT,
> although ksmd is waking up the OOM killer via a __GFP_FS allocation request.
>
> As of 4.8-rc6, the OOM reaper cannot take mmap_sem for read at __oom_reap_task()
> because of TIF_MEMDIE thread waiting at ksm_exit() from __mmput() from mmput()
>  from exit_mm() from do_exit(). Thus, __oom_reap_task() returns false and
> oom_reap_task() will emit "oom_reaper: unable to reap pid:%d (%s)\n" message.
> Then, oom_reap_task() clears TIF_MEMDIE from that thread, which in turn
> makes oom_scan_process_thread() not to return OOM_SCAN_ABORT because
> atomic_read(&task->signal->oom_victims) becomes 0 due to exit_oom_victim()
> by the OOM reaper. Then, the OOM killer selects next OOM victim because
> ksmd is waking up the OOM killer via a __GFP_FS allocation request.
  The issue will come up just in arm64, x86 is not.
> Thus, this bug will be completely solved (at the cost of selecting next
> OOM victim) as of 4.8-rc6.
>
>>>> Adding the __GFP_NORETRY,  the issue also can fixed.
>>>> Therefore, we can assure that the case of LTP will leads to the endless looping.
>>>>
>>>> index d45a0a1..03fb67b 100644
>>>> --- a/mm/ksm.c
>>>> +++ b/mm/ksm.c
>>>> @@ -283,7 +283,7 @@ static inline struct rmap_item *alloc_rmap_item(void)
>>>>  {
>>>>         struct rmap_item *rmap_item;
>>>>
>>>> -       rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
>>>> +       rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL | __GFP_NORETRY);
>>>>         if (rmap_item)
>>>>                 ksm_rmap_items++;
>>>>         return rmap_item;
> Your patch to add __GFP_NORETRY and __GFP_NOWARN is OK. But please explicitly state
> that you hit this bug in 4.1-stable. Also, your trace is not only a hung task but also
> an OOM livelock; the kernel as of 4.1-stable is silent when OOM livelock situation
> occurred.
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
