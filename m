Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76E8D82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:17:36 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so18237912pac.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:17:36 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id uo3si7037575pac.221.2015.12.22.14.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:17:35 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id o64so112383717pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:17:35 -0800 (PST)
Date: Tue, 22 Dec 2015 14:17:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
In-Reply-To: <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1512221410380.5172@chino.kir.corp.google.com>
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com> <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 21 Dec 2015, Joonsoo Kim wrote:

> There is a performance drop report due to hugepage allocation and in there
> half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
> In that workload, compaction is triggered to make hugepage but most of
> pageblocks are un-available for compaction due to pageblock type and
> skip bit so compaction usually fails. Most costly operations in this case
> is to find valid pageblock while scanning whole zone range. To check
> if pageblock is valid to compact, valid pfn within pageblock is required
> and we can obtain it by calling pageblock_pfn_to_page(). This function
> checks whether pageblock is in a single zone and return valid pfn
> if possible. Problem is that we need to check it every time before
> scanning pageblock even if we re-visit it and this turns out to
> be very expensive in this workload.
> 
> Although we have no way to skip this pageblock check in the system
> where hole exists at arbitrary position, we can use cached value for
> zone continuity and just do pfn_to_page() in the system where hole doesn't
> exist. This optimization considerably speeds up in above workload.
> 
> Before vs After
> Max: 1096 MB/s vs 1325 MB/s
> Min: 635 MB/s 1015 MB/s
> Avg: 899 MB/s 1194 MB/s
> 
> Avg is improved by roughly 30% [2].
> 

Wow, ok!

I'm wondering if it would be better to maintain this as a characteristic 
of each pageblock rather than each zone.  Have you tried to introduce a 
couple new bits to pageblock_bits that would track (1) if a cached value 
makes sense and (2) if the pageblock is contiguous?  On the first call to 
pageblock_pfn_to_page(), set the first bit, PB_cached, and set the second 
bit, PB_contiguous, iff it is contiguous.  On subsequent calls, if 
PB_cached is true, then return PB_contiguous.  On memory hot-add or 
remove (or init), clear PB_cached.

What are the cases where pageblock_pfn_to_page() is used for a subset of 
the pageblock and the result would be problematic for compaction?  I.e., 
do we actually care to use pageblocks that are not contiguous at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
