Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CADF8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 15:26:39 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so2714623pgm.4
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 12:26:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i5si6793179pgn.243.2019.01.08.12.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 Jan 2019 12:26:37 -0800 (PST)
Date: Tue, 8 Jan 2019 12:26:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Remove redundant test from find_get_pages_contig
Message-ID: <20190108202635.GE6310@bombadil.infradead.org>
References: <20190107200224.13260-1-willy@infradead.org>
 <20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
 <20190107223935.GC6310@bombadil.infradead.org>
 <20190107150904.09e56f51acaf417ed21f13a3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107150904.09e56f51acaf417ed21f13a3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2019 at 03:09:04PM -0800, Andrew Morton wrote:
> On Mon, 7 Jan 2019 14:39:35 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Mon, Jan 07, 2019 at 02:33:19PM -0800, Andrew Morton wrote:
> > > On Mon,  7 Jan 2019 12:02:24 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> > > 
> > > > After we establish a reference on the page, we check the pointer continues
> > > > to be in the correct position in i_pages.  There's no need to check the
> > > > page->mapping or page->index afterwards; if those can change after we've
> > > > got the reference, they can change after we return the page to the caller.
> > > 
> > > But that isn't what the comment says.
> > 
> > Right.  That patch from Nick moved the check from before taking the
> > ref to after taking the ref.  It was racy to have it before.  But it's
> > unnecessary to have it afterwards -- pages can't move once there's a
> > ref on them.  Or if they can move, they can move after the ref is taken.
> 
> So Nick's patch was never necessary?  I wonder what inspired it.

It was necessary to not check before the pin; that was clearly correct.
Checking after the pin, even with the code the way it was in 2006, was
unnecessary.  Look with a bit more context:

-               if (page->mapping == NULL || page->index != index)
-                       break;
-
                if (!page_cache_get_speculative(page))
                        goto repeat;
 
                /* Has the page moved? */
                if (unlikely(page != *((void **)pages[i]))) {
                        page_cache_release(page);
                        goto repeat;
                }
 
+               /*
+                * must check mapping and index after taking the ref.
+                * otherwise we can get both false positives and false
+                * negatives, which is just confusing to the caller.
+                */
+               if (page->mapping == NULL || page->index != index) {
+                       page_cache_release(page);
+                       break;
+               }
+

It's not immediately obvious that those added lines merely re-check the
condition checked by the 'page != *((void **)pages[i])', but if you think
about it, if page->index changes, then page must necessarily move within
the radix tree / xarray.

> Would it be excessively cautious to put a WARN_ON_ONCE() in there for a
> while?

I think it would ... it'd get in the way of a subsequent patch to store
only head pages in the page cache.
