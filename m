Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 294596B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 06:42:14 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id f14so26515114lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 03:42:14 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz26.laposte.net. [194.117.213.101])
        by mx.google.com with ESMTPS id k3si21557534wjj.26.2016.05.13.03.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 03:42:12 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 615A3120383
	for <linux-mm@kvack.org>; Fri, 13 May 2016 12:42:12 +0200 (CEST)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.prosodie [10.128.63.4])
	by lpn-prd-vrout014 (Postfix) with ESMTP id E73C31201C3
	for <linux-mm@kvack.org>; Fri, 13 May 2016 12:42:10 +0200 (CEST)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
	by lpn-prd-vrin003 (Postfix) with ESMTP id D18BB48DDA7
	for <linux-mm@kvack.org>; Fri, 13 May 2016 12:42:10 +0200 (CEST)
Message-ID: <5735AF81.7010803@laposte.net>
Date: Fri, 13 May 2016 12:42:09 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr>
In-Reply-To: <5735AA0E.5060605@free.fr>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

On 05/13/2016 12:18 PM, Mason wrote:
> On 13/05/2016 11:52, Michal Hocko wrote:
>> On Fri 13-05-16 10:44:30, Mason wrote:
>>> On 13/05/2016 10:04, Michal Hocko wrote:
>>>
>>>> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
>>>> [...]
>>>>> NOTE: I understand that the overcommit mode can be changed dynamically thru
>>>>> sysctl, but on embedded systems, where we know in advance that overcommit
>>>>> will be disabled, there's no reason to postpone such setting.
>>>>
>>>> To be honest I am not particularly happy about yet another config
>>>> option. At least not without a strong reason (the one above doesn't
>>>> sound that way). The config space is really large already.
>>>> So why a later initialization matters at all? Early userspace shouldn't
>>>> consume too much address space to blow up later, no?
>>>
>>> One thing I'm not quite clear on is: why was the default set
>>> to over-commit on?
>>
>> Because many applications simply rely on large and sparsely used address
>> space, I guess.
> 
> What kind of applications are we talking about here?
> 
> Server apps? Client apps? Supercomputer apps?
> 
> I heard some HPC software use large sparse matrices, but is it a common
> idiom to request large allocations, only to use a fraction of it?
> 

Let's say there are specific applications that require overcommit.
Shouldn't overcommit be changed for those specific circumstances?
In other words, why is overcommit=GUESS default for everybody?

> If you'll excuse the slight trolling, I'm sure many applications don't
> expect being randomly zapped by the OOM killer ;-)
> 
>> That's why the default is GUESS where we ignore the cumulative
>> charges and simply check the current state and blow up only when
>> the current request is way too large.
> 
> I wouldn't call denying a request "blowing up". Application will
> receive NULL, and is supposed to handle it gracefully.
> 
> "Blowing up" is receiving SIGKILL because another process happened
> to allocate too much memory.

I agree.
Furthermore, the "blow up when the current request is too large" is more complex than that due to delay between the allocation and the time when the system realises it cannot honour the promise, there must be lots of code/heuristics involved there.
Anyway, it'd be nice to understand the real history behind overcommit (as I stated earlier, my understanding of the history is that in the early days there was no overcommit) and why it is there by default if only specific applications would require it.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
