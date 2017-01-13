Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6FE6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:06:19 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so13551034wms.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:06:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q187si1369909wmb.99.2017.01.13.01.06.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 01:06:17 -0800 (PST)
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz>
 <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
 <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <89fec1bd-52b7-7861-2e02-a719c5631610@suse.cz>
Date: Fri, 13 Jan 2017 10:06:14 +0100
MIME-Version: 1.0
In-Reply-To: <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 01/13/2017 05:35 AM, Ganapatrao Kulkarni wrote:
> On Thu, Jan 12, 2017 at 4:40 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 01/11/2017 05:46 PM, Michal Hocko wrote:
>>>
>>> On Wed 11-01-17 21:52:29, Ganapatrao Kulkarni wrote:
>>>
>>>> [ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB
>>>> (UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
>>>> 275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) = 12047196kB
>>>
>>>
>>> Most of the memblocks are marked Unmovable (except for the 4MB bloks)
>>
>>
>> No, UME here means that e.g. 4kB blocks are available on unmovable, movable
>> and reclaimable lists.
>>
>>> which shouldn't matter because we can fallback to unmovable blocks for
>>> movable allocation AFAIR so we shouldn't really fail the request. I
>>> really fail to see what is going on there but it smells really
>>> suspicious.
>>
>>
>> Perhaps there's something wrong with zonelists and we are skipping the Node
>> 1 Normal zone. Or there's some race with cpuset operations (but can't see
>> how).
>>
>> The question is, how reproducible is this? And what exactly the test
>> cpuset01 does? Is it doing multiple things in a loop that could be reduced
>> to a single testcase?
> 
> IIUC, this test does node change to  cpuset.mems in loop in parent
> process in loop and child processes(equal to no of cpus) keeps on
> allocation and freeing
> 10 pages till the execution time is over.
> more details at
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/cpuset/cpuset01.c

Ah, thanks for explaining. Looks like there might be a race where determining
ac.preferred_zone using current_mems_allowed as ac.nodemask skips the only zone
that is allowed after the cpuset.mems update, and we only recalculate
ac.preferred_zone for allocations that are allowed to escape cpusets/watermarks.
Thus we see only part of the zonelist, missing the only allowed zone. This would
be due to commit 682a3385e773 ("mm, page_alloc: inline the fast path of the
zonelist iterator") and/or some others from that series.

Could you try with the following patch please? It also tries to protect from
race with last non-root cpuset removal, which could cause cpusets_enable() to
become false in the middle of the function.

----8<----
