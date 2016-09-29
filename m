Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA42280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:17:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so63900894wmg.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:17:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 126si24645246wmw.86.2016.09.29.00.17.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 00:17:48 -0700 (PDT)
Subject: Re: Regression in mobility grouping?
References: <20160928014148.GA21007@cmpxchg.org>
 <8c3b7dd8-ef6f-6666-2f60-8168d41202cf@suse.cz>
 <20160928153925.GA24966@cmpxchg.org> <20160929022540.GA30883@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e287158d-14b8-21cb-ce18-1b0b4be6ce05@suse.cz>
Date: Thu, 29 Sep 2016 09:17:47 +0200
MIME-Version: 1.0
In-Reply-To: <20160929022540.GA30883@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 09/29/2016 04:25 AM, Johannes Weiner wrote:
> On Wed, Sep 28, 2016 at 11:39:25AM -0400, Johannes Weiner wrote:
>> On Wed, Sep 28, 2016 at 11:00:15AM +0200, Vlastimil Babka wrote:
>>> I guess testing revert of 9c0415e could give us some idea. Commit
>>> 3a1086f shouldn't result in pageblock marking differences and as I said
>>> above, 99592d5 should be just restoring to what 3.10 did.
>>
>> I can give this a shot, but note that this commit makes only unmovable
>> stealing more aggressive. We see reclaimable blocks up as well.
>
> Quick update, I reverted back to stealing eagerly only on behalf of
> MIGRATE_RECLAIMABLE allocations in a 4.6 kernel:
>
> static bool can_steal_fallback(unsigned int order, int start_mt)
> {
>         if (order >= pageblock_order / 2 ||
>             start_mt == MIGRATE_RECLAIMABLE ||
>             page_group_by_mobility_disabled)
>                 return true;
>
>         return false;
> }
>
> Yet, I still see UNMOVABLE growing to the thousands within minutes,
> whereas 3.10 didn't reach those numbers even after days of uptime.
>
> Okay, that wasn't it. However, there is something fishy going on,
> because I see extfrag traces like these:
>
> <idle>-0     [006] d.s.  1110.217281: mm_page_alloc_extfrag: page=ffffea0064142000 pfn=26235008 alloc_order=3 fallback_order=3 pageblock_order=9 alloc_migratetype=0 fallback_migratetype=2 fragmenting=1 change_ownership=1
>
> enum {
>         MIGRATE_UNMOVABLE,
>         MIGRATE_MOVABLE,
>         MIGRATE_RECLAIMABLE,
>         MIGRATE_PCPTYPES,       /* the number of types on the pcp lists */
>         MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
> 	...
> };
>
> This is an UNMOVABLE order-3 allocation falling back to RECLAIMABLE.
> According to can_steal_fallback(), this allocation shouldn't steal the
> pageblock, yet change_ownership=1 indicates the block is UNMOVABLE.
>
> Who converted it? I wonder if there is a bug in ownership management,
> and there was an UNMOVABLE block on the RECLAIMABLE freelist from the
> beginning. AFAICS we never validate list/mt consistency anywhere.

Hm yes there are e.g. no strong guarantees for pageblock migratetype and 
relevant pages being on freelist of the same type, except for ISOLATE, 
for performance reasons. IIRC pageblock type is checked when putting a 
page on pcplist and then it may diverge before it's flushed on freelist. 
So it's possible the fallback page was on RECLAIMABLE list
while the pageblock was marked as UNMOVABLE.

Also the tracepoint is racy so that steal_suitable_fallback() doesn't 
have to communicate back whether it was truly stealing whole pageblock.

> I'll continue looking tomorrow.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
