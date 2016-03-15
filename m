Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AAA236B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 21:16:08 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id u190so4136260pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 18:16:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id zg6si2553458pac.237.2016.03.14.18.16.07
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 18:16:07 -0700 (PDT)
Date: Tue, 15 Mar 2016 10:16:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 01/19] mm: use put_page to free page instead of
 putback_lru_page
Message-ID: <20160315011656.GD19514@bbox>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-2-git-send-email-minchan@kernel.org>
 <56E67AE1.60700@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E67AE1.60700@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, Mar 14, 2016 at 09:48:33AM +0100, Vlastimil Babka wrote:
> On 03/11/2016 08:30 AM, Minchan Kim wrote:
> >Procedure of page migration is as follows:
> >
> >First of all, it should isolate a page from LRU and try to
> >migrate the page. If it is successful, it releases the page
> >for freeing. Otherwise, it should put the page back to LRU
> >list.
> >
> >For LRU pages, we have used putback_lru_page for both freeing
> >and putback to LRU list. It's okay because put_page is aware of
> >LRU list so if it releases last refcount of the page, it removes
> >the page from LRU list. However, It makes unnecessary operations
> >(e.g., lru_cache_add, pagevec and flags operations.
> 
> Yeah, and compaction (perhaps also other migration users) has to
> drain the lru pvec... Getting rid of this stuff is worth even by
> itself.

Good note. Although we cannot remove lru pvec draining completely,
at least, this patch removes a case which should drain pvec for
returning freed page to buddy.

Thanks for the notice.

> 
> >It would be
> >not significant but no worth to do) and harder to support new
> >non-lru page migration because put_page isn't aware of non-lru
> >page's data structure.
> >
> >To solve the problem, we can add new hook in put_page with
> >PageMovable flags check but it can increase overhead in
> >hot path and needs new locking scheme to stabilize the flag check
> >with put_page.
> >
> >So, this patch cleans it up to divide two semantic(ie, put and putback).
> >If migration is successful, use put_page instead of putback_lru_page and
> >use putback_lru_page only on failure. That makes code more readable
> >and doesn't add overhead in put_page.
> 
> I had an idea of checking for count==1 in putback_lru_page() which
> would take the put_page() shortcut from there. But maybe it can't be
> done nicely without races.

I thought about it and we might do it via page_freeze_refs but
what I want at this moment is to separte two semantic put and putback.
;-)

> 
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Note in -next/after 4.6-rc1 this will need some rebasing though.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
