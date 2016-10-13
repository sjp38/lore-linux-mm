Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E04C2280255
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:46:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d186so47294159lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:46:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si17180552wjw.186.2016.10.13.04.46.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 04:46:08 -0700 (PDT)
Subject: Re: [RFC 4/4] mm, page_alloc: disallow migratetype fallback in
 fastpath
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
 <20160929210548.26196-5-vbabka@suse.cz>
 <20161013075856.GC2306@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1a4548bd-a9b3-e6c0-7b4f-e75b5e4f4cbd@suse.cz>
Date: Thu, 13 Oct 2016 13:46:05 +0200
MIME-Version: 1.0
In-Reply-To: <20161013075856.GC2306@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On 10/13/2016 09:58 AM, Joonsoo Kim wrote:
> On Thu, Sep 29, 2016 at 11:05:48PM +0200, Vlastimil Babka wrote:
>> The previous patch has adjusted async compaction so that it helps against
>> longterm fragmentation when compacting for a non-MOVABLE high-order allocation.
>> The goal of this patch is to force such allocations go through compaction
>> once before being allowed to fallback to a pageblock of different migratetype
>> (e.g. MOVABLE). In contexts where compaction is not allowed (and for order-0
>> allocations), this delayed fallback possibility can still help by trying a
>> different zone where fallback might not be needed and potentially waking up
>> kswapd earlier.
>
> Hmm... can we justify this compaction overhead in case of that there is
> high order freepages in other migratetype pageblock? There is no guarantee
> that longterm fragmentation happens and it affects the system
> peformance.

Yeah, I hoped testing would show whether this makes any difference, and 
what the overhead is, and then we can decide whether it's worth.

> And, it would easilly fail to compact in unmovable pageblock since
> there would not be migratable pages if everything works as our
> intended. So, I guess that checking it over and over doesn't help to
> reduce fragmentation and just increase latency of allocation.

The pageblock isolation_suitable heuristics of compaction should 
mitigate rescanning blocks without success. We could also add a per-zone 
flag that gets set during a fallback allocation event and cleared by 
finished compaction, or something.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
