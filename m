Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 983586B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 04:04:27 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so7354413lbg.16
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 01:04:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si1544983laq.60.2014.09.08.01.04.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 01:04:25 -0700 (PDT)
Message-ID: <540D6305.8020409@suse.cz>
Date: Mon, 08 Sep 2014 10:04:21 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v6 11/13] mm, compaction: skip buddy pages by their order
 in the migrate scanner
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>	<1407142524-2025-12-git-send-email-vbabka@suse.cz> <20140821151115.bcc66c15d53f7dc89d1b9b73@linux-foundation.org>
In-Reply-To: <20140821151115.bcc66c15d53f7dc89d1b9b73@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 08/22/2014 12:11 AM, Andrew Morton wrote:
> On Mon,  4 Aug 2014 10:55:22 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> The migration scanner skips PageBuddy pages, but does not consider their order
>> as checking page_order() is generally unsafe without holding the zone->lock,
>> and acquiring the lock just for the check wouldn't be a good tradeoff.
>>
>> Still, this could avoid some iterations over the rest of the buddy page, and
>> if we are careful, the race window between PageBuddy() check and page_order()
>> is small, and the worst thing that can happen is that we skip too much and miss
>> some isolation candidates. This is not that bad, as compaction can already fail
>> for many other reasons like parallel allocations, and those have much larger
>> race window.
>>
>> This patch therefore makes the migration scanner obtain the buddy page order
>> and use it to skip the whole buddy page, if the order appears to be in the
>> valid range.
>>
>> It's important that the page_order() is read only once, so that the value used
>> in the checks and in the pfn calculation is the same. But in theory the
>> compiler can replace the local variable by multiple inlines of page_order().
>> Therefore, the patch introduces page_order_unsafe() that uses ACCESS_ONCE to
>> prevent this.
>>
>> Testing with stress-highalloc from mmtests shows a 15% reduction in number of
>> pages scanned by migration scanner. The reduction is >60% with __GFP_NO_KSWAPD
>> allocations, along with success rates better by few percent.
>> This change is also a prerequisite for a later patch which is detecting when
>> a cc->order block of pages contains non-buddy pages that cannot be isolated,
>> and the scanner should thus skip to the next block immediately.
>
> What is this "later patch"?  Or is the changelog stale?

Yes it is stale, that later patch was postponed due to apparent bad 
effect on fragmentation. I guess we can drop the last paragraph from 
this commit log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
