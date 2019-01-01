Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 422F08E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 01:30:35 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so30308406pfa.18
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:30:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m28si46373141pgn.273.2018.12.31.22.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Dec 2018 22:30:33 -0800 (PST)
Date: Mon, 31 Dec 2018 22:30:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190101063031.GD6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <87y385awg6.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y385awg6.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jan 01, 2019 at 08:57:53AM +0530, Aneesh Kumar K.V wrote:
> Matthew Wilcox <willy@infradead.org> writes:
> > +/* Returns the number of bytes in this potentially compound page. */
> > +static inline unsigned long page_size(struct page *page)
> > +{
> > +	return (unsigned long)PAGE_SIZE << compound_order(page);
> > +}
> > +
> 
> How about compound_page_size() to make it clear this is for
> compound_pages? Should we make it work with Tail pages by doing
> compound_head(page)?

I think that's a terrible idea.  Actually, I think the whole way we handle
compound pages is terrible; we should only ever see head pages.  Doing
page cache lookups should only give us head pages.  Calling pfn_to_page()
should give us the head page.  We should only put head pages into SG lists.
Everywhere you see a struct page should only be a head page.

I know we're far from that today, and there's lots of work to be done
to get there.  But the current state of handling compound pages is awful
and confusing.

Also, page_size() isn't just for compound pages.  It works for regular
pages too.  I'd be open to putting a VM_BUG_ON(PageTail(page)) in it
to catch people who misuse it.
