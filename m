Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC716B0253
	for <linux-mm@kvack.org>; Wed, 18 May 2016 11:19:26 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ga2so25459024lbc.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 08:19:26 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz26.laposte.net. [194.117.213.101])
        by mx.google.com with ESMTPS id 71si33851075wmo.92.2016.05.18.08.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 08:19:24 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 3F8A611F13E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:19:24 +0200 (CEST)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 3A1C211F05C
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:19:24 +0200 (CEST)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
	by lpn-prd-vrin002 (Postfix) with ESMTP id 214D95BF0BC
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:19:24 +0200 (CEST)
Message-ID: <573C87FB.3050301@laposte.net>
Date: Wed, 18 May 2016 17:19:23 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz> <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz> <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net> <20160513164357.5f565d3c@lxorguk.ukuu.org.uk> <573AD534.6050703@laposte.net> <20160517085724.GD14453@dhcp22.suse.cz> <573B43FA.7080503@laposte.net> <64a74ddc-c11b-75b9-c5f6-7e46be6f2122@gmail.com>
In-Reply-To: <64a74ddc-c11b-75b9-c5f6-7e46be6f2122@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

Hi Austin,

On 05/17/2016 07:29 PM, Austin S. Hemmelgarn wrote:
>> I see the difference, your answer seems a bit like the one from Austin, basically:
>> - killing a process is a sort of kernel protection attempting to deal "automatically" with some situation, like deciding what is a 'memory hog', or what is 'in infinite loop', "usually" in a correct way.
>> It seems there's people who think its better to avoid having to take such decisions and/or they should be decided by the user, because "usually" != "always".
> FWIW, it's really easy to see what's using a lot of memory, it's impossible to tell if something is stuck in an infinite loop without looking deep into the process state and possibly even at the source code (and even then it can be almost impossible to be certain).  This is why we have a OOM-Killer, and not a infinite-loop-killer.
> 
> Again I reiterate, if a system is properly provisioned (that is, if you have put in enough RAM and possibly swap space to do what you want to use it for), the only reason the OOM-killer should be invoked is due to a bug. 

Are you sure that's the only possible reason?
I mean, what if somebody keeps opening tabs on Firefox?
If malloc() returned NULL maybe Firefox could say "hey, you have too many tabs open, please close some to free memory".

> The non-default overcommit options still have the same issues they just change how and when they happen (overcommit=never will fire sooner, overcommit=always will fire later), and also can impact memory allocation performance (I have numbers somewhere that I can't find right now that demonstrated that overcommit=never gave more deterministic and (on average) marginally better malloc() performance, and simple logic would suggest that overcommit=always would make malloc() perform better too).
>> And people who see that as a nice thing but complex thing to do.
>> In this thread we've tried to explain why this heuristic (and/or OOM-killer) is/was needed and/or its history, which has been very enlightening by the way.
>>
>> From reading Documentation/cgroup-v1/memory.txt (and from a few replies here talking about cgroups), it looks like the OOM-killer is still being actively discussed, well, there's also "cgroup-v2".
>> My understanding is that cgroup's memory control will pause processes in a given cgroup until the OOM situation is solved for that cgroup, right?
>> If that is right, it means that there is indeed a way to deal with an OOM situation (stack expansion, COW failure, 'memory hog', etc.) in a better way than the OOM-killer, right?
>> In which case, do you guys know if there is a way to make the whole system behave as if it was inside a cgroup? (*)
> No, not with the process freeze behavior, because getting the group running again requires input from an external part of the system, which by definition doesn't exist if the group is the entire system; 

Do you mean that it pauses all processes in the cgroup?
I thought it would pause on a case-by-case basis, like first process to reach the limit gets paused, and so on.

Honestly I thought it would work a bit like the filesystems, where 'root' usually has 5% reserved, so that a process (or processes) filling the disk does not disrupt the system to the point of preventing 'root' from performing administrative actions.

That makes me think, why is disk space handled differently than memory in this case? I mean, why is disk space exhaustion handled differently than memory exhaustion?
We could imagine that both resources are required for proper system and process operation, so if OOM-killer is there to attempt to keep the system working at all costs (even if that means sacrificing processes), why isn't there an OOFS-killer (out-of-free-space killer)?

>and, because our GUI isn't built into the kernel, we can't pause things and pop up a little dialog asking the user what to do to resolve the issue.

:-) Yeah, I was thinking that could be handled with the cgroups' notification system + the reserved space (like on filesystems)
Maybe I was too optimistic (naive or just plain ignorant) about this.

Best regards,

Sebastian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
