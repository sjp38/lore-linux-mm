Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0CE6B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:23:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so10843549wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:23:49 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz25.laposte.net. [194.117.213.100])
        by mx.google.com with ESMTPS id cl10si22472960wjc.19.2016.05.13.07.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:23:47 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 90D3C1046C3
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:23:47 +0200 (CEST)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.laposte [10.128.63.3])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 8F6331046CB
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:23:47 +0200 (CEST)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
	by lpn-prd-vrin002 (Postfix) with ESMTP id 7A3DE5BF011
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:23:47 +0200 (CEST)
Message-ID: <5735E372.1090609@laposte.net>
Date: Fri, 13 May 2016 16:23:46 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz> <5735CAE5.5010104@laposte.net> <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com> <5735D7FC.3070409@laposte.net> <f28d8bc3-a144-9a18-51de-5ac8ae38fd15@gmail.com>
In-Reply-To: <f28d8bc3-a144-9a18-51de-5ac8ae38fd15@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Austin,

On 05/13/2016 04:14 PM, Austin S. Hemmelgarn wrote:
> On 2016-05-13 09:34, Sebastian Frias wrote:
>> Hi Austin,
>>
>> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
>>> On 2016-05-13 08:39, Sebastian Frias wrote:
>>>>
>>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
>>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.
>>
>> By the way, why does it has to "kill" anything in that case?
>> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?
> In theory, that's a great idea.  In practice though, it only works if:
> 1. The allocating task correctly handles malloc() (or whatever other function it uses) returning NULL, which a number of programs don't.
> 2. The task actually has fallback options for memory limits.  Many programs that do handle getting a NULL pointer from malloc() handle it by exiting anyway, so there's not as much value in this case.
> 3. There isn't a memory leak somewhere on the system.  Killing the allocating task doesn't help much if this is the case of course.

Well, the thing is that the current behaviour, i.e.: overcommiting, does not improves the quality of those programs.
I mean, what incentive do they have to properly handle situations 1, 2?

Also, if there's a memory leak, the termination of any task, whether it is the allocating task or something random, does not help either, the system will eventually go down, right?

> 
> You have to keep in mind though, that on a properly provisioned system, the only situations where the OOM killer should be invoked are when there's a memory leak, or when someone is intentionally trying to DoS the system through memory exhaustion. 

Exactly, the DoS attack is another reason why the OOM-killer does not seem a good idea, at least compared to just letting malloc return NULL and let the program fail.

>If you're hitting the OOM killer for any other reason than those or a kernel bug, then you just need more memory or more swap space.
> 

Indeed.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
