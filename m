Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7046B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:02:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u185so176964059oie.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:02:26 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id t142si7028587oie.19.2016.05.13.08.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:02:25 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id d62so4075532iof.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:02:25 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D7FC.3070409@laposte.net>
 <f28d8bc3-a144-9a18-51de-5ac8ae38fd15@gmail.com>
 <5735E372.1090609@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <a3fd524c-be46-8848-830d-259b544a0ab6@gmail.com>
Date: Fri, 13 May 2016 11:02:23 -0400
MIME-Version: 1.0
In-Reply-To: <5735E372.1090609@laposte.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 10:23, Sebastian Frias wrote:
> Hi Austin,
>
> On 05/13/2016 04:14 PM, Austin S. Hemmelgarn wrote:
>> On 2016-05-13 09:34, Sebastian Frias wrote:
>>> Hi Austin,
>>>
>>> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
>>>> On 2016-05-13 08:39, Sebastian Frias wrote:
>>>>>
>>>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
>>>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.
>>>
>>> By the way, why does it has to "kill" anything in that case?
>>> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?
>> In theory, that's a great idea.  In practice though, it only works if:
>> 1. The allocating task correctly handles malloc() (or whatever other function it uses) returning NULL, which a number of programs don't.
>> 2. The task actually has fallback options for memory limits.  Many programs that do handle getting a NULL pointer from malloc() handle it by exiting anyway, so there's not as much value in this case.
>> 3. There isn't a memory leak somewhere on the system.  Killing the allocating task doesn't help much if this is the case of course.
>
> Well, the thing is that the current behaviour, i.e.: overcommiting, does not improves the quality of those programs.
> I mean, what incentive do they have to properly handle situations 1, 2?
Overcommit got introduced because of these, not the other way around. 
It's not forcing them to change, but it's also a core concept in any 
modern virtual memory based OS, and that's not ever going to change either.

You also have to keep in mind that most apps aren't doing this 
intentionally.  There are three general reasons they do this:
1. They don't know how much memory they will need, so they guess high 
because malloc() is computationally expensive.  This is technically 
intentional, but it's also something that can't be avoided in some cases 
  Dropbox is a perfect example of this taken way too far (they also take 
the concept of a thread pool too far).
2. The program has a lot of code that isn't frequently run.  It makes no 
sense to keep code that isn't used in RAM, so it gets either dropped (if 
it's unmodified), or it gets swapped out.  Most of the programs that I 
see on my system fall into this category (acpid  for example just sleeps 
until an ACPI event happens, so it usually won't have most of it's code 
in memory on a busy system).
3. The application wants to do it's own memory management.  This is 
common on a lot of HPC apps and some high performance server software.
>
> Also, if there's a memory leak, the termination of any task, whether it is the allocating task or something random, does not help either, the system will eventually go down, right?
If the memory leak is in the kernel, then yes, the OOM killer won't 
help, period.  But if the memory leak is in userspace, and the OOM 
killer kills the task with the leak (which it usually will if you don't 
have it set to kill the allocating task), then it may have just saved 
the system from crashing completely.  Yes some user may lose some 
unsaved work, but they would lose that data anyway if the system 
crashes, and they can probably still use the rest of the system.
>> You have to keep in mind though, that on a properly provisioned system, the only situations where the OOM killer should be invoked are when there's a memory leak, or when someone is intentionally trying to DoS the system through memory exhaustion.
>
> Exactly, the DoS attack is another reason why the OOM-killer does not seem a good idea, at least compared to just letting malloc return NULL and let the program fail.
Because of overcommit, it's possible for the allocation to succeed, but 
the subsequent access to fail.  At that point, you're way past malloc() 
returning, and you have to do something.

Also, returning NULL on a failed malloc() provides zero protection 
against all but the most brain-dead memory exhaustion based DoS attacks. 
  The general core of a memory exhaustion DoS against a local system 
follows a simple three step procedure:
     1. Try to allocate a small chunk of memory (less than or equal to 
page size)
     2. If the allocation succeeded, write to the first byte of that 
chunk of memory, forcing actual allocation
     3. Repeat indefinitely from step 1
Step 2 is the crucial part here, if you don't write to the memory, it 
will only eat up your own virtual address space.  If you don't check for 
a NULL pointer and skip writing, you get a segfault.  If the OOM killer 
isn't invoked in such a situation, then this will just eat up all the 
free system memory, and then _keep running_ and eat up all the other 
memory as it's freed by other things exiting due to lack of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
