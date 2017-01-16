Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4CCA6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:22:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so11617397wjy.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:22:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si21544514wrt.49.2017.01.16.05.22.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 05:22:55 -0800 (PST)
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz>
 <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
 <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
 <89fec1bd-52b7-7861-2e02-a719c5631610@suse.cz>
 <CAFpQJXUq_O=UAhCb7fwq2txYxg_owO77rRdQFUjR0_Mj9p=3pA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a374d6b6-c299-b50d-d7e0-f85ac78525aa@suse.cz>
Date: Mon, 16 Jan 2017 14:22:52 +0100
MIME-Version: 1.0
In-Reply-To: <CAFpQJXUq_O=UAhCb7fwq2txYxg_owO77rRdQFUjR0_Mj9p=3pA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 01/16/2017 11:41 AM, Ganapatrao Kulkarni wrote:
> On Fri, Jan 13, 2017 at 2:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 01/13/2017 05:35 AM, Ganapatrao Kulkarni wrote:
>>> On Thu, Jan 12, 2017 at 4:40 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> On 01/11/2017 05:46 PM, Michal Hocko wrote:
>>>>>
>>>>> On Wed 11-01-17 21:52:29, Ganapatrao Kulkarni wrote:
>>>>>
>>>>>> [ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB
>>>>>> (UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
>>>>>> 275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) = 12047196kB
>>>>>
>>>>>
>>>>> Most of the memblocks are marked Unmovable (except for the 4MB bloks)
>>>>
>>>>
>>>> No, UME here means that e.g. 4kB blocks are available on unmovable, movable
>>>> and reclaimable lists.
>>>>
>>>>> which shouldn't matter because we can fallback to unmovable blocks for
>>>>> movable allocation AFAIR so we shouldn't really fail the request. I
>>>>> really fail to see what is going on there but it smells really
>>>>> suspicious.
>>>>
>>>>
>>>> Perhaps there's something wrong with zonelists and we are skipping the Node
>>>> 1 Normal zone. Or there's some race with cpuset operations (but can't see
>>>> how).
>>>>
>>>> The question is, how reproducible is this? And what exactly the test
>>>> cpuset01 does? Is it doing multiple things in a loop that could be reduced
>>>> to a single testcase?
>>>
>>> IIUC, this test does node change to  cpuset.mems in loop in parent
>>> process in loop and child processes(equal to no of cpus) keeps on
>>> allocation and freeing
>>> 10 pages till the execution time is over.
>>> more details at
>>> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/cpuset/cpuset01.c
>>
>> Ah, thanks for explaining. Looks like there might be a race where determining
>> ac.preferred_zone using current_mems_allowed as ac.nodemask skips the only zone
>> that is allowed after the cpuset.mems update, and we only recalculate
>> ac.preferred_zone for allocations that are allowed to escape cpusets/watermarks.
>> Thus we see only part of the zonelist, missing the only allowed zone. This would
>> be due to commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
>> zonelist iterator") and/or some others from that series.
>>
>> Could you try with the following patch please? It also tries to protect from
>> race with last non-root cpuset removal, which could cause cpusets_enable() to
>> become false in the middle of the function.
>>
>> ----8<----
>> From 9f041839401681f2678edf5040c851d11963c5fe Mon Sep 17 00:00:00 2001
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Fri, 13 Jan 2017 10:01:26 +0100
>> Subject: [PATCH] mm, page_alloc: fix race with cpuset update or removal
>>
>> Changelog and S-O-B TBD.
>> ---
>>  mm/page_alloc.c | 10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6de9440e3ae2..c397f146843a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3775,9 +3775,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>>         /*
>>          * Restore the original nodemask if it was potentially replaced with
>>          * &cpuset_current_mems_allowed to optimize the fast-path attempt.
>> +        * Also recalculate the starting point for the zonelist iterator or
>> +        * we could end up iterating over non-eligible zones endlessly.
>>          */
>> -       if (cpusets_enabled())
>> +       if (unlikely(ac.nodemask != nodemask)) {
>>                 ac.nodemask = nodemask;
>> +               ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
>> +                                               ac.high_zoneidx, ac.nodemask);
>> +               if (!ac.preferred_zoneref)
>> +                       goto no_zone;
>> +       }
>> +
>>         page = __alloc_pages_slowpath(alloc_mask, order, &ac);
>>
>>  no_zone:
>> --
>> 2.11.0
>>
> 
> this patch did not fix the issue.
> issue still exists!

Hmm, that's unfortunate.

> i did bisect and this test passes in 4.4,4.5 and 4.6
> test failing since 4.7-rc1

4.7 would match the commit I was trying to fix. But I don't see other
problems now. Could you bisect to a single commit then, to be sure? Thanks.

> thanks
> Ganapat
>>
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
