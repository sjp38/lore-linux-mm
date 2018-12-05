Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 465746B7184
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:36:55 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so18544322qka.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:36:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d9si10281408qtp.342.2018.12.04.16.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 16:36:54 -0800 (PST)
Date: Tue, 4 Dec 2018 19:36:48 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181205003648.GT2937@redhat.com>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 04, 2018 at 03:03:02PM -0800, Dan Williams wrote:
> On Tue, Dec 4, 2018 at 1:56 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >
> > On 12/4/18 12:28 PM, Dan Williams wrote:
> > > On Mon, Dec 3, 2018 at 4:17 PM <john.hubbard@gmail.com> wrote:
> > >>
> > >> From: John Hubbard <jhubbard@nvidia.com>
> > >>
> > >> Introduces put_user_page(), which simply calls put_page().
> > >> This provides a way to update all get_user_pages*() callers,
> > >> so that they call put_user_page(), instead of put_page().
> > >>
> > >> Also introduces put_user_pages(), and a few dirty/locked variations,
> > >> as a replacement for release_pages(), and also as a replacement
> > >> for open-coded loops that release multiple pages.
> > >> These may be used for subsequent performance improvements,
> > >> via batching of pages to be released.
> > >>
> > >> This is the first step of fixing the problem described in [1]. The steps
> > >> are:
> > >>
> > >> 1) (This patch): provide put_user_page*() routines, intended to be used
> > >>    for releasing pages that were pinned via get_user_pages*().
> > >>
> > >> 2) Convert all of the call sites for get_user_pages*(), to
> > >>    invoke put_user_page*(), instead of put_page(). This involves dozens of
> > >>    call sites, and will take some time.
> > >>
> > >> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
> > >>    implement tracking of these pages. This tracking will be separate from
> > >>    the existing struct page refcounting.
> > >>
> > >> 4) Use the tracking and identification of these pages, to implement
> > >>    special handling (especially in writeback paths) when the pages are
> > >>    backed by a filesystem. Again, [1] provides details as to why that is
> > >>    desirable.
> > >
> > > I thought at Plumbers we talked about using a page bit to tag pages
> > > that have had their reference count elevated by get_user_pages()? That
> > > way there is no need to distinguish put_page() from put_user_page() it
> > > just happens internally to put_page(). At the conference Matthew was
> > > offering to free up a page bit for this purpose.
> > >
> >
> > ...but then, upon further discussion in that same session, we realized that
> > that doesn't help. You need a reference count. Otherwise a random put_page
> > could affect your dma-pinned pages, etc, etc.
> 
> Ok, sorry, I mis-remembered. So, you're effectively trying to capture
> the end of the page pin event separate from the final 'put' of the
> page? Makes sense.
> 
> > I was not able to actually find any place where a single additional page
> > bit would help our situation, which is why this still uses LRU fields for
> > both the two bits required (the RFC [1] still applies), and the dma_pinned_count.
> 
> Except the LRU fields are already in use for ZONE_DEVICE pages... how
> does this proposal interact with those?
> 
> > [1] https://lore.kernel.org/r/20181110085041.10071-7-jhubbard@nvidia.com
> >
> > >> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> > >>
> > >> Reviewed-by: Jan Kara <jack@suse.cz>
> > >
> > > Wish, you could have been there Jan. I'm missing why it's safe to
> > > assume that a single put_user_page() is paired with a get_user_page()?
> > >
> >
> > A put_user_page() per page, or a put_user_pages() for an array of pages. See
> > patch 0002 for several examples.
> 
> Yes, however I was more concerned about validation and trying to
> locate missed places where put_page() is used instead of
> put_user_page().
> 
> It would be interesting to see if we could have a debug mode where
> get_user_pages() returned dynamically allocated pages from a known
> address range and catch drivers that operate on a user-pinned page
> without using the proper helper to 'put' it. I think we might also
> need a ref_user_page() for drivers that may do their own get_page()
> and expect the dma_pinned_count to also increase.

Total crazy idea for this, but this is the right time of day
for this (for me at least it is beer time :)) What about mapping
all struct page in two different range of kernel virtual address
and when get user space is use it returns a pointer from the second
range of kernel virtual address to the struct page. Then in put_page
you know for sure if the code putting the page got it from GUP or
from somewhere else. page_to_pfn() would need some trickery to
handle that.

Dunno if we are running out of kernel virtual address (outside
32bits that i believe we are trying to shot down quietly behind
the bar).

Cheers,
J�r�me
