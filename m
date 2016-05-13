Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84E456B025E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:15:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x67so177896072oix.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:15:12 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id uj2si1864144igc.83.2016.05.13.08.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:15:11 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id f89so136169367ioi.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:15:11 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D77C.9090803@laposte.net>
 <50852f22-6030-7361-4273-91b5bea446ed@gmail.com>
 <5735E628.9080306@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <86e8fa7e-f92a-a1d1-0676-a35d2ba85aed@gmail.com>
Date: Fri, 13 May 2016 11:15:09 -0400
MIME-Version: 1.0
In-Reply-To: <5735E628.9080306@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 10:35, Sebastian Frias wrote:
> Hi Austin,
>
> On 05/13/2016 03:51 PM, Austin S. Hemmelgarn wrote:
>> On 2016-05-13 09:32, Sebastian Frias wrote:
>>>
>>>>>
>>>>> Well, it's hard to report, since it is essentially the result of a dynamic system.
>>>>> I could assume it killed terminals with a long history buffer, or editors with many buffers (or big buffers).
>>>>> Actually when it happened, I just turned overcommit off. I just checked and is on again on my desktop, probably forgot to make it a permanent setting.
>>>>>
>>>>> In the end, no processes is a good candidate for termination.
>>>>> What works for you may not work for me, that's the whole point, there's a heuristic (which conceptually can never be perfect), yet the mere fact that some process has to be killed is somewhat chilling.
>>>>> I mean, all running processes are supposedly there and running for a reason.
>>>> OTOH, just because something is there for a reason doesn't mean it's doing what it's supposed to be.  Bugs happen, including memory leaks, and if something is misbehaving enough that it impacts the rest of the system, it really should be dealt with.
>>>
>>> Exactly, it's just that in this case, the system is deciding how to deal with the situation by itself.
>> On a busy server where uptime is critical, you can't wait for someone to notice and handle it manually, you need the issue resolved ASAP.  Now, this won't always kill the correct thing, but if it's due to a memory leak, it often will work like it should.
>
> The keyword is "'often' will work as expected".
> So you are saying that it will kill a program leaking memory in what, like 90% of the cases?
If the program leaking memory has the highest memory consumption, it 
will be the one that gets killed.  If not, then it will eventually be 
the one with the highest memory consumption and be killed (usually 
pretty quickly if it's leaking memory fast).
> I'm not sure if I would setup a server with critical uptime to have the OOM-killer enabled, do you think that'd be a good idea?
It really depends.  If you've got a setup with a bunch of web-servers 
behind a couple of load balancers which are set up in a HA 
configuration, I absolutely would run with the OOM killer enabled on 
everything.  There are in fact very few cases I wouldn't run with it 
enabled, as it's almost always better on a server to be able to actually 
log in to see what's wrong than to have to deal with resource exhaustion.

Most of the servers where I work are set to panic on OOM instead of 
killing something, because if we hit an OOM condition it's either a bug 
or a DoS attack, and either case needs to be noticed immediately, and 
taking out the entire system is the most reliable way to make sure it 
gets noticed.
>
> Anyway, as a side note, I just want to say thank you guys for having this discussion.
> I think it is an interesting thread and hopefully it will advance the "knowledge" about this setting.
>
>>>
>>>>
>>>> This brings to mind a complex bug involving Tor and GCC whereby building certain (old) versions of Tor with certain (old) versions of GCC with -Os would cause an infinite loop in GCC.  You obviously have GCC running for a reason, but that doesn't mean that it's doing what it should be.
>>>
>>> I'm not sure if I followed the analogy/example, but are you saying that the OOM-killer killed GCC in your example?
>>> This seems an odd example though, I mean, shouldn't the guy in front of the computer notice the loop and kill GCC by himself?
>> No, I didn't mean as an example of the OOM killer, I just meant as an example of software not doing what it should.  It's not as easy to find an example for the OOM killer, so I don't really have a good example. The general concept is the same though, the only difference is there isn't a kernel protection against infinite loops (because they aren't always bugs, while memory leaks and similar are).
>
> So how does the kernel knows that a process is "leaking memory" as opposed to just "using lots of memory"? (wouldn't that be comparable to answering how does the kernel knows the difference between an infinite loop and one that is not?)
It doesn't, it sees who's using the most RAM and kills that first.  If 
something is leaking memory, it will eventually kill that and you should 
have a working system again if you have process supervision.

There are three cases where it won't kill the task with the largest 
memory consumption:
1. You have /proc/sys/vm/panic_on_oom set to 1, which will cause the 
kernel to panic instead of killing a single task.
2. You have /proc/sys/vm/oom_kill_allocating_task set to 1, in which 
case it will kill whatever triggered the fault that caused the OOM 
condition.
3. You have adjusted the OOM score for tasks via /proc.  The score 
normally scales with memory usage, but it's possible to set it higher 
for specific tasks.  Many of the public distributed computing platforms 
(like BOINC) use this to cause their applications to be the first target 
for the OOM killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
