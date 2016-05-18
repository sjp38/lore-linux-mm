Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD1B6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 12:28:16 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k129so113641286iof.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 09:28:16 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id r4si8360128itb.80.2016.05.18.09.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 09:28:15 -0700 (PDT)
Received: by mail-io0-x234.google.com with SMTP id d62so72054819iof.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 09:28:15 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz>
 <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz>
 <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net>
 <20160513164357.5f565d3c@lxorguk.ukuu.org.uk> <573AD534.6050703@laposte.net>
 <20160517085724.GD14453@dhcp22.suse.cz> <573B43FA.7080503@laposte.net>
 <64a74ddc-c11b-75b9-c5f6-7e46be6f2122@gmail.com>
 <573C87FB.3050301@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <59ca6360-abc4-5cc9-8873-b93cc2d8a898@gmail.com>
Date: Wed, 18 May 2016 12:28:08 -0400
MIME-Version: 1.0
In-Reply-To: <573C87FB.3050301@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

On 2016-05-18 11:19, Sebastian Frias wrote:
> Hi Austin,
>
> On 05/17/2016 07:29 PM, Austin S. Hemmelgarn wrote:
>>> I see the difference, your answer seems a bit like the one from Austin, basically:
>>> - killing a process is a sort of kernel protection attempting to deal "automatically" with some situation, like deciding what is a 'memory hog', or what is 'in infinite loop', "usually" in a correct way.
>>> It seems there's people who think its better to avoid having to take such decisions and/or they should be decided by the user, because "usually" != "always".
>> FWIW, it's really easy to see what's using a lot of memory, it's impossible to tell if something is stuck in an infinite loop without looking deep into the process state and possibly even at the source code (and even then it can be almost impossible to be certain).  This is why we have a OOM-Killer, and not a infinite-loop-killer.
>>
>> Again I reiterate, if a system is properly provisioned (that is, if you have put in enough RAM and possibly swap space to do what you want to use it for), the only reason the OOM-killer should be invoked is due to a bug.
>
> Are you sure that's the only possible reason?
> I mean, what if somebody keeps opening tabs on Firefox?
> If malloc() returned NULL maybe Firefox could say "hey, you have too many tabs open, please close some to free memory".
That's an application issue, and I'm pretty sure that most browsers do 
mention this.  That also falls within normal usage for a desktop system 
(somewhat, if you're opening more than a few dozen tabs, you're asking 
for trouble for other reasons too).
>
>> The non-default overcommit options still have the same issues they just change how and when they happen (overcommit=never will fire sooner, overcommit=always will fire later), and also can impact memory allocation performance (I have numbers somewhere that I can't find right now that demonstrated that overcommit=never gave more deterministic and (on average) marginally better malloc() performance, and simple logic would suggest that overcommit=always would make malloc() perform better too).
>>> And people who see that as a nice thing but complex thing to do.
>>> In this thread we've tried to explain why this heuristic (and/or OOM-killer) is/was needed and/or its history, which has been very enlightening by the way.
>>>
>>> From reading Documentation/cgroup-v1/memory.txt (and from a few replies here talking about cgroups), it looks like the OOM-killer is still being actively discussed, well, there's also "cgroup-v2".
>>> My understanding is that cgroup's memory control will pause processes in a given cgroup until the OOM situation is solved for that cgroup, right?
>>> If that is right, it means that there is indeed a way to deal with an OOM situation (stack expansion, COW failure, 'memory hog', etc.) in a better way than the OOM-killer, right?
>>> In which case, do you guys know if there is a way to make the whole system behave as if it was inside a cgroup? (*)
>> No, not with the process freeze behavior, because getting the group running again requires input from an external part of the system, which by definition doesn't exist if the group is the entire system;
>
> Do you mean that it pauses all processes in the cgroup?
> I thought it would pause on a case-by-case basis, like first process to reach the limit gets paused, and so on.
>
> Honestly I thought it would work a bit like the filesystems, where 'root' usually has 5% reserved, so that a process (or processes) filling the disk does not disrupt the system to the point of preventing 'root' from performing administrative actions.
>
> That makes me think, why is disk space handled differently than memory in this case? I mean, why is disk space exhaustion handled differently than memory exhaustion?
> We could imagine that both resources are required for proper system and process operation, so if OOM-killer is there to attempt to keep the system working at all costs (even if that means sacrificing processes), why isn't there an OOFS-killer (out-of-free-space killer)?
There are actually sysctl's for this, vm/{admin,user}_reserve_kbytes. 
The admin one is system-wide and provides a reserve for users with 
CAP_SYS_ADMIN.  The user one is per-process and prevents a process from 
allocating beyond a specific point, and is intended for overcommit=never 
mode.

That said, there are a couple of reasons that disk space and memory are 
handled differently:
1. The kernel needs RAM to function, it does not need disk space to 
function.  In other words, if we have no free RAM, the system is 
guaranteed to be unusable, but if we have no disk space, the system may 
or may not still be usable.
2. Freeing disk space is usually an easy decision for the user, figuring 
out what to kill to free RAM is not.
3. Most end users have at least a basic understanding of disk space 
being finite, while they don't necessarily have a similar understanding 
of memory being finite (note that I'm not talking about sysadmins and 
similar, I"m talking about people's grandmothers, and people who have no 
low-level background with computers, and people like some of my friends 
who still have trouble understanding the difference between memory and 
persistent storage)
>
>> and, because our GUI isn't built into the kernel, we can't pause things and pop up a little dialog asking the user what to do to resolve the issue.
>
> :-) Yeah, I was thinking that could be handled with the cgroups' notification system + the reserved space (like on filesystems)
> Maybe I was too optimistic (naive or just plain ignorant) about this.
Ideally, we would have something that could check against some watermark 
and notify like Windows does when virtual memory is getting low (most 
people never see this, because they let windows manage the page file, 
which means it just gleefully allocates whatever it needs on disk).  I 
don't know of a way to do that right now without polling though, and 
that level of inefficiency should ideally be avoided.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
