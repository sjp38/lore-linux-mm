Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C34A76B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:55:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u18so8572096wrc.10
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:55:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w75si10932671wmd.74.2017.03.30.00.55.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 00:55:35 -0700 (PDT)
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <87shmedddm.fsf@vitty.brq.redhat.com> <20170315122914.GG32620@dhcp22.suse.cz>
 <87k27qd7m2.fsf@vitty.brq.redhat.com> <20170315131139.GK32620@dhcp22.suse.cz>
 <20170315163729.GR27056@redhat.com>
 <20170316053122.GA14701@js1304-P5Q-DELUXE>
 <20170316190125.GT27056@redhat.com>
 <CAAmzW4OR7GREYv3LVE5LVOdEDGEfyGLaZNMg2ZBhO7niAakLAw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ae9c5714-ff45-05ea-6a10-976c311b5742@suse.cz>
Date: Thu, 30 Mar 2017 09:55:32 +0200
MIME-Version: 1.0
In-Reply-To: <CAAmzW4OR7GREYv3LVE5LVOdEDGEfyGLaZNMg2ZBhO7niAakLAw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Toshi Kani <toshi.kani@hpe.com>, xieyisheng1@huawei.com, slaoub@gmail.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

On 03/20/2017 07:33 AM, Joonsoo Kim wrote:
>> The fact sticky movable pageblocks aren't ideal for CMA doesn't mean
>> they're not ideal for memory hotunplug though.
>>
>> With CMA there's no point in having the sticky movable pageblocks
>> scattered around and it's purely a misfeature to use sticky movable
>> pageblocks because you need the whole CMA area contiguous hence a
>> ZONE_CMA is ideal.
> No. CMA ranges could be registered many times for each devices and they
> could be scattered due to device's H/W limitation. So, current implementation
> in kernel, MIGRATE_CMA pageblocks, are scattered sometimes.
> 
>> As opposed with memory hotplug the sticky movable pageblocks would
>> allow the kernel to satisfy the current /sys API and they would
>> provide no downside unlike in the CMA case where the size of the
>> allocation is unknown.
> No, same downside also exists in this case. Downside is not related to the case
> that device uses that range. It is related to VM management to this range and
> problems are the same. For example, with sticky movable pageblock, we need to
> subtract number of freepages in sticky movable pageblock when watermark is
> checked for non-movable allocation and it causes some problems.

Agree. Right now for CMA we have to account NR_FREE_CMA_PAGES (number of
free pages within MIGRATE_CMA pageblocks), which brings all those hooks
and other troubles for keep the accounting precise (there used to be
various races in there). This goes against the rest of page grouping by
mobility design, which wasn't meant to be precise for performance
reasons (e.g. when you change pageblock type and move pages between
freelists, any pcpu cached pages are left at their previous type's list).

We also can't ignore this accounting, as then the watermark check could
then pass for e.g. UNMOVABLE allocation, which would proceed to find
that the only free pages available are within the MIGRATE_CMA (or
sticky-movable) pageblocks, where it's not allowed to fallback to. If
only then we went reclaiming, the zone balance checks would also
consider the zone balanced, even though unmovable allocations would
still not be possible.

Even with this extra accounting, things are not perfect, because reclaim
doesn't guarantee freeing the pages in the right pageblocks, so we can
easily overreclaim. That's mainly why I agreed that ZONE_CMA should be
better than the current implementation, and I'm skeptical about the
sticky-movable pageblock idea. Note the conversion to node-lru reclaim
has changed things somewhat, as we can't reclaim a single zone anymore,
but the accounting troubles remain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
