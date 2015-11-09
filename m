Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 28E026B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 06:45:41 -0500 (EST)
Received: by wmdw130 with SMTP id w130so25743067wmd.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 03:45:40 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 17si16082924wmk.116.2015.11.09.03.45.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 03:45:39 -0800 (PST)
Received: by wmww144 with SMTP id w144so72439246wmw.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 03:45:39 -0800 (PST)
Date: Mon, 9 Nov 2015 13:45:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: introduce page reference manipulation functions
Message-ID: <20151109114537.GA3903@node.shutemov.name>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151109075337.GC472@swordfish>
 <CAAmzW4MugYCu1+ZsRp63o=26eTuJG22C+nNrGBhDJvQDOzbQJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4MugYCu1+ZsRp63o=26eTuJG22C+nNrGBhDJvQDOzbQJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Nov 09, 2015 at 05:00:32PM +0900, Joonsoo Kim wrote:
> 2015-11-09 16:53 GMT+09:00 Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com>:
> > Hi,
> >
> > On (11/09/15 16:23), Joonsoo Kim wrote:
> > [..]
> >> +static inline int page_count(struct page *page)
> >> +{
> >> +     return atomic_read(&compound_head(page)->_count);
> >> +}
> >> +
> >> +static inline void set_page_count(struct page *page, int v)
> >> +{
> >> +     atomic_set(&page->_count, v);
> >> +}
> >> +
> >> +/*
> >> + * Setup the page count before being freed into the page allocator for
> >> + * the first time (boot or memory hotplug)
> >> + */
> >> +static inline void init_page_count(struct page *page)
> >> +{
> >> +     set_page_count(page, 1);
> >> +}
> >> +
> >> +static inline void page_ref_add(struct page *page, int nr)
> >> +{
> >> +     atomic_add(nr, &page->_count);
> >> +}
> >
> > Since page_ref_FOO wrappers operate with page->_count and there
> > are already page_count()/set_page_count()/etc. may be name new
> > wrappers in page_count_FOO() manner?
> 
> Hello,
> 
> I used that page_count_ before but change my mind.
> I think that ref is more relevant to this operation.
> Perhaps, it'd be better to change page_count()/set_page_count()
> to page_ref()/set_page_ref().

What about get_page() vs. page_cache_get() and put_page() vs.
page_cache_release()? Two different helpers for the same thing is annyoing
me for some time (plus PAGE_SIZE vs. PAGE_CACHE_SIZE, etc.).

If you want coherent API you might want to get them consitent too.

> FYI, some functions such as page_(un)freeze_refs uses ref. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
