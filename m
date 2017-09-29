Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3506B025E
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 18:15:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q75so1221468pfl.1
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 15:15:20 -0700 (PDT)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTPS id b6si4021630pfm.392.2017.09.29.15.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 15:15:18 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
 <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
 <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
 <201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
 <69a33b7a-afdf-d798-2e03-0c92dd94bfa6@alibaba-inc.com>
 <201709290545.HGH30269.LOVtSHFQOFJFOM@I-love.SAKURA.ne.jp>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <1a0dd923-7b5c-e1ed-708a-5fdfe8c662dc@alibaba-inc.com>
Date: Sat, 30 Sep 2017 06:15:10 +0800
MIME-Version: 1.0
In-Reply-To: <201709290545.HGH30269.LOVtSHFQOFJFOM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/28/17 1:45 PM, Tetsuo Handa wrote:
> Yang Shi wrote:
>> On 9/28/17 12:57 PM, Tetsuo Handa wrote:
>>> Yang Shi wrote:
>>>> On 9/27/17 9:36 PM, Tetsuo Handa wrote:
>>>>> On 2017/09/28 6:46, Yang Shi wrote:
>>>>>> Changelog v7 -> v8:
>>>>>> * Adopted Michal’s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
>>>>>
>>>>> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
>>>>> because there are
>>>>>
>>>>> 	mutex_lock(&slab_mutex);
>>>>> 	kmalloc(GFP_KERNEL);
>>>>> 	mutex_unlock(&slab_mutex);
>>>>>
>>>>> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
>>>>> introducing a risk of crash (i.e. kernel panic) for regular OOM path?
>>>>
>>>> I don't see the difference between regular oom path and oom path other
>>>> than calling panic() at last.
>>>>
>>>> And, the slab dump may be called by panic path too, it is for both
>>>> regular and panic path.
>>>
>>> Calling a function that might cause kerneloops immediately before calling panic()
>>> would be tolerable, for the kernel will panic after all. But calling a function
>>> that might cause kerneloops when there is no plan to call panic() is a bug.
>>
>> I got your point. slab_mutex is used to protect the list of all the
>> slabs, since we are already in oom, there should be not kmem cache
>> destroy happen during the list traverse. And, list_for_each_entry() has
>> been replaced to list_for_each_entry_safe() to make the traverse more
>> robust.
> 
> I consider that OOM event and kmem chache destroy event can run concurrently
> because slab_mutex is not held by OOM event (and unfortunately cannot be held
> due to possibility of deadlock) in order to protect the list of all the slabs.
> 
> I don't think replacing list_for_each_entry() with list_for_each_entry_safe()
> makes the traverse more robust, for list_for_each_entry_safe() does not defer
> freeing of memory used by list element. Rather, replacing list_for_each_entry()
> with list_for_each_entry_rcu() (and making relevant changes such as
> rcu_read_lock()/rcu_read_unlock()/synchronize_rcu()) will make the traverse safe.

I'm not sure if rcu could satisfy this case. rcu just can protect  
slab_caches_to_rcu_destroy list, which is used by SLAB_TYPESAFE_BY_RCU  
slabs.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
