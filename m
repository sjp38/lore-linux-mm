Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D48B56B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:16:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d139so2716755oig.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:16:09 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id q66si547715iod.154.2016.05.16.18.16.08
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 18:16:09 -0700 (PDT)
Date: Tue, 17 May 2016 10:16:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160517011608.GC31335@bbox>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-3-git-send-email-minchan@kernel.org>
 <20160516070455.GA28813@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160516070455.GA28813@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Mon, May 16, 2016 at 04:04:55PM +0900, Sergey Senozhatsky wrote:
> On (05/09/16 11:20), Minchan Kim wrote:
> > +++ b/include/linux/migrate.h
> > @@ -32,11 +32,16 @@ extern char *migrate_reason_names[MR_TYPES];
> >  
> >  #ifdef CONFIG_MIGRATION
> >  
> > +extern int PageMovable(struct page *page);
> > +extern void __SetPageMovable(struct page *page, struct address_space *mapping);
> > +extern void __ClearPageMovable(struct page *page);
> >  extern void putback_movable_pages(struct list_head *l);
> >  extern int migrate_page(struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> >  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
> >  		unsigned long private, enum migrate_mode mode, int reason);
> > +extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> > +extern void putback_movable_page(struct page *page);
> >  
> >  extern int migrate_prep(void);
> >  extern int migrate_prep_local(void);
> 
> __ClearPageMovable() is under CONFIG_MIGRATION in include/linux/migrate.h,
> but zsmalloc checks for CONFIG_COMPACTION.

Thanks!

PageMovable check function should be in compact.c, I think.
I will fix it.


> 
> can we have stub declarations of movable functions for !CONFIG_MIGRATION builds?
> otherwise the users (zsmalloc, for example) have to do things like
> 
> static void reset_page(struct page *page)
> {
> #ifdef CONFIG_COMPACTION
>         __ClearPageMovable(page);
> #endif
>         clear_bit(PG_private, &page->flags);
>         clear_bit(PG_private_2, &page->flags);
>         set_page_private(page, 0);
>         ClearPageHugeObject(page);
>         page->freelist = NULL;
> }
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
