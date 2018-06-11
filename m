Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9D36B0280
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 11:38:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t17-v6so12328326ply.13
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 08:38:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9-v6sor4144861pgu.328.2018.06.11.08.38.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 08:38:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <112df846-76d6-140f-8fdb-44dd0437c859@suse.cz>
References: <20180531193420.26087-1-ikalvachev@gmail.com> <CAHH2K0afVpVyMw+_J48pg9ngj9oovBEPBFd3kfCcCfyV7xxF0w@mail.gmail.com>
 <CABA=pqc8tuLGc4OTGymj5wN3ypisMM60mgOLpy2OXxmfteoJFg@mail.gmail.com>
 <alpine.LSU.2.11.1805311552390.13499@eggly.anvils> <112df846-76d6-140f-8fdb-44dd0437c859@suse.cz>
From: Ivan Kalvachev <ikalvachev@gmail.com>
Date: Mon, 11 Jun 2018 18:38:54 +0300
Message-ID: <CABA=pqf81WiOEhX-_O8EJ-cr_QMTFML3vvRzMrcEkbiXD4ogiA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix kswap excessive pressure after wrong condition transfer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

On 6/1/18, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 06/01/2018 01:30 AM, Hugh Dickins wrote:
>> On Fri, 1 Jun 2018, Ivan Kalvachev wrote:
>>> On 5/31/18, Greg Thelen <gthelen@google.com> wrote:
>>>>
>>>> This looks like yesterday's https://lkml.org/lkml/2018/5/30/1158
>>>>
>>>
>>> Yes, it seems to be the same problem.
>>> It also have better technical description.
>>
>> Well, your paragraph above on "Big memory consumers" gives a much
>> better user viewpoint, and a more urgent case for the patch to go in,
>> to stable if it does not make 4.17.0.
>>
>> But I am surprised: the change is in a block of code only used in
>> one of the modes of compaction (not in  reclaim itself), and I thought
>> it was a mode which gives up quite easily, rather than visibly blocking.
>>
>> So I wonder if there's another issue to be improved here,
>> and the mistreatment of the ex-swap pages just exposed it somehow.
>> Cc'ing Vlastimil and David in case it triggers any insight from them.
>
> My guess is that the problem is compaction fails because of the
> isolation failures, causing further reclaim/complaction attempts with
> higher priority, in the context of non-costly thus non-failing
> allocations. Initially I thought that increased priority of compaction
> would eventually synchronous and thus not go via this block of code
> anymore. But (see isolate_migratepages()) only MIGRATE_SYNC compaction
> mode drops the ISOLATE_ASYNC_MIGRATE isolate_mode flag. And MIGRATE_SYNC
> is only used for compaction triggered via /proc - direct compaction
> stops at MIGRATE_SYNC_LIGHT. Maybe that could be changed? Mel had
> reasons to limit to SYNC_LIGHT, I guess...
>
> If the above is correct, it means that even with gigabytes of free
> memory you can fail order-3 (max non-costly order) allocation if
> compaction doesn't work properly. That's a bit surprising, but not
> impossible I guess...

Is somebody working on testing this guess?

I don't fully understand this explanation, however I cannot imagine
non-costly allocation to fail when there are gigabytes of free
(unused) memory.

That's why I still think that the possibility that this bug is
triggering some underlying issue. So I did a little bit more poking
around.

For clarity, I'll be referring to the commits as:
-the bug : 69d763fc6d3a ("mm: pin address_space before dereferencing
it while isolating an LRU page")
-the fix : 145e1a71e090("mm: fix the NULL mapping case in __isolate_lru_page()")

The following results might be interesting to you:

1. I've discovered that 4.14.41 does not exhibit any problems, despite
having "the bug" backported into it . I used it again for a while, to
make sure I haven't overlooked it. No issues at all.

2. The 4.15 kernels were shortly supported so I backported "the bug"
on my own and run the kernel (first 4.15.18, later 4.15.0 ). At first
I thought that they were not affected, because I was not getting
blocking during use. However `top` showed that they also tend to
accumulate gigabytes of "free ram". Likely they were just better at
swapping unused pages.

3. I've tried the original 4.16.13 that has "the bug" but not "the
fix", however this time I disabled the "Transparent Hugepage Support"
from `make menuconfig`.
I ran that kernel for a while without any sign of issues.

So, before I start another round of bisect,
Does anybody have an educated guess what commit might have introduced
this behavior?

Do you think it is unintended behavior that should be investigated?

Any other hits?

Best Regards
   Ivan Kalvachev


>>>
>>> Such let down.
>>> It took me so much time to bisect the issue...
>>
>> Thank you for all your work on it, odd how we found it at the same
>> time: I was just porting Mel's patch into another tree, had to make
>> a change near there, and suddenly noticed that the test was wrong.
>>
>> Hugh
>>
>>>
>>> Well, I hope that the fix will get into 4.17 release in time.
>>
>
>
