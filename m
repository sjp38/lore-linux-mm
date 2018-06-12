Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71E4F6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:36:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p29-v6so11857005pfi.19
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 04:36:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m189-v6si608407pga.107.2018.06.12.04.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Jun 2018 04:36:17 -0700 (PDT)
Date: Tue, 12 Jun 2018 04:36:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Distinguishing VMalloc pages
Message-ID: <20180612113615.GB19433@bombadil.infradead.org>
References: <20180611121129.GB12912@bombadil.infradead.org>
 <c99d981a-d55e-1759-a14a-4ef856072618@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c99d981a-d55e-1759-a14a-4ef856072618@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Tue, Jun 12, 2018 at 12:54:09PM +0300, Igor Stoppa wrote:
> On 11/06/18 15:11, Matthew Wilcox wrote:
> > I tried to use the page->mapping field in my earlier patch and that was
> > a problem because page_mapping() would return non-NULL, which broke
> > user-space unmapping of vmalloced pages through the zap_pte_range ->
> > set_page_dirty path.
> 
> This seems pretty similar to what I am doing in a preparatory patch for
> pmalloc (I'm still working on this, I just got swamped in day-job related
> stuff, but I am progressing toward an example with IMA).
> So it looks like my patch won't work, after all?
> 
> Although, in your case, you noticed a problem with userspace, while I do
> not care at all about that, so maybe there is some wriggling space there ...

Yes; if your pages can never be mapped to userspace, then there's no
problem.  Many other users of struct page use the page->mapping field
for other purposes.

> Why not having a reference (either direct or indirect) to the actual
> vmap area, and then the flag there, instead?

Because what we're trying to do is find out "Given a random struct page,
what is it used for".  It might be page cache, it might be slab, it
might be anything.  We can't go round randomly dereferencing pointers
and seeing what pot of gold is at the end of that rainbow.

> I do not know the specific use case you have in mind - if any - but I
> think that if one is already trying to figure out what sort of use the
> vmalloc page is put to, then probably pretty soon there will be a need
> for a reference to the area.
> 
> So what if the page could hold a reference the area, where there would
> be more space available for specifying what it is used for?

It might be useful to refer to the earlier patch which included that
information:

https://www.spinics.net/lists/linux-mm/msg152818.html
