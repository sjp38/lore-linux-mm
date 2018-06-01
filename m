Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 123F86B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 04:49:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v133-v6so7210865pgb.10
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 01:49:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11-v6si22790200pgs.218.2018.06.01.01.49.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 01:49:29 -0700 (PDT)
Subject: Re: [PATCH] mm: fix kswap excessive pressure after wrong condition
 transfer
References: <20180531193420.26087-1-ikalvachev@gmail.com>
 <CAHH2K0afVpVyMw+_J48pg9ngj9oovBEPBFd3kfCcCfyV7xxF0w@mail.gmail.com>
 <CABA=pqc8tuLGc4OTGymj5wN3ypisMM60mgOLpy2OXxmfteoJFg@mail.gmail.com>
 <alpine.LSU.2.11.1805311552390.13499@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <112df846-76d6-140f-8fdb-44dd0437c859@suse.cz>
Date: Fri, 1 Jun 2018 10:49:25 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1805311552390.13499@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Ivan Kalvachev <ikalvachev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

On 06/01/2018 01:30 AM, Hugh Dickins wrote:
> On Fri, 1 Jun 2018, Ivan Kalvachev wrote:
>> On 5/31/18, Greg Thelen <gthelen@google.com> wrote:
>>>
>>> This looks like yesterday's https://lkml.org/lkml/2018/5/30/1158
>>>
>>
>> Yes, it seems to be the same problem.
>> It also have better technical description.
> 
> Well, your paragraph above on "Big memory consumers" gives a much
> better user viewpoint, and a more urgent case for the patch to go in,
> to stable if it does not make 4.17.0.
> 
> But I am surprised: the change is in a block of code only used in
> one of the modes of compaction (not in  reclaim itself), and I thought
> it was a mode which gives up quite easily, rather than visibly blocking. 
> 
> So I wonder if there's another issue to be improved here,
> and the mistreatment of the ex-swap pages just exposed it somehow.
> Cc'ing Vlastimil and David in case it triggers any insight from them.

My guess is that the problem is compaction fails because of the
isolation failures, causing further reclaim/complaction attempts with
higher priority, in the context of non-costly thus non-failing
allocations. Initially I thought that increased priority of compaction
would eventually synchronous and thus not go via this block of code
anymore. But (see isolate_migratepages()) only MIGRATE_SYNC compaction
mode drops the ISOLATE_ASYNC_MIGRATE isolate_mode flag. And MIGRATE_SYNC
is only used for compaction triggered via /proc - direct compaction
stops at MIGRATE_SYNC_LIGHT. Maybe that could be changed? Mel had
reasons to limit to SYNC_LIGHT, I guess...

If the above is correct, it means that even with gigabytes of free
memory you can fail order-3 (max non-costly order) allocation if
compaction doesn't work properly. That's a bit surprising, but not
impossible I guess...

Vlastimil

>>
>> Such let down.
>> It took me so much time to bisect the issue...
> 
> Thank you for all your work on it, odd how we found it at the same
> time: I was just porting Mel's patch into another tree, had to make
> a change near there, and suddenly noticed that the test was wrong.
> 
> Hugh
> 
>>
>> Well, I hope that the fix will get into 4.17 release in time.
> 
