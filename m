Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A050382F64
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:21:05 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so15419257pad.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:21:05 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id w14si3911904pbt.201.2015.09.17.02.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 02:21:05 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so15565995pad.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:21:04 -0700 (PDT)
Date: Thu, 17 Sep 2015 18:19:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150917091956.GA4171@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <55F6D356.5000106@suse.cz>
 <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
 <55F6D641.6010209@suse.cz>
 <CALZtONCKCTRP5r0u5iXYHsQ=uxA-B+1M=4=RPGtFiwo4EOpzeg@mail.gmail.com>
 <20150915042216.GE1860@swordfish>
 <55FA5BFE.6010605@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55FA5BFE.6010605@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (09/17/15 08:21), Vlastimil Babka wrote:
> On 09/15/2015 06:22 AM, Sergey Senozhatsky wrote:
> >On (09/15/15 00:08), Dan Streetman wrote:
> >[..]
> >
> >correct. a bit of internals: we don't scan all the zspages every
> >time. each class has stats for allocated used objects, allocated
> >used objects, etc. so we 'compact' only classes that can be
> >compacted:
> >
> >  static unsigned long zs_can_compact(struct size_class *class)
> >  {
> >          unsigned long obj_wasted;
> >
> >          obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> >                  zs_stat_get(class, OBJ_USED);
> >
> >          obj_wasted /= get_maxobj_per_zspage(class->size,
> >                          class->pages_per_zspage);
> >
> >          return obj_wasted * class->pages_per_zspage;
> >  }
> >
> >if we can free any zspages (which is at least one page), then we
> >attempt to do so.
> >
> >is compaction the root cause of the symptoms Vitaly observe?
> 
> He mentioned the "compact_stalls" counter which in /proc/vmstat is for the
> traditional physical memory compaction, not the zsmalloc-specific one. Which
> would imply high-order allocations. Does zsmalloc try them first before
> falling back to the order-0 zspages linked together manually?

each zspage is a bunch (pages_per_zspage) of alloc_page() calls

        for (i = 0; i < class->pages_per_zspage; i++) {
                struct page *page;

                page = alloc_page(flags);
                if (!page)
                        goto cleanup;

                INIT_LIST_HEAD(&page->lru);
                if (i == 0) {   /* first page */
                        SetPagePrivate(page);
                        set_page_private(page, 0);
                        first_page = page;
                        first_page->inuse = 0;
                }
                if (i == 1)
                        set_page_private(first_page, (unsigned long)page);
                if (i >= 1)
                        set_page_private(page, (unsigned long)first_page);
                if (i >= 2)
                        list_add(&page->lru, &prev_page->lru);
                if (i == class->pages_per_zspage - 1)   /* last page */
                        SetPagePrivate2(page);
                prev_page = page;
        }

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
