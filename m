Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id D9D886B009E
	for <linux-mm@kvack.org>; Wed,  7 May 2014 18:39:58 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so1885076qga.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:39:58 -0700 (PDT)
Received: from mail.siteground.com (mail.siteground.com. [67.19.240.234])
        by mx.google.com with ESMTPS id 35si4590588qgy.136.2014.05.07.15.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 15:39:57 -0700 (PDT)
Message-ID: <536AB626.9070005@1h.com>
Date: Thu, 08 May 2014 01:39:34 +0300
From: Marian Marinov <mm@1h.com>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140416154650.GA3034@alpha.arachsys.com>	<20140418155939.GE4523@dhcp22.suse.cz>	<5351679F.5040908@parallels.com>	<20140420142830.GC22077@alpha.arachsys.com>	<20140422143943.20609800@oracle.com>	<20140422200531.GA19334@alpha.arachsys.com>	<535758A0.5000500@yuhu.biz> <20140423084942.560ae837@oracle.com>	<5368CA47.7030007@yuhu.biz> <20140507131514.43716518@oracle.com>
In-Reply-To: <20140507131514.43716518@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dwight Engen <dwight.engen@oracle.com>, Marian Marinov <mm@yuhu.biz>
Cc: Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Daniel Walsh <dwalsh@redhat.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On 05/07/2014 08:15 PM, Dwight Engen wrote:
> On Tue, 06 May 2014 14:40:55 +0300
> Marian Marinov <mm@yuhu.biz> wrote:
>
>> On 04/23/2014 03:49 PM, Dwight Engen wrote:
>>> On Wed, 23 Apr 2014 09:07:28 +0300
>>> Marian Marinov <mm@yuhu.biz> wrote:
>>>
>>>> On 04/22/2014 11:05 PM, Richard Davies wrote:
>>>>> Dwight Engen wrote:
>>>>>> Richard Davies wrote:
>>>>>>> Vladimir Davydov wrote:
>>>>>>>> In short, kmem limiting for memory cgroups is currently broken.
>>>>>>>> Do not use it. We are working on making it usable though.
>>>>> ...
>>>>>>> What is the best mechanism available today, until kmem limits
>>>>>>> mature?
>>>>>>>
>>>>>>> RLIMIT_NPROC exists but is per-user, not per-container.
>>>>>>>
>>>>>>> Perhaps there is an up-to-date task counter patchset or similar?
>>>>>>
>>>>>> I updated Frederic's task counter patches and included Max
>>>>>> Kellermann's fork limiter here:
>>>>>>
>>>>>> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>>>>>>
>>>>>> I can send you a more recent patchset (against 3.13.10) if you
>>>>>> would find it useful.
>>>>>
>>>>> Yes please, I would be interested in that. Ideally even against
>>>>> 3.14.1 if you have that too.
>>>>
>>>> Dwight, do you have these patches in any public repo?
>>>>
>>>> I would like to test them also.
>>>
>>> Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
>>>
>>> git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
>>> git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
>>>
>> Guys I tested the patches with 3.12.16. However I see a problem with
>> them.
>>
>> Trying to set the limit to a cgroup which already have processes in
>> it does not work:
>
> This is a similar check/limitation to the one for kmem in memcg, and is
> done here to keep the res_counters consistent and from going negative.
> It could probably be relaxed slightly by using res_counter_set_limit()
> instead, but you would still need to initially set a limit before
> adding tasks to the group.

I have removed the check entirely and still receive the EBUSY... I just don't understand what is returning it. If you 
have any pointers, I would be happy to take a look.

I'll look at set_limit(), thanks for pointing that one.

What I'm proposing is the following checks:

     if (val > RES_COUNTER_MAX || val < 0)
         return -EBUSY;
     if (val != 0 && val <= cgroup_task_count(cgrp))
         return -EBUSY;

     res_counter_write_u64(&ca->task_limit, type, val);

This way we ensure that val is within the limits > 0 and < RES_COUNTER_MAX. And also allow only values of 0 or greater 
then the current task count.

Marian
>
>> [root@sp2 lxc]# echo 50 > cpuacct.task_limit
>> -bash: echo: write error: Device or resource busy
>> [root@sp2 lxc]# echo 0 > cpuacct.task_limit
>> -bash: echo: write error: Device or resource busy
>> [root@sp2 lxc]#
>>
>> I have even tried to remove this check:
>> +               if (cgroup_task_count(cgrp)
>> || !list_empty(&cgrp->children))
>> +                       return -EBUSY;
>> But still give me 'Device or resource busy'.
>>
>> Any pointers of why is this happening ?
>>
>> Marian
>>
>>>> Marian
>>>>
>>>>>
>>>>> Thanks,
>>>>>
>>>>> Richard.
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe cgroups"
>>>>> in the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>>
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe cgroups"
>>> in the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>


-- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman@jabber.org
ICQ: 7556201
Mobile: +359 886 660 270

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
