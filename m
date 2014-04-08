Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id C40C26B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:44:07 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so837813eek.34
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 08:44:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si3300523eef.52.2014.04.08.08.44.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 08:44:05 -0700 (PDT)
Message-ID: <53441943.1080102@suse.cz>
Date: Tue, 08 Apr 2014 17:44:03 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC] mm,tracing: improve current situation
References: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net> <533DEDC5.5070500@oracle.com>
In-Reply-To: <533DEDC5.5070500@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <davidlohr@hp.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/04/2014 01:24 AM, Sasha Levin wrote:
> On 04/03/2014 05:44 PM, Davidlohr Bueso wrote:
>> Hi All,
>>
>> During LSFMM Dave Jones discussed the current situation around
>> testing/trinity in the mm. One of the conclusions was that basically we
>> lack tools to gather the necessary information to make debugging a less
>> painful process, making it pretty much a black box for a lot of cases.
>>
>> One of the suggested ways to do so was to improve our tracing. Currently
>> we have events for kmem, vmscan and oom (which really just traces the
>> tunable updates) -- In addition Dave Hansen also also been trying to add
>> tracing for TLB range flushing, hopefully that can make it in some time
>> soon. However, this lacks the more general data that governs all of the
>> core VM, such as vmas and of course the mm_struct.
>>
>> To this end, I've started adding events to trace the vma lifecycle,
>> including: creating, removing, splitting, merging, copying and
>> adjusting. Currently it only prints out the start and end virtual
>> addresses, such as:
>>
>> bash-3661   [000]  ....  222.964847: split_vma: [8a8000-9a6000] => new: [9a6000-9b6000]
>>
>> Now, on a more general scenario, I basically would like to know, 1) is
>> this actually useful... I'm hoping that, if in fact something like this
>> gets merged, it won't just sit there. 2) What other general data would
>> be useful for debugging purposes? I'm happy to collect feedback and send
>> out something we can all benefit from.

I think that adding more tracepoints might be more useful for debugging 
performance-related problems (e.g. compaction) that don't manifest as 
panic, and that VM_BUG_ON is more suited for this kind of debugging. But 
I might be wrong.

> There's another thing we have to think about, which is the bottleneck of
> getting that debug info out.
>
> Turning on any sort of tracing/logging in mm/ would trigger huge amounts
> of data flowing out. Any attempt to store that data anywhere would result
> either in too much interference to the tests so that issues stop reproducing,
> or way too much data to even be able to get through the guest <-> host pipe.
>
> I was working on a similar idea, which is similar to what lockdep does now:
> when you get a lockdep spew you see a nice output which also shows call
> traces of relevant locks. What if, for example, we could make dump_page()
> also dump the traces of where each of it's flags was set or cleared?

Hm doesn't the oops printing already print accumulated trace buffers? 
Wouldn't it be easier to post-process that instead of trying to do some 
smart "unwinding" during oops? Is it possible to enable tracing without 
actually consuming the data, just for this purpose?

Vlastimil

> Thanks,
> Sasha
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
