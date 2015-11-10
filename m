Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E5D1B6B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 19:28:17 -0500 (EST)
Received: by pasz6 with SMTP id z6so221731060pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 16:28:17 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id t13si963260pas.21.2015.11.09.16.28.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Nov 2015 16:28:17 -0800 (PST)
Date: Tue, 10 Nov 2015 09:28:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm: introduce page reference manipulation functions
Message-ID: <20151110002842.GC13894@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151109075337.GC472@swordfish>
 <CAAmzW4MugYCu1+ZsRp63o=26eTuJG22C+nNrGBhDJvQDOzbQJw@mail.gmail.com>
 <20151109114537.GA3903@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109114537.GA3903@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Mon, Nov 09, 2015 at 01:45:37PM +0200, Kirill A. Shutemov wrote:
> On Mon, Nov 09, 2015 at 05:00:32PM +0900, Joonsoo Kim wrote:
> > 2015-11-09 16:53 GMT+09:00 Sergey Senozhatsky
> > <sergey.senozhatsky.work@gmail.com>:
> > > Hi,
> > >
> > > On (11/09/15 16:23), Joonsoo Kim wrote:
> > > [..]
> > >> +static inline int page_count(struct page *page)
> > >> +{
> > >> +     return atomic_read(&compound_head(page)->_count);
> > >> +}
> > >> +
> > >> +static inline void set_page_count(struct page *page, int v)
> > >> +{
> > >> +     atomic_set(&page->_count, v);
> > >> +}
> > >> +
> > >> +/*
> > >> + * Setup the page count before being freed into the page allocator for
> > >> + * the first time (boot or memory hotplug)
> > >> + */
> > >> +static inline void init_page_count(struct page *page)
> > >> +{
> > >> +     set_page_count(page, 1);
> > >> +}
> > >> +
> > >> +static inline void page_ref_add(struct page *page, int nr)
> > >> +{
> > >> +     atomic_add(nr, &page->_count);
> > >> +}
> > >
> > > Since page_ref_FOO wrappers operate with page->_count and there
> > > are already page_count()/set_page_count()/etc. may be name new
> > > wrappers in page_count_FOO() manner?
> > 
> > Hello,
> > 
> > I used that page_count_ before but change my mind.
> > I think that ref is more relevant to this operation.
> > Perhaps, it'd be better to change page_count()/set_page_count()
> > to page_ref()/set_page_ref().
> 
> What about get_page() vs. page_cache_get() and put_page() vs.
> page_cache_release()? Two different helpers for the same thing is annyoing
> me for some time (plus PAGE_SIZE vs. PAGE_CACHE_SIZE, etc.).
> 
> If you want coherent API you might want to get them consitent too.

In fact, consistent naming is out of interest of this patchset. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
