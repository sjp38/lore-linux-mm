Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 359DA6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:39:04 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so10592576wib.11
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:39:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf3si12041351wjc.6.2014.06.05.08.39.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 08:39:01 -0700 (PDT)
Message-ID: <53908F10.4020603@suse.cz>
Date: Thu, 05 Jun 2014 17:38:56 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/05/2014 02:08 AM, David Rientjes wrote:
> On Wed, 4 Jun 2014, Vlastimil Babka wrote:
>
>> In direct compaction, we want to allocate the high-order page as soon as
>> possible, so migrating from a block of pages that contains also unmigratable
>> pages just adds to allocation latency.
>>
>
> The title of the patch in the subject line should probably be reworded
> since it implies we never isolate from blocks that cannot become
> completely free and what you're really doing is skipping cc->order aligned
> pages.
>
>> This patch therefore makes the migration scanner skip to the next cc->order
>> aligned block of pages as soon as it cannot isolate a non-free page. Everything
>> isolated up to that point is put back.
>>
>> In this mode, the nr_isolated limit to COMPACT_CLUSTER_MAX is not observed,
>> allowing the scanner to scan the whole block at once, instead of migrating
>> COMPACT_CLUSTER_MAX pages and then finding an unmigratable page in the next
>> call. This might however have some implications on too_many_isolated.
>>
>> Also in this RFC PATCH, the "skipping mode" is tied to async migration mode,
>> which is not optimal. What we most probably want is skipping in direct
>> compactions, but not from kswapd and hugepaged.
>>
>> In very preliminary tests, this has reduced migrate_scanned, isolations and
>> migrations by about 10%, while the success rate of stress-highalloc mmtests
>> actually improved a bit.
>>
>
> Ok, so this obsoletes my patchseries that did something similar.  I hope

Your patches 1/3 and 2/3 would still make sense. Checking alloc flags is 
IMHO better than checking async here. That way, hugepaged and kswapd 
would still try to migrate stuff which is important as Mel described in 
the reply to your 3/3.

> you can rebase this set on top of linux-next and then propose it formally
> without the RFC tag.

I posted this early to facilitate discussion, but if you want to test on 
linux-next then sure.

> We also need to discuss the scheduling heuristics, the reliance on
> need_resched(), to abort async compaction.  In testing, we actualy
> sometimes see 2-3 pageblocks scanned before terminating and thp has a very
> little chance of being allocated.  At the same time, if we try to fault
> 64MB of anon memory in and each of the 32 calls to compaction are
> expensive but don't result in an order-9 page, we see very lengthy fault
> latency.

Yes, I thought you were about to try the 1GB per call setting. I don't 
currently have a test setup like you. My patch 1/6 still uses on 
need_resched() but that could be replaced with a later patch.

> I think it would be interesting to consider doing async compaction
> deferral up to 1 << COMPACT_MAX_DEFER_SHIFT after a sysctl-configurable
> amount of memory is scanned, at least for thp, and remove the scheduling
> heuristic entirely.

That could work. How about the lock contention heuristic? Is it possible 
on a large and/or busy system to compact anything substantional without 
hitting the lock contention? Are your observations about too early abort 
based on need_resched() or lock contention?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
