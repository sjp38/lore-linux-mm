Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 817596B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 17:58:58 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so11205060wiw.8
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:58:57 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id df5si14021485wjb.42.2014.06.05.14.58.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 14:58:57 -0700 (PDT)
Message-ID: <5390E819.2070709@nod.at>
Date: Thu, 05 Jun 2014 23:58:49 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at> <20140605150025.GB15939@dhcp22.suse.cz> <5390930A.8050504@nod.at> <20140605161807.GD15939@dhcp22.suse.cz>
In-Reply-To: <20140605161807.GD15939@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Am 05.06.2014 18:18, schrieb Michal Hocko:
> On Thu 05-06-14 17:55:54, Richard Weinberger wrote:
>> Am 05.06.2014 17:00, schrieb Michal Hocko:
>>> On Thu 05-06-14 16:00:41, Richard Weinberger wrote:
>>>> Don't spam the kernel logs if the oom_control event fd has listeners.
>>>> In this case there is no need to print that much lines as user space
>>>> will anyway notice that the memory cgroup has reached its limit.
>>>
>>> But how do you debug why it is reaching the limit and why a particular
>>> process has been killed?
>>
>> In my case it's always because customer's Java application gone nuts.
>> So I don't really have to debug a lot. ;-)
>> But I can understand your point.
> 
> If you know that handling memcg-OOM condition is easy then maybe you can
> not only listen for the OOM notifications but also handle OOM conditions
> and kill the offender. This would mean that kernel doesn't try to kill
> anything and so wouldn't dump anything to the log.

Basically I don't care what customers run in their containers.
But almost every OOM is because their Java apps consume too much memory.
Mostly because they don't know exactly how much memory they need or
because of completely broken JVM heap settings.

All my OOM listener does is sending a mail a la "Your container ran out of memory, go figure...".

>>> If we are printing too much then OK, let's remove those parts which are
>>> not that useful but hiding information which tells us more about the oom
>>> decision doesn't sound right to me.
>>
>> What about adding a sysctl like "vm.oom_verbose"?
>> By default it would be 1.
>> If set to 0 the full OOM information is only printed out if nobody listens
>> to the event fd.
> 
> If we have a knob then I guess it should be global and shared by memcg
> as well. I can imagine that somebody might be interested only in the
> tasks dump, while somebody would like to see LRU states and other memory
> counters. So it would be ideally a bitmask of things to output. I do not
> think that a memcg specific solution is good, though.

I'm not sure if such a fine grained setting is really useful.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
