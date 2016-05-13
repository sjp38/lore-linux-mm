Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A38D6B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:51:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x67so174049548oix.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:51:53 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id w187si6932598oia.210.2016.05.13.06.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:51:52 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id k129so14954069iof.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:51:52 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D77C.9090803@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <50852f22-6030-7361-4273-91b5bea446ed@gmail.com>
Date: Fri, 13 May 2016 09:51:50 -0400
MIME-Version: 1.0
In-Reply-To: <5735D77C.9090803@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 09:32, Sebastian Frias wrote:
> Hi Austin,
>
> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
>> On 2016-05-13 08:39, Sebastian Frias wrote:
>>> Well, a more urgent problem would be that in that case overcommit=never is not really well tested.
>> I know more people who use overcommit=never than overcommit=always.  I use it myself on all my personal systems, but I also allocate significant amounts of swap space (usually 64G, but I also have a big disks in my systems and don't often hit swap), don't use Java, and generally don't use a lot of the more wasteful programs either (many of them on desktop systems tend to be stuff like office software).  I know a number of people who use overcommit=never on their servers and give them a decent amount of swap space (and again, don't use Java).
>
> Then I'll look into LTP and the issues it has when overcommit=never.
>
>>>
>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.
>
> I didn't see that in Documentation/vm/overcommit-accounting or am I looking in the wrong place?
It's controlled by a sysctl value, so it's listed in 
Documentation/sysctl/vm.txt
The relevant sysctl is vm.oom_kill_allocating_task
>
>>>
>>> Well, it's hard to report, since it is essentially the result of a dynamic system.
>>> I could assume it killed terminals with a long history buffer, or editors with many buffers (or big buffers).
>>> Actually when it happened, I just turned overcommit off. I just checked and is on again on my desktop, probably forgot to make it a permanent setting.
>>>
>>> In the end, no processes is a good candidate for termination.
>>> What works for you may not work for me, that's the whole point, there's a heuristic (which conceptually can never be perfect), yet the mere fact that some process has to be killed is somewhat chilling.
>>> I mean, all running processes are supposedly there and running for a reason.
>> OTOH, just because something is there for a reason doesn't mean it's doing what it's supposed to be.  Bugs happen, including memory leaks, and if something is misbehaving enough that it impacts the rest of the system, it really should be dealt with.
>
> Exactly, it's just that in this case, the system is deciding how to deal with the situation by itself.
On a busy server where uptime is critical, you can't wait for someone to 
notice and handle it manually, you need the issue resolved ASAP.  Now, 
this won't always kill the correct thing, but if it's due to a memory 
leak, it often will work like it should.
>
>>
>> This brings to mind a complex bug involving Tor and GCC whereby building certain (old) versions of Tor with certain (old) versions of GCC with -Os would cause an infinite loop in GCC.  You obviously have GCC running for a reason, but that doesn't mean that it's doing what it should be.
>
> I'm not sure if I followed the analogy/example, but are you saying that the OOM-killer killed GCC in your example?
> This seems an odd example though, I mean, shouldn't the guy in front of the computer notice the loop and kill GCC by himself?
No, I didn't mean as an example of the OOM killer, I just meant as an 
example of software not doing what it should.  It's not as easy to find 
an example for the OOM killer, so I don't really have a good example. 
The general concept is the same though, the only difference is there 
isn't a kernel protection against infinite loops (because they aren't 
always bugs, while memory leaks and similar are).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
