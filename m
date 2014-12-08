Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76C196B0073
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:26:12 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so4392127wib.4
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:26:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt3si9369539wid.19.2014.12.08.03.26.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 03:26:11 -0800 (PST)
Date: Mon, 8 Dec 2014 11:26:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 3/3] mm: always steal split buddies in fallback
 allocations
Message-ID: <20141208112606.GP6043@suse.de>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1417713178-10256-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Thu, Dec 04, 2014 at 06:12:58PM +0100, Vlastimil Babka wrote:
> When allocation falls back to another migratetype, it will steal a page with
> highest available order, and (depending on this order and desired migratetype),
> it might also steal the rest of free pages from the same pageblock.
> 
> Given the preference of highest available order, it is likely that it will be
> higher than the desired order, and result in the stolen buddy page being split.
> The remaining pages after split are currently stolen only when the rest of the
> free pages are stolen.

The original intent was that the stolen fallback buddy page would be
added to the requested migratetype freelists. This was independent of
whether all other free pages in the pageblock were moved or whether the
pageblock migratetype was updated.

> This can however lead to situations where for MOVABLE
> allocations we split e.g. order-4 fallback UNMOVABLE page, but steal only
> order-0 page. Then on the next MOVABLE allocation (which may be batched to
> fill the pcplists) we split another order-3 or higher page, etc. By stealing
> all pages that we have split, we can avoid further stealing.
> 
> This patch therefore adjust the page stealing so that buddy pages created by
> split are always stolen. This has effect only on MOVABLE allocations, as
> RECLAIMABLE and UNMOVABLE allocations already always do that in addition to
> stealing the rest of free pages from the pageblock.
> 

This restores the intended behaviour.

> Note that commit 7118af076f6 ("mm: mmzone: MIGRATE_CMA migration type added")
> has already performed this change (unintentinally), but was reverted by commit
> 0cbef29a7821 ("mm: __rmqueue_fallback() should respect pageblock type").
> Neither included evaluation. My evaluation with stress-highalloc from mmtests
> shows about 2.5x reduction of page stealing events for MOVABLE allocations,
> without affecting the page stealing events for other allocation migratetypes.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
