Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2766B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:40:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so12819278pfj.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:40:41 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id q126si7984625pfc.88.2017.10.02.08.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 08:40:39 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
 <201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
 <69a33b7a-afdf-d798-2e03-0c92dd94bfa6@alibaba-inc.com>
 <201709290545.HGH30269.LOVtSHFQOFJFOM@I-love.SAKURA.ne.jp>
 <1a0dd923-7b5c-e1ed-708a-5fdfe8c662dc@alibaba-inc.com>
 <201709302000.GGD86407.OOHMJFSFQLFOtV@I-love.SAKURA.ne.jp>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <e0531762-6ef7-d3bf-e6a2-91642b4eeb63@alibaba-inc.com>
Date: Mon, 02 Oct 2017 23:40:11 +0800
MIME-Version: 1.0
In-Reply-To: <201709302000.GGD86407.OOHMJFSFQLFOtV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/30/17 4:00 AM, Tetsuo Handa wrote:
> Yang Shi wrote:
>> On 9/28/17 1:45 PM, Tetsuo Handa wrote:
>>> Yang Shi wrote:
>>>> On 9/28/17 12:57 PM, Tetsuo Handa wrote:
>>>>> Yang Shi wrote:
>>>>>> On 9/27/17 9:36 PM, Tetsuo Handa wrote:
>>>>>>> On 2017/09/28 6:46, Yang Shi wrote:
>>>>>>>> Changelog v7 -> v8:
>>>>>>>> * Adopted Michal’s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
>>>>>>>
>>>>>>> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
>>>>>>> because there are
>>>>>>>
>>>>>>> 	mutex_lock(&slab_mutex);
>>>>>>> 	kmalloc(GFP_KERNEL);
>>>>>>> 	mutex_unlock(&slab_mutex);
>>>>>>>
>>>>>>> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
>>>>>>> introducing a risk of crash (i.e. kernel panic) for regular OOM path?
>>>>>>
>>>>>> I don't see the difference between regular oom path and oom path other
>>>>>> than calling panic() at last.
>>>>>>
>>>>>> And, the slab dump may be called by panic path too, it is for both
>>>>>> regular and panic path.
>>>>>
>>>>> Calling a function that might cause kerneloops immediately before calling panic()
>>>>> would be tolerable, for the kernel will panic after all. But calling a function
>>>>> that might cause kerneloops when there is no plan to call panic() is a bug.
>>>>
>>>> I got your point. slab_mutex is used to protect the list of all the
>>>> slabs, since we are already in oom, there should be not kmem cache
>>>> destroy happen during the list traverse. And, list_for_each_entry() has
>>>> been replaced to list_for_each_entry_safe() to make the traverse more
>>>> robust.
>>>
>>> I consider that OOM event and kmem chache destroy event can run concurrently
>>> because slab_mutex is not held by OOM event (and unfortunately cannot be held
>>> due to possibility of deadlock) in order to protect the list of all the slabs.
>>>
>>> I don't think replacing list_for_each_entry() with list_for_each_entry_safe()
>>> makes the traverse more robust, for list_for_each_entry_safe() does not defer
>>> freeing of memory used by list element. Rather, replacing list_for_each_entry()
>>> with list_for_each_entry_rcu() (and making relevant changes such as
>>> rcu_read_lock()/rcu_read_unlock()/synchronize_rcu()) will make the traverse safe.
>>
>> I'm not sure if rcu could satisfy this case. rcu just can protect
>> slab_caches_to_rcu_destroy list, which is used by SLAB_TYPESAFE_BY_RCU
>> slabs.
> 
> I'm not sure why you are talking about SLAB_TYPESAFE_BY_RCU.
> What I meant is that
> 
>    Upon registration:
> 
>      // do initialize/setup stuff here
>      synchronize_rcu(); // <= for dump_unreclaimable_slab()
>      list_add_rcu(&kmem_cache->list, &slab_caches);
> 
>    Upon unregistration:
> 
>      list_del_rcu(&kmem_cache->list);
>      synchronize_rcu(); // <= for dump_unreclaimable_slab()
>      // do finalize/cleanup stuff here
> 
> then (if my understanding is correct)
> 
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(s, &slab_caches, list) {
> 		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
> 			continue;
> 
> 		memset(&sinfo, 0, sizeof(sinfo));
> 		get_slabinfo(s, &sinfo);
> 
> 		if (sinfo.num_objs > 0)
> 			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
> 				(sinfo.active_objs * s->size) / 1024,
> 				(sinfo.num_objs * s->size) / 1024);
> 	}
> 	rcu_read_unlock();
> 
> will make dump_unreclaimable_slab() safe.

Thanks for the detailed description. However, it sounds this change is  
too much for slub, I'm not sure if this may change the subtle behavior  
of slub.

trylock sounds like a good alternative.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
