Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 343E36B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:14:58 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id n2so191058272obo.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:14:58 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id t18si1749283itb.78.2016.05.13.07.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:14:57 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id d62so3840795iof.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:14:57 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net>
 <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
 <5735D7FC.3070409@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <f28d8bc3-a144-9a18-51de-5ac8ae38fd15@gmail.com>
Date: Fri, 13 May 2016 10:14:55 -0400
MIME-Version: 1.0
In-Reply-To: <5735D7FC.3070409@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 09:34, Sebastian Frias wrote:
> Hi Austin,
>
> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
>> On 2016-05-13 08:39, Sebastian Frias wrote:
>>>
>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.
>
> By the way, why does it has to "kill" anything in that case?
> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?
In theory, that's a great idea.  In practice though, it only works if:
1. The allocating task correctly handles malloc() (or whatever other 
function it uses) returning NULL, which a number of programs don't.
2. The task actually has fallback options for memory limits.  Many 
programs that do handle getting a NULL pointer from malloc() handle it 
by exiting anyway, so there's not as much value in this case.
3. There isn't a memory leak somewhere on the system.  Killing the 
allocating task doesn't help much if this is the case of course.

You have to keep in mind though, that on a properly provisioned system, 
the only situations where the OOM killer should be invoked are when 
there's a memory leak, or when someone is intentionally trying to DoS 
the system through memory exhaustion.  If you're hitting the OOM killer 
for any other reason than those or a kernel bug, then you just need more 
memory or more swap space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
