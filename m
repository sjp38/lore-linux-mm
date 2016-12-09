Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5576B0261
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 13:32:45 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id he10so8845105wjc.6
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 10:32:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ww1si35158788wjb.147.2016.12.09.10.32.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 10:32:43 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, page_alloc: don't convert pfn to idx when merging
References: <20161209093754.3515-1-vbabka@suse.cz>
 <20161209172658.uebsgt5ju6gtz2bu@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e6f7ee3c-75ae-63a8-cde0-1d00e65cb973@suse.cz>
Date: Fri, 9 Dec 2016 19:32:22 +0100
MIME-Version: 1.0
In-Reply-To: <20161209172658.uebsgt5ju6gtz2bu@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On 12/09/2016 06:26 PM, Mel Gorman wrote:
> On Fri, Dec 09, 2016 at 10:37:53AM +0100, Vlastimil Babka wrote:
>> In __free_one_page() we do the buddy merging arithmetics on "page/buddy index",
>> which is just the lower MAX_ORDER bits of pfn. The operations we do that affect
>> the higher bits are bitwise AND and subtraction (in that order), where the
>> final result will be the same with the higher bits left unmasked, as long as
>> these bits are equal for both buddies - which must be true by the definition of
>> a buddy.
> 
> Ok, other than the kbuild warning, both patchs look ok. I expect the
> benefit is marginal but every little bit helps.
> 
>>
>> We can therefore use pfn's directly instead of "index" and skip the zeroing of
>>> MAX_ORDER bits. This can help a bit by itself, although compiler might be
>> smart enough already. It also helps the next patch to avoid page_to_pfn() for
>> memory hole checks.
>>
> 
> I expect this benefit only applies to a few archiectures and won't be
> visible on x86 but it still makes sense so for both patches;
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks!

> As a slight aside, I recently spotted that one of the largest overhead
> in the bulk free path was in the page_is_buddy() checks so pretty much
> anything that helps that is welcome.

Interesting, the function shouldn't be doing really much on x86 without
debug config options? We might try further optimize the zone equivalence
checks, perhaps?
- try caching page_zone_id(page) through whole merging, and only obtain
it freshly
  for buddy candidate
- mark arches/configurations sane enough that they have no zone boundary
within MAX_ORDER, and skip these checks there. I assume most, if not all
x86 would fall here? Somewhat analogically to page_valid_within().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
