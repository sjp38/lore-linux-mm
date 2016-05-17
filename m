Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D64E26B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 13:29:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x67so37668696oix.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 10:29:36 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id g5si1693126otb.34.2016.05.17.10.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 10:29:35 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id i75so32628366ioa.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 10:29:35 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz>
 <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz>
 <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net>
 <20160513164357.5f565d3c@lxorguk.ukuu.org.uk> <573AD534.6050703@laposte.net>
 <20160517085724.GD14453@dhcp22.suse.cz> <573B43FA.7080503@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <64a74ddc-c11b-75b9-c5f6-7e46be6f2122@gmail.com>
Date: Tue, 17 May 2016 13:29:31 -0400
MIME-Version: 1.0
In-Reply-To: <573B43FA.7080503@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

On 2016-05-17 12:16, Sebastian Frias wrote:
> Hi Michal,
>
> On 05/17/2016 10:57 AM, Michal Hocko wrote:
>> On Tue 17-05-16 10:24:20, Sebastian Frias wrote:
>> [...]
>>>>> Also, under what conditions would copy-on-write fail?
>>>>
>>>> When you have no memory or swap pages free and you touch a COW page that
>>>> is currently shared. At that point there is no resource to back to the
>>>> copy so something must die - either the process doing the copy or
>>>> something else.
>>>
>>> Exactly, and why does "killing something else" makes more sense (or
>>> was chosen over) "killing the process doing the copy"?
>>
>> Because that "something else" is usually a memory hog and so chances are
>> that the out of memory situation will get resolved. If you kill "process
>> doing the copy" then you might end up just not getting any memory back
>> because that might be a little forked process which doesn't own all that
>> much memory on its own. That would leave you in the oom situation for a
>> long time until somebody actually sitting on some memory happens to ask
>> for CoW... See the difference?
>>
>
> I see the difference, your answer seems a bit like the one from Austin, basically:
> - killing a process is a sort of kernel protection attempting to deal "automatically" with some situation, like deciding what is a 'memory hog', or what is 'in infinite loop', "usually" in a correct way.
> It seems there's people who think its better to avoid having to take such decisions and/or they should be decided by the user, because "usually" != "always".
FWIW, it's really easy to see what's using a lot of memory, it's 
impossible to tell if something is stuck in an infinite loop without 
looking deep into the process state and possibly even at the source code 
(and even then it can be almost impossible to be certain).  This is why 
we have a OOM-Killer, and not a infinite-loop-killer.

Again I reiterate, if a system is properly provisioned (that is, if you 
have put in enough RAM and possibly swap space to do what you want to 
use it for), the only reason the OOM-killer should be invoked is due to 
a bug.  The non-default overcommit options still have the same issues 
they just change how and when they happen (overcommit=never will fire 
sooner, overcommit=always will fire later), and also can impact memory 
allocation performance (I have numbers somewhere that I can't find right 
now that demonstrated that overcommit=never gave more deterministic and 
(on average) marginally better malloc() performance, and simple logic 
would suggest that overcommit=always would make malloc() perform better 
too).
> And people who see that as a nice thing but complex thing to do.
> In this thread we've tried to explain why this heuristic (and/or OOM-killer) is/was needed and/or its history, which has been very enlightening by the way.
>
> From reading Documentation/cgroup-v1/memory.txt (and from a few replies here talking about cgroups), it looks like the OOM-killer is still being actively discussed, well, there's also "cgroup-v2".
> My understanding is that cgroup's memory control will pause processes in a given cgroup until the OOM situation is solved for that cgroup, right?
> If that is right, it means that there is indeed a way to deal with an OOM situation (stack expansion, COW failure, 'memory hog', etc.) in a better way than the OOM-killer, right?
> In which case, do you guys know if there is a way to make the whole system behave as if it was inside a cgroup? (*)
No, not with the process freeze behavior, because getting the group 
running again requires input from an external part of the system, which 
by definition doesn't exist if the group is the entire system; and, 
because our GUI isn't built into the kernel, we can't pause things and 
pop up a little dialog asking the user what to do to resolve the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
