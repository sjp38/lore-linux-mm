Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 94C616B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 22:35:19 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so45003870pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:35:19 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id ld10si8311509pab.98.2016.04.06.19.35.18
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 19:35:18 -0700 (PDT)
Date: Thu, 7 Apr 2016 11:35:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 02/16] mm/compaction: support non-lru movable page
 migration
Message-ID: <20160407023532.GD15178@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-3-git-send-email-minchan@kernel.org>
 <56FEE82A.30602@suse.cz>
 <20160404051225.GA6838@bbox>
 <57026B12.6060000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57026B12.6060000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, dri-devel@lists.freedesktop.org, Gioh Kim <gurugio@hanmail.net>

On Mon, Apr 04, 2016 at 03:24:34PM +0200, Vlastimil Babka wrote:
> On 04/04/2016 07:12 AM, Minchan Kim wrote:
> >On Fri, Apr 01, 2016 at 11:29:14PM +0200, Vlastimil Babka wrote:
> >>Might have been better as a separate migration patch and then a
> >>compaction patch. It's prefixed mm/compaction, but most changed are
> >>in mm/migrate.c
> >
> >Indeed. The title is rather misleading but not sure it's a good idea
> >to separate compaction and migration part.
> 
> Guess it's better to see the new functions together with its user
> after all, OK.
> 
> >I will just resend to change the tile from "mm/compaction" to
> >"mm/migration".
> 
> OK!
> 
> >>Also I'm a bit uncomfortable how isolate_movable_page() blindly expects that
> >>page->mapping->a_ops->isolate_page exists for PageMovable() pages.
> >>What if it's a false positive on a PG_reclaim page? Can we rely on
> >>PG_reclaim always (and without races) implying PageLRU() so that we
> >>don't even attempt isolate_movable_page()?
> >
> >For now, we shouldn't have such a false positive because PageMovable
> >checks page->_mapcount == PAGE_MOVABLE_MAPCOUNT_VALUE as well as PG_movable
> >under PG_lock.
> >
> >But I read your question about user-mapped drvier pages so we cannot
> >use _mapcount anymore so I will find another thing. A option is this.
> >
> >static inline int PageMovable(struct page *page)
> >{
> >         int ret = 0;
> >         struct address_space *mapping;
> >         struct address_space_operations *a_op;
> >
> >         if (!test_bit(PG_movable, &(page->flags))
> >                 goto out;
> >
> >         mapping = page->mapping;
> >         if (!mapping)
> >                 goto out;
> >
> >         a_op = mapping->a_op;
> >         if (!aop)
> >                 goto out;
> >         if (a_op->isolate_page)
> >                 ret = 1;
> >out:
> >         return ret;
> >
> >}
> >
> >It works under PG_lock but with this, we need trylock_page to peek
> >whether it's movable non-lru or not for scanning pfn.
> 
> Hm I hoped that with READ_ONCE() we could do the peek safely without
> trylock_page, if we use it only as a heuristic. But I guess it would
> require at least RCU-level protection of the
> page->mapping->a_op->isolate_page chain.
> 
> >For avoiding that, we need another function to peek which just checks
> >PG_movable bit instead of all things.
> >
> >
> >/*
> >  * If @page_locked is false, we cannot guarantee page->mapping's stability
> >  * so just the function checks with PG_movable which could be false positive
> >  * so caller should check it again under PG_lock to check a_ops->isolate_page.
> >  */
> >static inline int PageMovable(struct page *page, bool page_locked)
> >{
> >         int ret = 0;
> >         struct address_space *mapping;
> >         struct address_space_operations *a_op;
> >
> >         if (!test_bit(PG_movable, &(page->flags))
> >                 goto out;
> >
> >         if (!page_locked) {
> >                 ret = 1;
> >                 goto out;
> >         }
> >
> >         mapping = page->mapping;
> >         if (!mapping)
> >                 goto out;
> >
> >         a_op = mapping->a_op;
> >         if (!aop)
> >                 goto out;
> >         if (a_op->isolate_page)
> >                 ret = 1;
> >out:
> >         return ret;
> >}
> 
> I wouldn't put everything into single function, but create something
> like __PageMovable() just for the unlocked peek. Unlike the
> zone->lru_lock, we don't keep page_lock() across iterations in
> isolate_migratepages_block(), as obviously each page has different
> lock.
> So the page_locked parameter would be always passed as constant, and
> at that point it's better to have separate functions.

Agree.

> 
> So I guess the question is how many false positives from overlap
> with PG_reclaim the scanner will hit if we give up on
> PAGE_MOVABLE_MAPCOUNT_VALUE, as that will increase number of page
> locks just to realize that it's not actual PageMovable() page...

I don't think it's too many because PG_reclaim bit is set to only
LRU pages at the moment and we can check PageMovable after !PageLRU
check.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
