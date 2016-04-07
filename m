Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9B266B025E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 22:26:59 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fe3so44885546pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:26:59 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ug10si8221798pab.237.2016.04.06.19.26.58
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 19:26:59 -0700 (PDT)
Date: Thu, 7 Apr 2016 11:27:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 03/16] mm: add non-lru movable page support document
Message-ID: <20160407022714.GC15178@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-4-git-send-email-minchan@kernel.org>
 <56FE87EA.60806@suse.cz>
 <20160404022552.GD6543@bbox>
 <57026782.3020201@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57026782.3020201@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Jonathan Corbet <corbet@lwn.net>

On Mon, Apr 04, 2016 at 03:09:22PM +0200, Vlastimil Babka wrote:
> On 04/04/2016 04:25 AM, Minchan Kim wrote:
> >>
> >>Ah, I see, so it's designed with page lock to handle the concurrent isolations etc.
> >>
> >>In http://marc.info/?l=linux-mm&m=143816716511904&w=2 Mel has warned
> >>about doing this in general under page_lock and suggested that each
> >>user handles concurrent calls to isolate_page() internally. Might be
> >>more generic that way, even if all current implementers will
> >>actually use the page lock.
> >
> >We need PG_lock for two reasons.
> >
> >Firstly, it guarantees page's flags operation(i.e., PG_movable, PG_isolated)
> >atomicity. Another thing is for stability for page->mapping->a_ops.
> >
> >For example,
> >
> >isolate_migratepages_block
> >         if (PageMovable(page))
> >                 isolate_movable_page
> >                         get_page_unless_zero <--- 1
> >                         trylock_page
> >                         page->mapping->a_ops->isolate_page <--- 2
> >
> >Between 1 and 2, driver can nullify page->mapping so we need PG_lock
> 
> Hmm I see, that really doesn't seem easily solvable without page_lock.
> My idea is that compaction code would just check PageMovable() and
> PageIsolated() to find a candidate.
> page->mapping->a_ops->isolate_page would do the driver-specific
> necessary locking, revalidate if the page state and succeed
> isolation, or fail. It would need to handle the possibility that the

So you mean that VM can try to isolate false-positive page of the driver?
I don't think it's a good idea. For handling that, every driver should
keep some logics to handle such false-positive which needs each own
data structure or something to remember the page passed from VM
is valid or not. It makes driver's logic more complicated and need
more codes to handle it. It's not a good deal.

> page already doesn't belong to the mapping, which is probably not a
> problem. But what if the driver is a module that was already
> unloaded, and even though we did NULL-check each part from page to
> isolate_page, it points to a function that's already gone? That
> would need some extra handling to prevent that, hm...

Yes, driver should clean up pages is is using. For it, we need some lock.
I think page_lock is good for it because we are migrating *page* and page_lock
have been used it for a long time in migration path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
