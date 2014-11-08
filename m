Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A14CD82BEF
	for <linux-mm@kvack.org>; Sat,  8 Nov 2014 17:18:41 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id h11so7450064wiw.0
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 14:18:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu6si22328440wjb.48.2014.11.08.14.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Nov 2014 14:18:40 -0800 (PST)
Message-ID: <545E96BD.5040103@suse.cz>
Date: Sat, 08 Nov 2014 23:18:37 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
References: <12996532.NCRhVKzS9J@xorhgos3.pefnos> <3583067.00bS4AInhm@xorhgos3.pefnos> <545BEA3B.40005@suse.cz> <3443150.6EQzxj6Rt9@xorhgos3.pefnos>
In-Reply-To: <3443150.6EQzxj6Rt9@xorhgos3.pefnos>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "P. Christeas" <xrg@linux.gr>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lkml <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, Markus Trippelsdorf <markus@trippelsdorf.de>, Pavel Machek <pavel@ucw.cz>

On 11/08/2014 02:11 PM, P. Christeas wrote:
> On Thursday 06 November 2014, Vlastimil Babka wrote:
>>> On Wednesday 05 November 2014, Vlastimil Babka wrote:
>>>> Can you please try the following patch?
>>>> -			compaction_defer_reset(zone, order, false);
>> Oh and did I ask in this thread for /proc/zoneinfo yet? :)
> 
> Using that same kernel[1], got again into a race, gathered a few more data.
> 
> This time, I had 1x "urpmq" process [2] hung at 100% CPU , when "kwin" got 
> apparently blocked (100% CPU, too) trying to resize a GUI window. I suppose 
> the resizing operation would mean heavy memory alloc/free.
> 
> The rest of the system was responsive, I could easily get a console, login, 
> gather the files.. Then, I have *killed* -9 the "urpmq" process, which solved 
> the race and my system is still alive! "kwin" is still running, returned to 
> regular CPU load.
> 
> Attached is traces from SysRq+l (pressed a few times, wanted to "snapshot" the 
> stack) and /proc/zoneinfo + /proc/vmstat
> 
> Bisection is not yet meaningful, IMHO, because I cannot be sure that "good" 
> points are really free from this issue. I'd estimate that each test would take 
> +3days, unless I really find a deterministic way to reproduce the issue .

Hi,

I think I finally found the cause by staring into the code... CCing
people from all 4 separate threads I know about this issue.
The problem with finding the cause was that the first report I got from
Markus was about isolate_freepages_block() overhead, and later Norbert
reported that reverting a patch for isolate_freepages* helped. But the
problem seems to be that although the loop in isolate_migratepages exits
because the scanners almost meet (they are within same pageblock), they
don't truly meet, therefore compact_finished() decides to continue, but
isolate_migratepages() exits immediately... boom! But indeed e14c720efdd7
made this situation possible, as free scaner pfn can now point to a
middle of pageblock.

So I hope the attached patch will fix the soft-lockup issues in
compact_zone. Please apply on 3.18-rc3 or later without any other reverts,
and test. It probably won't help Markus and his isolate_freepages_block()
overhead though...

Thanks,
Vlastimil

------8<------
