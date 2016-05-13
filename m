Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 053506B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 05:52:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so7076910wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 02:52:33 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz300.laposte.net. [178.22.154.200])
        by mx.google.com with ESMTPS id b203si2871198wma.5.2016.05.13.02.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 02:52:32 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout012 (Postfix) with ESMTP id 221F08CA1E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:52:32 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout012 (Postfix) with ESMTP id 121988CA30
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:52:32 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id EE8AA3669E2
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:52:31 +0200 (CEST)
Message-ID: <5735A3DE.9030100@laposte.net>
Date: Fri, 13 May 2016 11:52:30 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
In-Reply-To: <573593EE.6010502@free.fr>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

On 05/13/2016 10:44 AM, Mason wrote:
> On 13/05/2016 10:04, Michal Hocko wrote:
> 
>> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
>> [...]
>>> NOTE: I understand that the overcommit mode can be changed dynamically thru
>>> sysctl, but on embedded systems, where we know in advance that overcommit
>>> will be disabled, there's no reason to postpone such setting.
>>
>> To be honest I am not particularly happy about yet another config
>> option. At least not without a strong reason (the one above doesn't
>> sound that way). The config space is really large already.
>> So why a later initialization matters at all? Early userspace shouldn't
>> consume too much address space to blow up later, no?

By the way, do you know what's the rationale to allow this setting to be controlled by the userspace dynamically?
Was it for testing only?

> 
> One thing I'm not quite clear on is: why was the default set
> to over-commit on?

Indeed, I was hoping we could throw some light into that.
My patch had another note:

   "NOTE2: I tried to track down the history of overcommit but back then there
were no single patches apparently and the patch that appears to have
introduced the first overcommit mode (OVERCOMMIT_ALWAYS) is commit
9334eab8a36f ("Import 2.1.27"). OVERCOMMIT_NEVER was introduced with commit
502bff0685b2 ("[PATCH] strict overcommit").
My understanding is that prior to commit 9334eab8a36f ("Import 2.1.27")
there was no overcommit, is that correct?"

It'd be nice to know more about why was overcommit introduced.
Furthermore, it looks like allowing overcommit and the introduction of the OOM-killer has given rise to lots of other options to try to tame the OOM-killer.
Without context, that may seem like a form of "feature creep" around it.
Moreover, it makes Linux behave differently from let's say Solaris.

   https://www.win.tue.nl/~aeb/linux/lk/lk-9.html#ss9.6

Hopefully this discussion could clear some of this up and maybe result in more documentation around this subject.

> 
> I suppose the biggest use-case is when a "large" process forks
> only to exec microseconds later into a "small" process, it would
> be silly to refuse that fork. But isn't that what the COW
> optimization addresses, without the need for over-commit?
> 
> Another issue with overcommit=on is that some programmers seem
> to take for granted that "allocations will never fail" and so
> neglect to handle malloc == NULL conditions gracefully.
> 
> I tried to run LTP with overcommit off, and I vaguely recall that
> I had more failures than with overcommit on. (Perhaps only those
> tests that tickle the dreaded OOM assassin.)

>From what I remember, one of the LTP maintainers said that it is highly unlikely people test (or run LTP for that matter) with different settings for overcommit.

Years ago, while using MacOS X, a long running process apparently took all the memory over night.
The next day when I checked the computer I saw a dialog that said something like (I don't remember the exact wording) "process X has been paused due to lack of memory (or is requesting too much memory, I don't remember). If you think this is not normal you can terminate process X, otherwise you can terminate other processes to free memory and unpause process X to continue" and then some options to proceed.

If left unattended (thus the dialog unanswered), the computer would still work, all other processes were left intact and only the "offending" process was paused.
Arguably, if the "offending" process is just left paused, it takes the memory away from other processes, and if it was a server, maybe it wouldn't have enough memory to reply to requests.
On the server world I can thus understand that some setting could indicate that when the situation arises, the "dialog" is automatically dismissed with some default action, like "terminate the offending process".

To me it seems really strange for the "OOM-killer" to exist.
It has happened to me that it kills my terminals or editors, how can people deal with random processes being killed?
Doesn't it bother anybody?

Best regards,

Sebastian



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
