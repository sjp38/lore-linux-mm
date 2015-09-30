Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 534186B0269
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 10:16:33 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so200686967wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 07:16:32 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id pj8si1032387wjb.35.2015.09.30.07.16.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 07:16:32 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so64139737wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 07:16:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560BE934.3030808@suse.cz>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
	<20150824123015.GJ12432@techsingularity.net>
	<CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
	<20150909123901.GA12432@techsingularity.net>
	<CAMJBoFORrhY++4PeT1xcvHCU=tyNs4T0uMhoUxrKsru6QC1NWw@mail.gmail.com>
	<560BE934.3030808@suse.cz>
Date: Wed, 30 Sep 2015 16:16:31 +0200
Message-ID: <CAMJBoFOKGchN7LQny+tsWd-wL0LVyt8NL+7FZE__TvskanFhsg@mail.gmail.com>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for order-0 allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 30, 2015 at 3:52 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/30/2015 10:51 AM, Vitaly Wool wrote:
>>
>> On Wed, Sep 9, 2015 at 2:39 PM, Mel Gorman <mgorman@techsingularity.net>
>> wrote:
>>>
>>> On Tue, Sep 08, 2015 at 05:26:13PM +0900, Joonsoo Kim wrote:
>>>>
>>>> 2015-08-24 21:30 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
>>>>>
>>>>> The primary purpose of watermarks is to ensure that reclaim can always
>>>>> make forward progress in PF_MEMALLOC context (kswapd and direct
>>>>> reclaim).
>>>>> These assume that order-0 allocations are all that is necessary for
>>>>> forward progress.
>>>>>
>>>>> High-order watermarks serve a different purpose. Kswapd had no
>>>>> high-order
>>>>> awareness before they were introduced
>>>>> (https://lkml.org/lkml/2004/9/5/9).
>>>>> This was particularly important when there were high-order atomic
>>>>> requests.
>>>>> The watermarks both gave kswapd awareness and made a reserve for those
>>>>> atomic requests.
>>>>>
>>>>> There are two important side-effects of this. The most important is
>>>>> that
>>>>> a non-atomic high-order request can fail even though free pages are
>>>>> available
>>>>> and the order-0 watermarks are ok. The second is that high-order
>>>>> watermark
>>>>> checks are expensive as the free list counts up to the requested order
>>>>> must
>>>>> be examined.
>>>>>
>>>>> With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary
>>>>> to
>>>>> have high-order watermarks. Kswapd and compaction still need high-order
>>>>> awareness which is handled by checking that at least one suitable
>>>>> high-order
>>>>> page is free.
>>>>
>>>>
>>>> I still don't think that this one suitable high-order page is enough.
>>>> If fragmentation happens, there would be no order-2 freepage. If kswapd
>>>> prepares only 1 order-2 freepage, one of two successive process forks
>>>> (AFAIK, fork in x86 and ARM require order 2 page) must go to direct
>>>> reclaim
>>>> to make order-2 freepage. Kswapd cannot make order-2 freepage in that
>>>> short time. It causes latency to many high-order freepage requestor
>>>> in fragmented situation.
>>>>
>>>
>>> So what do you suggest instead? A fixed number, some other heuristic?
>>> You have pushed several times now for the series to focus on the latency
>>> of standard high-order allocations but again I will say that it is
>>> outside
>>> the scope of this series. If you want to take steps to reduce the latency
>>> of ordinary high-order allocation requests that can sleep then it should
>>> be a separate series.
>>
>>
>> I do believe https://lkml.org/lkml/2015/9/9/313 does a better job
>
>
> Does a better job regarding what exactly? It does fix the CMA-specific
> issue, but so does this patch - without affecting allocation fastpaths by
> making them update another counter. But the issues discussed here are not
> related to that CMA problem.

Let me disagree. Guaranteeing one suitable high-order page is not
enough, so the suggested patch does not work that well for me.
Existing broken watermark calculation doesn't work for me either, as
opposed to the one with my patch applied. Both solutions are related
to the CMA issue but one does make compaction work harder and cause
bigger latencies -- why do you think these are not related?

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
