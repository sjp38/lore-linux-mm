Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFA726B025E
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 16:22:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 188so6254536pgb.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 13:22:17 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id s2si2008280pfi.348.2017.09.28.13.22.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 13:22:16 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
 <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
 <7e8684c2-c9e8-f76a-d7fb-7d5bf7682321@alibaba-inc.com>
 <201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <69a33b7a-afdf-d798-2e03-0c92dd94bfa6@alibaba-inc.com>
Date: Fri, 29 Sep 2017 04:21:54 +0800
MIME-Version: 1.0
In-Reply-To: <201709290457.CAC30283.VFtMFOFOJLQHOS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/28/17 12:57 PM, Tetsuo Handa wrote:
> Yang Shi wrote:
>> On 9/27/17 9:36 PM, Tetsuo Handa wrote:
>>> On 2017/09/28 6:46, Yang Shi wrote:
>>>> Changelog v7 -> v8:
>>>> * Adopted Michal’s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
>>>
>>> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
>>> because there are
>>>
>>> 	mutex_lock(&slab_mutex);
>>> 	kmalloc(GFP_KERNEL);
>>> 	mutex_unlock(&slab_mutex);
>>>
>>> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
>>> introducing a risk of crash (i.e. kernel panic) for regular OOM path?
>>
>> I don't see the difference between regular oom path and oom path other
>> than calling panic() at last.
>>
>> And, the slab dump may be called by panic path too, it is for both
>> regular and panic path.
> 
> Calling a function that might cause kerneloops immediately before calling panic()
> would be tolerable, for the kernel will panic after all. But calling a function
> that might cause kerneloops when there is no plan to call panic() is a bug.

I got your point. slab_mutex is used to protect the list of all the  
slabs, since we are already in oom, there should be not kmem cache  
destroy happen during the list traverse. And, list_for_each_entry() has  
been replaced to list_for_each_entry_safe() to make the traverse more  
robust.

Thanks,
Yang

> 
>>
>> Thanks,
>> Yang
>>
>>>
>>> We can try mutex_trylock() from dump_unreclaimable_slab() at best.
>>> But it is still remaining unsafe, isn't it?
>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
