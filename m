Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A9E2C6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 03:57:02 -0400 (EDT)
Received: by wggj6 with SMTP id j6so18676770wgg.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 00:57:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cn6si26099973wjb.209.2015.05.12.00.57.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 May 2015 00:57:01 -0700 (PDT)
Message-ID: <5551B24C.7080801@suse.cz>
Date: Tue, 12 May 2015 09:57:00 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage
 if steal
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com> <20150427080850.GF2449@suse.de> <20150427084257.GA13790@js1304-P5Q-DELUXE>
In-Reply-To: <20150427084257.GA13790@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On 04/27/2015 10:42 AM, Joonsoo Kim wrote:
> On Mon, Apr 27, 2015 at 09:08:50AM +0100, Mel Gorman wrote:
>> On Mon, Apr 27, 2015 at 04:23:39PM +0900, Joonsoo Kim wrote:
>>> When we steal whole pageblock, we don't need to break highest order
>>> freepage. Perhaps, there is small order freepage so we can use it.
>>>
>>
>> The reason why the largest block is taken is to reduce the probability
>> there will be another fallback event in the near future. Early on, there
>> were a lot of tests conducted to measure the number of external fragmenting
>> events and take steps to reduce them. Stealing the largest highest order
>> freepage was one of those steps.
>
> Hello, Mel.
>
> Purpose of this patch is not "stop steal highest order freepage".
> Currently, in case of that we steal all freepage including highest
> order freepage in certain pageblock, we break highest order freepage and
> return it even if we have low order freepage that we immediately steal.
>
> For example,
>
> Pageblock A has 5 freepage (4 * order 0, 1 * order 3) and
> we try to steal all freepage on pageblock A.
>
> Withouth this patch, we move all freepage to requested migratetype
> buddy list and break order 3 freepage. Leftover is like as following.
>
> (5 * order 0, 1 * order 1, 1* order 2)
>
> With this patch, (3 * order 0, 1 * order 3) remains.
>
> I think that this is better than before because we still have high order
> page. Isn't it?

I agree that this should be better in some cases and shouldn't be worse 
in any case. Nice catch.

> Thanks.
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
