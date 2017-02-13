Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DABEB6B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:54:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a15so35640945wrc.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:54:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si13332052wrn.333.2017.02.13.02.54.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 02:54:55 -0800 (PST)
Subject: Re: [PATCH v2 03/10] mm, page_alloc: split smallest stolen page in
 fallback
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-4-vbabka@suse.cz>
 <20170213105118.f3y5y2xaf2kdnxv7@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c4a97114-3020-c70f-0e9e-9f611f2dec1c@suse.cz>
Date: Mon, 13 Feb 2017 11:54:51 +0100
MIME-Version: 1.0
In-Reply-To: <20170213105118.f3y5y2xaf2kdnxv7@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/13/2017 11:51 AM, Mel Gorman wrote:
> On Fri, Feb 10, 2017 at 06:23:36PM +0100, Vlastimil Babka wrote:
>> The __rmqueue_fallback() function is called when there's no free page of
>> requested migratetype, and we need to steal from a different one. There are
>> various heuristics to make this event infrequent and reduce permanent
>> fragmentation. The main one is to try stealing from a pageblock that has the
>> most free pages, and possibly steal them all at once and convert the whole
>> pageblock. Precise searching for such pageblock would be expensive, so instead
>> the heuristics walks the free lists from MAX_ORDER down to requested order and
>> assumes that the block with highest-order free page is likely to also have the
>> most free pages in total.
>>
>> Chances are that together with the highest-order page, we steal also pages of
>> lower orders from the same block. But then we still split the highest order
>> page. This is wasteful and can contribute to fragmentation instead of avoiding
>> it.
>>
> 
> The original intent was that if an allocation request was stealing a
> pageblock that taking the largest one would reduce the likelihood of a
> steal in the near future by the same type.

I understand the intent and tried to explain that in the first
paragraph. This patch doesn't change that, we still select the pageblock
for stealing based on the largest free page we find. But if we manage to
steal also some smaller pages from the same pageblock, we will split the
smallest one instead of the largest one.

>> This patch thus changes __rmqueue_fallback() to just steal the page(s) and put
>> them on the freelist of the requested migratetype, and only report whether it
>> was successful. Then we pick (and eventually split) the smallest page with
>> __rmqueue_smallest().  This all happens under zone lock, so nobody can steal it
>> from us in the process. This should reduce fragmentation due to fallbacks. At
>> worst we are only stealing a single highest-order page and waste some cycles by
>> moving it between lists and then removing it, but fallback is not exactly hot
>> path so that should not be a concern. As a side benefit the patch removes some
>> duplicate code by reusing __rmqueue_smallest().
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> But conceptually this is better so
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
