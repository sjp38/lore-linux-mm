Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB2BC8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 22:14:18 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so31894386pfi.9
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 19:14:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j39si3120947plb.272.2019.01.01.19.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Jan 2019 19:14:17 -0800 (PST)
Date: Tue, 1 Jan 2019 19:14:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190102031414.GG6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <87y385awg6.fsf@linux.ibm.com>
 <20190101063031.GD6310@bombadil.infradead.org>
 <87lg447knf.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lg447knf.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jan 01, 2019 at 03:41:00PM +0530, Aneesh Kumar K.V wrote:
> Matthew Wilcox <willy@infradead.org> writes:
> > On Tue, Jan 01, 2019 at 08:57:53AM +0530, Aneesh Kumar K.V wrote:
> >> Matthew Wilcox <willy@infradead.org> writes:
> >> > +/* Returns the number of bytes in this potentially compound page. */
> >> > +static inline unsigned long page_size(struct page *page)
> >> > +{
> >> > +	return (unsigned long)PAGE_SIZE << compound_order(page);
> >> > +}
> >> > +
> >> 
> >> How about compound_page_size() to make it clear this is for
> >> compound_pages? Should we make it work with Tail pages by doing
> >> compound_head(page)?
> >
> > I think that's a terrible idea.  Actually, I think the whole way we handle
> > compound pages is terrible; we should only ever see head pages.  Doing
> > page cache lookups should only give us head pages.  Calling pfn_to_page()
> > should give us the head page.  We should only put head pages into SG lists.
> > Everywhere you see a struct page should only be a head page.
> >
> > I know we're far from that today, and there's lots of work to be done
> > to get there.  But the current state of handling compound pages is awful
> > and confusing.
> >
> > Also, page_size() isn't just for compound pages.  It works for regular
> > pages too.  I'd be open to putting a VM_BUG_ON(PageTail(page)) in it
> > to catch people who misuse it.
> 
> Adding VM_BUG_ON is a good idea.

I'm no longer sure about that.  If someone has a tail page and asks for
page_size(page), I think they want to get PAGE_SIZE back.  Just look at the current users in that patch; they all process page_size() number of bytes, then
move on to the next struct page.

If they somehow happen to have a tail page, then we want them to process
PAGE_SIZE bytes at a time, then move onto the next page, until they hit
a head page.  If calling page_size() on a tail page returned the size
of the entire compound page, then it would process some bytes from pages
which weren't part of this compound page.

So I think the current definition of page_size() is right.
