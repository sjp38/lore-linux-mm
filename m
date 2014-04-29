Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 46A926B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 17:36:44 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so716992eek.37
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:36:43 -0700 (PDT)
Received: from BlackPearl.yuhu.biz (mail.bgservers.net. [85.14.7.126])
        by mx.google.com with ESMTP id 43si28364790eer.147.2014.04.29.14.36.41
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 14:36:42 -0700 (PDT)
Message-ID: <53601B68.60906@yuhu.biz>
Date: Wed, 30 Apr 2014 00:36:40 +0300
From: Marian Marinov <mm@yuhu.biz>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140428180025.GC25689@ubuntumail> <20140429072515.GB15058@dhcp22.suse.cz> <20140429130353.GA27354@ubuntumail> <20140429154345.GH15058@dhcp22.suse.cz> <CAO_RewYZDGLBAKit4CudTbqVk+zfDRX8kP0W6Zz90xJh7abM9Q@mail.gmail.com> <20140429165114.GE6129@localhost.localdomain> <CAO_Rewa20dneL8e3T4UPnu2Dkv28KTgFJR9_YSmRBKp-_yqewg@mail.gmail.com> <20140429170639.GA25609@dhcp22.suse.cz> <20140429133039.162d9dd7@oracle.com> <20140429180927.GB29606@alpha.arachsys.com> <20140429182742.GB25609@dhcp22.suse.cz>
In-Reply-To: <20140429182742.GB25609@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Richard Davies <richard@arachsys.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Tim Hockin <thockin@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Serge Hallyn <serge.hallyn@ubuntu.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Daniel Walsh <dwalsh@redhat.com>

On 04/29/2014 09:27 PM, Michal Hocko wrote:
> On Tue 29-04-14 19:09:27, Richard Davies wrote:
>> Dwight Engen wrote:
>>> Michal Hocko wrote:
>>>> Tim Hockin wrote:
>>>>> Here's the reason it doesn't work for us: It doesn't work.
>>>>
>>>> There is a "simple" solution for that. Help us to fix it.
>>>>
>>>>> It was something like 2 YEARS since we first wanted this, and it
>>>>> STILL does not work.
>>>>
>>>> My recollection is that it was primarily Parallels and Google asking
>>>> for the kmem accounting. The reason why I didn't fight against
>>>> inclusion although the implementation at the time didn't have a
>>>> proper slab shrinking implemented was that that would happen later.
>>>> Well, that later hasn't happened yet and we are slowly getting there.
>>>>
>>>>> You're postponing a pretty simple request indefinitely in
>>>>> favor of a much more complex feature, which still doesn't really
>>>>> give me what I want.
>>>>
>>>> But we cannot simply add a new interface that will have to be
>>>> maintained for ever just because something else that is supposed to
>>>> workaround bugs.
>>>>
>>>>> What I want is an API that works like rlimit but per-cgroup, rather
>>>>> than per-UID.
>>>>
>>>> You can use an out-of-tree patchset for the time being or help to get
>>>> kmem into shape. If there are principal reasons why kmem cannot be
>>>> used then you better articulate them.
>>>
>>> Is there a plan to separately account/limit stack pages vs kmem in
>>> general? Richard would have to verify, but I suspect kmem is not currently
>>> viable as a process limiter for him because icache/dcache/stack is all
>>> accounted together.
>>
>> Certainly I would like to be able to limit container fork-bombs without
>> limiting the amount of disk IO caching for processes in those containers.
>>
>> In my testing with of kmem limits, I needed a limit of 256MB or lower to
>> catch fork bombs early enough. I would definitely like more than 256MB of
>> disk caching.
>>
>> So if we go the "working kmem" route, I would like to be able to specify a
>> limit excluding disk cache.
>
> Page cache (which is what you mean by disk cache probably) is a
> userspace accounted memory with the memory cgroup controller. And you
> do not have to limit that one. Kmem accounting refers to kernel internal
> allocations - slab memory and per process kernel stack. You can see how
> much memory is allocated per container by memory.kmem.usage_in_bytes or
> have a look at /proc/slabinfo to see what kind of memory kernel
> allocates globally and might be accounted for a container as well.
>
> The primary problem with the kmem accounting right now is that such a
> memory is not "reclaimed" and so if the kmem limit is reached all the
> further kmem allocations fail. The biggest user of the kmem allocations
> on many systems is dentry and inode chache which is reclaimable easily.
> When this is implemented the kmem limit will be usable to both prevent
> forkbombs but also other DOS scenarios when the kernel is pushed to
> allocate a huge amount of memory.

I would have to disagree here.
If a container starts to create many processes it will use kmem, however my use cases, the memory is not the problem.
The simple scheduling of so many processes generates have load on the machine.
Even if I have the memory to handle this... the problem becomes the scheduling of all of these processes.

Typical rsync of 2-3TB of small files(1-100k) will generate heavy pressure on the kmem, but will would not produce many 
processes.
On the other hand, forking thousands of processes with low memory footprint will hit the scheduler a lot faster then 
hitting the kmem limit.

Kmem limit is something that we need! But firmly believe that we need a simple NPROC limit for cgroups.

-hackman

>
> HTH
>
>> I am also somewhat worried that normal software use could legitimately go
>> above 256MB of kmem (even excluding disk cache) - I got to 50MB in testing
>> just by booting a distro with a few daemons in a container.
>>
>> Richard.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
