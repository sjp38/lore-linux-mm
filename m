Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7E36C6B026D
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 01:14:17 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l126so133737920wml.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 22:14:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15si62006184wju.169.2015.12.22.22.14.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 22:14:16 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1512221410380.5172@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <567A3BBD.80408@suse.cz>
Date: Wed, 23 Dec 2015 07:14:21 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1512221410380.5172@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 22.12.2015 23:17, David Rientjes wrote:
> On Mon, 21 Dec 2015, Joonsoo Kim wrote:
> 
>> Before vs After
>> Max: 1096 MB/s vs 1325 MB/s
>> Min: 635 MB/s 1015 MB/s
>> Avg: 899 MB/s 1194 MB/s
>>
>> Avg is improved by roughly 30% [2].
>>
> 
> Wow, ok!
> 
> I'm wondering if it would be better to maintain this as a characteristic 
> of each pageblock rather than each zone.  Have you tried to introduce a 
> couple new bits to pageblock_bits that would track (1) if a cached value 
> makes sense and (2) if the pageblock is contiguous?  On the first call to 
> pageblock_pfn_to_page(), set the first bit, PB_cached, and set the second 
> bit, PB_contiguous, iff it is contiguous.  On subsequent calls, if 
> PB_cached is true, then return PB_contiguous.  On memory hot-add or 
> remove (or init), clear PB_cached.

I can imagine these bitmap operation to be as expensive as what
__pageblock_pfn_to_page() does (or close)? But if not, we could also just be a
bit smarter about PG_skip and check that before doing pfn_to_page.

> What are the cases where pageblock_pfn_to_page() is used for a subset of 
> the pageblock and the result would be problematic for compaction?  I.e., 
> do we actually care to use pageblocks that are not contiguous at all?

The problematic pageblocks are those that have pages from more than one zone in
them, so we just skip them. Supposedly that can only happen by switching once
between two zones somewhere in the middle of the pageblock, so it's sufficient
to check first and last pfn and compare their zones. So using
pageblock_pfn_to_page() on a subset from compaction would be wrong. Holes (==no
pages) within pageblock is a different thing checked by pfn_valid_within()
(#defined out on archs where such holes cannot happen) when scanning the block.

That's why I'm not entirely happy with how the patch conflates both the
first/last pfn's zone checks and pfn_valid_within() checks. Yes, a fully
contiguous zone does *imply* that pageblock_pfn_to_page() doesn't have to check
first/last pfn for a matching zone. But it's not *equality*. And any (now just
*potential*) user of pageblock_pfn_to_page() with pfn's different than
first/last pfn of a pageblock is likely wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
