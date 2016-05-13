Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61CA46B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:39:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so38049037lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:39:04 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz29.laposte.net. [194.117.213.104])
        by mx.google.com with ESMTPS id a141si3534641wmd.7.2016.05.13.05.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:39:03 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout017 (Postfix) with ESMTP id 92835A01537
	for <linux-mm@kvack.org>; Fri, 13 May 2016 14:39:02 +0200 (CEST)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.prosodie [10.128.63.5])
	by lpn-prd-vrout017 (Postfix) with ESMTP id 8FC95A0150E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 14:39:02 +0200 (CEST)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id 786C770FF7A
	for <linux-mm@kvack.org>; Fri, 13 May 2016 14:39:02 +0200 (CEST)
Message-ID: <5735CAE5.5010104@laposte.net>
Date: Fri, 13 May 2016 14:39:01 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
In-Reply-To: <20160513120042.GK20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

On 05/13/2016 02:00 PM, Michal Hocko wrote:
> On Fri 13-05-16 11:52:30, Sebastian Frias wrote:
>>
>> By the way, do you know what's the rationale to allow this setting to
>> be controlled by the userspace dynamically?  Was it for testing only?
> 
> Dunno, but I guess the default might be just too benevolent for some
> specific workloads which are not so wasteful to their address space
> and the strict overcommit is really helpful for them.
> 

Exactly. That's why I was wondering what is the history behind enabling it by default.

> OVERCOMMIT_ALWAYS is certainly useful for testing.
> 
>>> One thing I'm not quite clear on is: why was the default set
>>> to over-commit on?
>>
>> Indeed, I was hoping we could throw some light into that.
>> My patch had another note:
> 
> I cannot really tell because this was way before my time but I guess the
> reason was that userspace is usually very address space hungry while the
> actual memory consumption is not that bad. See my other email.

Yes, I saw that, thanks for the example.
It's just that it feels like the default value is there to deal with (what it should be?) very specific cases, right?

>> It'd be nice to know more about why was overcommit introduced.
>> Furthermore, it looks like allowing overcommit and the introduction of the OOM-killer has given rise to lots of other options to try to tame the OOM-killer.
>> Without context, that may seem like a form of "feature creep" around it.
>> Moreover, it makes Linux behave differently from let's say Solaris.
>>
>>    https://www.win.tue.nl/~aeb/linux/lk/lk-9.html#ss9.6
> 
> Well, those are some really strong statements which do not really
> reflect the reality of the linux userspace. I am not going to argue with
> those points because it doesn't make much sense. Yes in an ideal world
> everybody consumes only so much he needs. Well the real life is a bit
> different...

:-)
I see, so basically it is a sort of workaround.

Anyway, in the embedded world the memory and system requirements are usually controlled.

Would you agree to the option if it was dependent on CONFIG_EMBEDDED? Or if it was a hidden option?
(I understand though that it wouldn't affect the size of config space)

> 
>> Hopefully this discussion could clear some of this up and maybe result
>> in more documentation around this subject.
> 
> What kind of documentation would help?

Well, mostly the history of this setting, why it was introduced, etc. more or less what we are discussing here.
Because honestly, killing random processes does not seems like a straightforward idea, ie: it is not obvious.
Like I was saying, without context, such behaviour looks a bit crazy.

>>
>> From what I remember, one of the LTP maintainers said that it is
>> highly unlikely people test (or run LTP for that matter) with
>> different settings for overcommit.
> 
> Yes this is sad and the result of a excessive configuration space.
> That's why I was pushing back to adding yet another one without having
> really good reasons...

Well, a more urgent problem would be that in that case overcommit=never is not really well tested.

> 
>> Years ago, while using MacOS X, a long running process apparently took
>> all the memory over night.  The next day when I checked the computer
>> I saw a dialog that said something like (I don't remember the exact
>> wording) "process X has been paused due to lack of memory (or is
>> requesting too much memory, I don't remember). If you think this is
>> not normal you can terminate process X, otherwise you can terminate
>> other processes to free memory and unpause process X to continue" and
>> then some options to proceed.
>>
>> If left unattended (thus the dialog unanswered), the computer would
>> still work, all other processes were left intact and only the
>> "offending" process was paused.  Arguably, if the "offending" process
>> is just left paused, it takes the memory away from other processes,
>> and if it was a server, maybe it wouldn't have enough memory to reply
>> to requests.  On the server world I can thus understand that some
>> setting could indicate that when the situation arises, the "dialog" is
>> automatically dismissed with some default action, like "terminate the
>> offending process".
> 
> Not sure what you are trying to tell here but it seems like killing such
> a leaking task is a better option as the memory can be reused for others
> rather than keep it blocked for an unbounded amount of time.

My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.

> 
>> To me it seems really strange for the "OOM-killer" to exist.  It has
>> happened to me that it kills my terminals or editors, how can people
>> deal with random processes being killed?  Doesn't it bother anybody?
> 
> Killing random tasks is definitely a misbehavior and it happened a lot
> in the past when heuristics were based on multiple metrics (including
> the run time etc.). Things have changed considerably since then and
> seeing random tasks being selected shouldn't happen all that often and
> if it happens it should be reported, understood and fixed.
> 

Well, it's hard to report, since it is essentially the result of a dynamic system.
I could assume it killed terminals with a long history buffer, or editors with many buffers (or big buffers).
Actually when it happened, I just turned overcommit off. I just checked and is on again on my desktop, probably forgot to make it a permanent setting.

In the end, no processes is a good candidate for termination.
What works for you may not work for me, that's the whole point, there's a heuristic (which conceptually can never be perfect), yet the mere fact that some process has to be killed is somewhat chilling.
I mean, all running processes are supposedly there and running for a reason.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
