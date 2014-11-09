Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 98BAB82BEF
	for <linux-mm@kvack.org>; Sun,  9 Nov 2014 04:43:03 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id ex7so7960347wid.10
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 01:43:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv10si1155131wib.88.2014.11.09.01.43.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 01:43:02 -0800 (PST)
Message-ID: <545F3724.7070502@suse.cz>
Date: Sun, 09 Nov 2014 10:43:00 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <3583067.00bS4AInhm@xorhgos3.pefnos> <545BEA3B.40005@suse.cz> <3443150.6EQzxj6Rt9@xorhgos3.pefnos> <545E96BD.5040103@suse.cz> <20141109082746.GA3402@amd>
In-Reply-To: <20141109082746.GA3402@amd>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "P. Christeas" <xrg@linux.gr>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, Markus Trippelsdorf <markus@trippelsdorf.de>

On 11/09/2014 09:27 AM, Pavel Machek wrote:
> Hi!
> 
>>>> Oh and did I ask in this thread for /proc/zoneinfo yet? :)
>>>
>>> Using that same kernel[1], got again into a race, gathered a few more data.
>>>
>>> This time, I had 1x "urpmq" process [2] hung at 100% CPU , when "kwin" got 
>>> apparently blocked (100% CPU, too) trying to resize a GUI window. I suppose 
>>> the resizing operation would mean heavy memory alloc/free.
>>>
>>> The rest of the system was responsive, I could easily get a console, login, 
>>> gather the files.. Then, I have *killed* -9 the "urpmq" process, which solved 
>>> the race and my system is still alive! "kwin" is still running, returned to 
>>> regular CPU load.
>>>
>>> Attached is traces from SysRq+l (pressed a few times, wanted to "snapshot" the 
>>> stack) and /proc/zoneinfo + /proc/vmstat
>>>
>>> Bisection is not yet meaningful, IMHO, because I cannot be sure that "good" 
>>> points are really free from this issue. I'd estimate that each test would take 
>>> +3days, unless I really find a deterministic way to reproduce the issue .
>>
>> Hi,
>>
>> I think I finally found the cause by staring into the code... CCing
>> people from all 4 separate threads I know about this issue.
>> The problem with finding the cause was that the first report I got from
>> Markus was about isolate_freepages_block() overhead, and later Norbert
>> reported that reverting a patch for isolate_freepages* helped. But the
>> problem seems to be that although the loop in isolate_migratepages exits
>> because the scanners almost meet (they are within same pageblock), they
>> don't truly meet, therefore compact_finished() decides to continue, but
>> isolate_migratepages() exits immediately... boom! But indeed e14c720efdd7
>> made this situation possible, as free scaner pfn can now point to a
>> middle of pageblock.
> 
> Ok, it seems it happened second time now, again shortly after
> resume. I guess I should apply your patch after all.

Thanks.

> (Or... instead it should go to Linus ASAP -- it fixes known problem
> that is affected people, and we want it in soon in case it is not
> complete fix.)

I don't want to send untested fix, and wasn't able to reproduce the bug
myself. I think Norbert could do it rather quickly so I hope he can tell
us soon.

> Dmesg is in the attachment, perhaps it helps.
> 									Pavel

It looks the same as before, so no surprises there, which is good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
