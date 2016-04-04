Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id DF4436B027B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:24:38 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id u8so161054731lbk.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:24:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vl10si31260508wjc.75.2016.04.04.06.24.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 06:24:37 -0700 (PDT)
Subject: Re: [PATCH v3 02/16] mm/compaction: support non-lru movable page
 migration
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-3-git-send-email-minchan@kernel.org>
 <56FEE82A.30602@suse.cz> <20160404051225.GA6838@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57026B12.6060000@suse.cz>
Date: Mon, 4 Apr 2016 15:24:34 +0200
MIME-Version: 1.0
In-Reply-To: <20160404051225.GA6838@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, dri-devel@lists.freedesktop.org, Gioh Kim <gurugio@hanmail.net>

On 04/04/2016 07:12 AM, Minchan Kim wrote:
> On Fri, Apr 01, 2016 at 11:29:14PM +0200, Vlastimil Babka wrote:
>> Might have been better as a separate migration patch and then a
>> compaction patch. It's prefixed mm/compaction, but most changed are
>> in mm/migrate.c
>
> Indeed. The title is rather misleading but not sure it's a good idea
> to separate compaction and migration part.

Guess it's better to see the new functions together with its user after 
all, OK.

> I will just resend to change the tile from "mm/compaction" to
> "mm/migration".

OK!

>> Also I'm a bit uncomfortable how isolate_movable_page() blindly expects that
>> page->mapping->a_ops->isolate_page exists for PageMovable() pages.
>> What if it's a false positive on a PG_reclaim page? Can we rely on
>> PG_reclaim always (and without races) implying PageLRU() so that we
>> don't even attempt isolate_movable_page()?
>
> For now, we shouldn't have such a false positive because PageMovable
> checks page->_mapcount == PAGE_MOVABLE_MAPCOUNT_VALUE as well as PG_movable
> under PG_lock.
>
> But I read your question about user-mapped drvier pages so we cannot
> use _mapcount anymore so I will find another thing. A option is this.
>
> static inline int PageMovable(struct page *page)
> {
>          int ret = 0;
>          struct address_space *mapping;
>          struct address_space_operations *a_op;
>
>          if (!test_bit(PG_movable, &(page->flags))
>                  goto out;
>
>          mapping = page->mapping;
>          if (!mapping)
>                  goto out;
>
>          a_op = mapping->a_op;
>          if (!aop)
>                  goto out;
>          if (a_op->isolate_page)
>                  ret = 1;
> out:
>          return ret;
>
> }
>
> It works under PG_lock but with this, we need trylock_page to peek
> whether it's movable non-lru or not for scanning pfn.

Hm I hoped that with READ_ONCE() we could do the peek safely without 
trylock_page, if we use it only as a heuristic. But I guess it would 
require at least RCU-level protection of the 
page->mapping->a_op->isolate_page chain.

> For avoiding that, we need another function to peek which just checks
> PG_movable bit instead of all things.
>
>
> /*
>   * If @page_locked is false, we cannot guarantee page->mapping's stability
>   * so just the function checks with PG_movable which could be false positive
>   * so caller should check it again under PG_lock to check a_ops->isolate_page.
>   */
> static inline int PageMovable(struct page *page, bool page_locked)
> {
>          int ret = 0;
>          struct address_space *mapping;
>          struct address_space_operations *a_op;
>
>          if (!test_bit(PG_movable, &(page->flags))
>                  goto out;
>
>          if (!page_locked) {
>                  ret = 1;
>                  goto out;
>          }
>
>          mapping = page->mapping;
>          if (!mapping)
>                  goto out;
>
>          a_op = mapping->a_op;
>          if (!aop)
>                  goto out;
>          if (a_op->isolate_page)
>                  ret = 1;
> out:
>          return ret;
> }

I wouldn't put everything into single function, but create something 
like __PageMovable() just for the unlocked peek. Unlike the 
zone->lru_lock, we don't keep page_lock() across iterations in 
isolate_migratepages_block(), as obviously each page has different lock.
So the page_locked parameter would be always passed as constant, and at 
that point it's better to have separate functions.

So I guess the question is how many false positives from overlap with 
PG_reclaim the scanner will hit if we give up on 
PAGE_MOVABLE_MAPCOUNT_VALUE, as that will increase number of page locks 
just to realize that it's not actual PageMovable() page...

> Thanks for detail review, Vlastimil!
> I will resend new versions after vacation in this week.

You're welcome, great!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
