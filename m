Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 778E26B0253
	for <linux-mm@kvack.org>; Tue, 17 May 2016 12:17:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so13718253wme.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 09:17:01 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz26.laposte.net. [194.117.213.101])
        by mx.google.com with ESMTPS id 137si27441337wmp.46.2016.05.17.09.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 09:17:00 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id BDBC6120B66
	for <linux-mm@kvack.org>; Tue, 17 May 2016 18:16:59 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout014 (Postfix) with ESMTP id B97A51209A4
	for <linux-mm@kvack.org>; Tue, 17 May 2016 18:16:59 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id A9CF0366A2C
	for <linux-mm@kvack.org>; Tue, 17 May 2016 18:16:59 +0200 (CEST)
Message-ID: <573B43FA.7080503@laposte.net>
Date: Tue, 17 May 2016 18:16:58 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz> <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz> <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net> <20160513164357.5f565d3c@lxorguk.ukuu.org.uk> <573AD534.6050703@laposte.net> <20160517085724.GD14453@dhcp22.suse.cz>
In-Reply-To: <20160517085724.GD14453@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

Hi Michal,

On 05/17/2016 10:57 AM, Michal Hocko wrote:
> On Tue 17-05-16 10:24:20, Sebastian Frias wrote:
> [...]
>>>> Also, under what conditions would copy-on-write fail?
>>>
>>> When you have no memory or swap pages free and you touch a COW page that
>>> is currently shared. At that point there is no resource to back to the
>>> copy so something must die - either the process doing the copy or
>>> something else.
>>
>> Exactly, and why does "killing something else" makes more sense (or
>> was chosen over) "killing the process doing the copy"?
> 
> Because that "something else" is usually a memory hog and so chances are
> that the out of memory situation will get resolved. If you kill "process
> doing the copy" then you might end up just not getting any memory back
> because that might be a little forked process which doesn't own all that
> much memory on its own. That would leave you in the oom situation for a
> long time until somebody actually sitting on some memory happens to ask
> for CoW... See the difference?
> 

I see the difference, your answer seems a bit like the one from Austin, basically:
- killing a process is a sort of kernel protection attempting to deal "automatically" with some situation, like deciding what is a 'memory hog', or what is 'in infinite loop', "usually" in a correct way.
It seems there's people who think its better to avoid having to take such decisions and/or they should be decided by the user, because "usually" != "always".
And people who see that as a nice thing but complex thing to do.
In this thread we've tried to explain why this heuristic (and/or OOM-killer) is/was needed and/or its history, which has been very enlightening by the way.

>From reading Documentation/cgroup-v1/memory.txt (and from a few replies here talking about cgroups), it looks like the OOM-killer is still being actively discussed, well, there's also "cgroup-v2".
My understanding is that cgroup's memory control will pause processes in a given cgroup until the OOM situation is solved for that cgroup, right?
If that is right, it means that there is indeed a way to deal with an OOM situation (stack expansion, COW failure, 'memory hog', etc.) in a better way than the OOM-killer, right?
In which case, do you guys know if there is a way to make the whole system behave as if it was inside a cgroup? (*)

Best regards,

Sebastian


(*): I tried setting up a simple test but failed, so I think I need more reading :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
