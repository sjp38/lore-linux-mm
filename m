Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43AB06B025E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:11:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u185so172294557oie.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:11:23 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id f13si1656186itc.34.2016.05.13.06.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:11:22 -0700 (PDT)
Received: by mail-io0-x234.google.com with SMTP id f89so131535720ioi.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:11:22 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
Date: Fri, 13 May 2016 09:11:18 -0400
MIME-Version: 1.0
In-Reply-To: <5735CAE5.5010104@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 08:39, Sebastian Frias wrote:
> On 05/13/2016 02:00 PM, Michal Hocko wrote:
>> On Fri 13-05-16 11:52:30, Sebastian Frias wrote:
>>>
>>> From what I remember, one of the LTP maintainers said that it is
>>> highly unlikely people test (or run LTP for that matter) with
>>> different settings for overcommit.
>>
>> Yes this is sad and the result of a excessive configuration space.
>> That's why I was pushing back to adding yet another one without having
>> really good reasons...
>
> Well, a more urgent problem would be that in that case overcommit=never is not really well tested.
I know more people who use overcommit=never than overcommit=always.  I 
use it myself on all my personal systems, but I also allocate 
significant amounts of swap space (usually 64G, but I also have a big 
disks in my systems and don't often hit swap), don't use Java, and 
generally don't use a lot of the more wasteful programs either (many of 
them on desktop systems tend to be stuff like office software).  I know 
a number of people who use overcommit=never on their servers and give 
them a decent amount of swap space (and again, don't use Java).
>
>>
>>> Years ago, while using MacOS X, a long running process apparently took
>>> all the memory over night.  The next day when I checked the computer
>>> I saw a dialog that said something like (I don't remember the exact
>>> wording) "process X has been paused due to lack of memory (or is
>>> requesting too much memory, I don't remember). If you think this is
>>> not normal you can terminate process X, otherwise you can terminate
>>> other processes to free memory and unpause process X to continue" and
>>> then some options to proceed.
>>>
>>> If left unattended (thus the dialog unanswered), the computer would
>>> still work, all other processes were left intact and only the
>>> "offending" process was paused.  Arguably, if the "offending" process
>>> is just left paused, it takes the memory away from other processes,
>>> and if it was a server, maybe it wouldn't have enough memory to reply
>>> to requests.  On the server world I can thus understand that some
>>> setting could indicate that when the situation arises, the "dialog" is
>>> automatically dismissed with some default action, like "terminate the
>>> offending process".
>>
>> Not sure what you are trying to tell here but it seems like killing such
>> a leaking task is a better option as the memory can be reused for others
>> rather than keep it blocked for an unbounded amount of time.
>
> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
There's an option for the OOM-killer to just kill the allocating task 
instead of using the scoring heuristic.  This is about as deterministic 
as things can get though.
>
>>
>>> To me it seems really strange for the "OOM-killer" to exist.  It has
>>> happened to me that it kills my terminals or editors, how can people
>>> deal with random processes being killed?  Doesn't it bother anybody?
>>
>> Killing random tasks is definitely a misbehavior and it happened a lot
>> in the past when heuristics were based on multiple metrics (including
>> the run time etc.). Things have changed considerably since then and
>> seeing random tasks being selected shouldn't happen all that often and
>> if it happens it should be reported, understood and fixed.
>>
>
> Well, it's hard to report, since it is essentially the result of a dynamic system.
> I could assume it killed terminals with a long history buffer, or editors with many buffers (or big buffers).
> Actually when it happened, I just turned overcommit off. I just checked and is on again on my desktop, probably forgot to make it a permanent setting.
>
> In the end, no processes is a good candidate for termination.
> What works for you may not work for me, that's the whole point, there's a heuristic (which conceptually can never be perfect), yet the mere fact that some process has to be killed is somewhat chilling.
> I mean, all running processes are supposedly there and running for a reason.
OTOH, just because something is there for a reason doesn't mean it's 
doing what it's supposed to be.  Bugs happen, including memory leaks, 
and if something is misbehaving enough that it impacts the rest of the 
system, it really should be dealt with.

This brings to mind a complex bug involving Tor and GCC whereby building 
certain (old) versions of Tor with certain (old) versions of GCC with 
-Os would cause an infinite loop in GCC.  You obviously have GCC running 
for a reason, but that doesn't mean that it's doing what it should be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
