Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8BD36B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 11:18:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a17so16396548wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 08:18:55 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz300.laposte.net. [178.22.154.200])
        by mx.google.com with ESMTPS id r6si11047785wjc.46.2016.05.18.08.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 08:18:54 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout012 (Postfix) with ESMTP id EF5928CA2D
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:18:53 +0200 (CEST)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.laposte [10.128.63.4])
	by lpn-prd-vrout012 (Postfix) with ESMTP id EA6728CA2C
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:18:53 +0200 (CEST)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
	by lpn-prd-vrin003 (Postfix) with ESMTP id DAF1648DEA7
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:18:53 +0200 (CEST)
Message-ID: <573C87D5.6070304@laposte.net>
Date: Wed, 18 May 2016 17:18:45 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz> <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz> <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net> <20160513164357.5f565d3c@lxorguk.ukuu.org.uk> <573AD534.6050703@laposte.net> <20160517085724.GD14453@dhcp22.suse.cz> <573B43FA.7080503@laposte.net> <20160517201605.GC12220@dhcp22.suse.cz>
In-Reply-To: <20160517201605.GC12220@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

Hi Michal,

On 05/17/2016 10:16 PM, Michal Hocko wrote:
> On Tue 17-05-16 18:16:58, Sebastian Frias wrote:
> [...]
>> From reading Documentation/cgroup-v1/memory.txt (and from a few
>> replies here talking about cgroups), it looks like the OOM-killer is
>> still being actively discussed, well, there's also "cgroup-v2".
>> My understanding is that cgroup's memory control will pause processes
>> in a given cgroup until the OOM situation is solved for that cgroup,
>> right?
> 
> It will be blocked waiting either for some external action which would
> result in OOM codition going away or any other charge release. You have
> to configure memcg for that though. The default behavior is to invoke
> the same OOM killer algorithm which is just reduced to tasks from the
> memcg (hierarchy).

Ok, I see, thanks!

> 
>> If that is right, it means that there is indeed a way to deal
>> with an OOM situation (stack expansion, COW failure, 'memory hog',
>> etc.) in a better way than the OOM-killer, right?
>> In which case, do you guys know if there is a way to make the whole
>> system behave as if it was inside a cgroup? (*)
> 
> No it is not. You have to realize that the system wide and the memcg OOM
> situations are quite different. There is usually quite some memory free
> when you hit the memcg OOM so the administrator can actually do
> something. 

Ok, so it works like the 5% reserved for 'root' on filesystems?

>The global OOM means there is _no_ memory at all. Many kernel
> operations will need some memory to do something useful. Let's say you
> would want to do an educated guess about who to kill - most proc APIs
> will need to allocate. And this is just a beginning. Things are getting
> really nasty when you get deeper and deeper. E.g. the OOM killer has to
> give the oom victim access to memory reserves so that the task can exit
> because that path needs to allocate as well. 

Really? I would have thought that once that SIGKILL is sent, the victim process is not expected to do anything else and thus its memory could be claimed immediately.
Or the OOM-killer is more of a OOM-terminator? (i.e.: sends SIGTERM)

>So even if you wanted to
> give userspace some chance to resolve the OOM situation you would either
> need some special API to tell "this process is really special and it can
> access memory reserves and it has an absolute priority etc." or have a
> in kernel fallback to do something or your system could lockup really
> easily.
> 

I see, so basically at least two cgroups would be needed, one reserved for handling the OOM situation through some API and another for the "rest of the system".
Basically just like the 5% reserved for 'root' on filesystems.
Do you think that would work?

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
