Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 206A66B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:38:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23-v6so9318515pfm.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:38:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o16-v6si9032860pgc.603.2018.05.21.07.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 May 2018 07:38:33 -0700 (PDT)
Date: Mon, 21 May 2018 07:38:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
Message-ID: <20180521143830.GA25109@bombadil.infradead.org>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca>
 <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
 <20180518173637.GF15611@ziepe.ca>
 <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
 <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com>
 <20180519032400.GA12517@ziepe.ca>
 <CAPcyv4iGmUg108O-s1h6_YxmjQgMcV_pFpciObHh3zJkTOKfKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iGmUg108O-s1h6_YxmjQgMcV_pFpciObHh3zJkTOKfKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Christopher Lameter <cl@linux.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, May 18, 2018 at 08:51:38PM -0700, Dan Williams wrote:
> >> +1, and I am now super-interested in this conversation, because
> >> after tracking down a kernel BUG to this classic mistaken pattern:
> >>
> >>     get_user_pages (on file-backed memory from ext4)
> >>     ...do some DMA
> >>     set_pages_dirty
> >>     put_page(s)
> >
> > Ummm, RDMA has done essentially that since 2005, since when did it
> > become wrong? Do you have some references? Is there some alternative?
> >
> > See __ib_umem_release
> >
> >> ...there is (rarely!) a backtrace from ext4, that disavows ownership of
> >> any such pages.
> >
> > Yes, I've seen that oops with RDMA, apparently isn't actually that
> > rare if you tweak things just right.
> >
> > I thought it was an obscure ext4 bug :(
> >
> >> Because the obvious "fix" in device driver land is to use a dedicated
> >> buffer for DMA, and copy to the filesystem buffer, and of course I will
> >> get *killed* if I propose such a performance-killing approach. But a
> >> core kernel fix really is starting to sound attractive.
> >
> > Yeah, killed is right. That idea totally cripples RDMA.
> >
> > What is the point of get_user_pages FOLL_WRITE if you can't write to
> > and dirty the pages!?!
> 
> You're oversimplifying the problem, here are the details:
> 
> https://www.spinics.net/lists/linux-mm/msg142700.html

Suggestion 1:

in get_user_pages_fast(), mark the page as dirty, but don't tag the radix
tree entry as dirty.  Then vmscan() won't find it when it's looking to
write out dirty pages.  Only mark it as dirty in the radix tree once we
call set_page_dirty_lock().

Suggestion 2:

in get_user_pages_fast(), replace the page in the radix tree with a special
entry that means "page under io".  In set_page_dirty_lock(), replace the
"page under io" entry with the struct page pointer.

Both of these suggestions have trouble with simultaneous sub-page IOs to the
same page.  Do we care?  I suspect we might as pages get larger (see also:
supporting THP pages in the page cache).
