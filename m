Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFEBC8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 01:39:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p9so30413467pfj.3
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:39:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p8si44980861pls.83.2018.12.31.22.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Dec 2018 22:39:23 -0800 (PST)
Date: Mon, 31 Dec 2018 22:39:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190101063922.GE6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jan 01, 2019 at 02:02:22AM +0300, Kirill A. Shutemov wrote:
> On Mon, Dec 31, 2018 at 05:42:23AM -0800, Matthew Wilcox wrote:
> > It's unnecessarily hard to find out the size of a potentially huge page.
> > Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> 
> Good idea.
> 
> Should we add page_mask() and page_shift() too?

I'm not opposed to that at all.  I also have a patch to add compound_nr():

+/* Returns the number of pages in this potentially compound page. */
+static inline unsigned long compound_nr(struct page *page)
+{
+       return 1UL << compound_order(page);
+}

I just haven't sent it yet ;-)  It should, perhaps, be called page_count()
or nr_pages() or something.  That covers most of the remaining users of
compound_order() which look awkward.

PAGE_MASK (and its HPAGE counterparts) always confuses me because it's
a mask which returns the upper bits rather than one which returns the
lower bits.
