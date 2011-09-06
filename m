Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5393E6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 18:38:20 -0400 (EDT)
Message-ID: <4E66A0A9.3060403@parallels.com>
Date: Tue, 6 Sep 2011 19:37:29 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com> <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
In-Reply-To: <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/06/2011 07:12 PM, Greg Thelen wrote:
> On Tue, Sep 6, 2011 at 9:16 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> On 09/06/2011 01:08 PM, Greg Thelen wrote:
>>>
>>> On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa<glommer@parallels.com>
>>>   wrote:
>>>>
>>>> This patch introduces per-cgroup tcp buffers limitation. This allows
>>>> sysadmins to specify a maximum amount of kernel memory that
>>>> tcp connections can use at any point in time. TCP is the main interest
>>>> in this work, but extending it to other protocols would be easy.
>>
>> Hello Greg,
>>
>>> With this approach we would be giving admins the ability to
>>> independently limit user memory with memcg and kernel memory with this
>>> new kmem cgroup.
>>>
>>> At least in some situations admins prefer to give a particular
>>> container X bytes without thinking about the kernel vs user split.
>>> Sometimes the admin would prefer the kernel to keep the total
>>> user+kernel memory below a certain threshold.  To achieve this with
>>> this approach would we need a user space agent to monitor both kernel
>>> and user usage for a container and grow/shrink memcg/kmem limits?
>>
>> Yes, I believe so. And this is not only valid for containers: the
>> information we expose in proc, sys, cgroups, etc, is always much more fine
>> grained than a considerable part of the users want. Tools come to fill this
>> gap.
>
> In your use cases do jobs separately specify independent kmem usage
> limits and user memory usage limits?

Yes, because they are different in nature: user memory can be 
overcommited, kernel memory is pinned by its objects, and can't go to swap.

> I presume for people who want to simply dedicate X bytes of memory to
> container C that a user-space agent would need to poll both
> memcg/X/memory.usage_in_bytes and kmem/X/kmem.usage_in_bytes (or some
> other file) to determine if memory limits should be adjusted (i.e. if
> kernel memory is growing, then user memory would need to shrink).
Ok.

I think memcg's usage is really all you need here. In the end of the 
day, it tells you how many pages your container has available. The whole
point of kmem cgroup is not any kind of reservation or accounting.

Once a container (or cgroup) reaches a number of objects *pinned* in 
memory (therefore, non-reclaimable), you won't be able to grab anything 
from it.
> So
> far my use cases involve a single memory limit which includes both
> kernel and user memory.  So I would need a user space agent to poll
> {memcg,kmem}.usage_in_bytes to apply pressure to memcg if kmem grows
> and visa versa.

Maybe not.
If userspace memory works for you today (supposing it does), why change?
Right now you assign X bytes of user memory to a container, and the 
kernel memory is shared among all of them. If this works for you, 
kmem_cgroup won't change that. It just will impose limits over which
your kernel objects can't grow.

So you don't *need* a userspace agent doing this calculation, because 
fundamentally, nothing changed: I am not unbilling memory in memcg to 
bill it back in kmem_cg. Of course, once it is in, you will be able to 
do it in such a fine grained fashion if you decide to do so.

> Do you foresee instantiation of multiple kmem cgroups, so that a
> process could be added into kmem/K1 or kmem/K2?  If so do you plan on
> supporting migration between cgroups and/or migration of kmem charge
> between K1 to K2?
Yes, each container should have its own cgroup, so at least in the use
cases I am concerned, we will have a lot of them. But the usual 
lifecycle, is create, execute and die. Mobility between them
is not something I am overly concerned right now.


>>> Do you foresee the kmem cgroup growing to include reclaimable slab,
>>> where freeing one type of memory allows for reclaim of the other?
>>
>> Yes, absolutely.
>
> Small comments below.
>

>>>>   };
>>>>
>>>> +#define sk_memory_pressure(sk)                                         \
>>>> +({                                                                     \
>>>> +       int *__ret = NULL;                                              \
>>>> +       if ((sk)->sk_prot->memory_pressure)                             \
>>>> +               __ret = (sk)->sk_prot->memory_pressure(sk->sk_cgrp);    \
>>>> +       __ret;                                                          \
>>>> +})
>>>> +
>>>> +#define sk_sockets_allocated(sk)                               \
>>>> +({                                                             \
>>>> +       struct percpu_counter *__p;                             \
>>>> +       __p = (sk)->sk_prot->sockets_allocated(sk->sk_cgrp);    \
>>>> +       __p;                                                    \
>>>> +})
>
> Could this be simplified as (same applies to following few macros):
>
> static inline struct percpu_counter *sk_sockets_allocated(struct sock *sk)
> {
>          return sk->sk_prot->sockets_allocated(sk->sk_cgrp);
> }
Yes and no. Right now, I need them to be valid lvalues. But in the 
upcoming version of the patch, I will drop this requirement. Then
I will move to inline functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
