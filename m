Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6909C8308D
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:20:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so11399244lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:20:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si1649205wjg.16.2016.08.18.05.20.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:20:13 -0700 (PDT)
Subject: Re: [PATCH v6 10/11] mm, compaction: require only min watermarks for
 non-costly orders
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-11-vbabka@suse.cz>
 <20160816061636.GF17448@js1304-P5Q-DELUXE>
 <484d17e5-7294-4724-f5f9-0a15167d47ee@suse.cz>
 <20160816064630.GH17448@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7ae4baec-4eca-e70b-2a69-94bea4fb19fa@suse.cz>
Date: Thu, 18 Aug 2016 14:20:10 +0200
MIME-Version: 1.0
In-Reply-To: <20160816064630.GH17448@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2016 08:46 AM, Joonsoo Kim wrote:
> On Tue, Aug 16, 2016 at 08:36:12AM +0200, Vlastimil Babka wrote:
>> On 08/16/2016 08:16 AM, Joonsoo Kim wrote:
>>> On Wed, Aug 10, 2016 at 11:12:25AM +0200, Vlastimil Babka wrote:
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 621e4211ce16..a5c0f914ec00 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -2492,7 +2492,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>>>>
>>>> 	if (!is_migrate_isolate(mt)) {
>>>> 		/* Obey watermarks as if the page was being allocated */
>>>> -		watermark = low_wmark_pages(zone) + (1 << order);
>>>> +		watermark = min_wmark_pages(zone) + (1UL << order);
>>>
>>> This '1 << order' also needs some comment. Why can't we use
>>> compact_gap() in this case?
>>
>> This is just short-cutting the high-order watermark check to check
>> only order-0, because we already know the high-order page exists.
>> We can't use compact_gap() as that's too high to use for a single
>> allocation watermark, since we can be already holding some free
>> pages on the list. So it would defeat the gap purpose.
> 
> Oops. I missed that. Thanks for clarifying it.

So let's expand the comment?

----8<----
