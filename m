Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id B733D6B712D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:03:14 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id u63so9391021oie.17
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:03:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x206sor8523566oig.63.2018.12.04.15.03.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 15:03:13 -0800 (PST)
MIME-Version: 1.0
References: <20181204001720.26138-1-jhubbard@nvidia.com> <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com> <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
In-Reply-To: <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 15:03:02 -0800
Message-ID: <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 4, 2018 at 1:56 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 12/4/18 12:28 PM, Dan Williams wrote:
> > On Mon, Dec 3, 2018 at 4:17 PM <john.hubbard@gmail.com> wrote:
> >>
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> Introduces put_user_page(), which simply calls put_page().
> >> This provides a way to update all get_user_pages*() callers,
> >> so that they call put_user_page(), instead of put_page().
> >>
> >> Also introduces put_user_pages(), and a few dirty/locked variations,
> >> as a replacement for release_pages(), and also as a replacement
> >> for open-coded loops that release multiple pages.
> >> These may be used for subsequent performance improvements,
> >> via batching of pages to be released.
> >>
> >> This is the first step of fixing the problem described in [1]. The steps
> >> are:
> >>
> >> 1) (This patch): provide put_user_page*() routines, intended to be used
> >>    for releasing pages that were pinned via get_user_pages*().
> >>
> >> 2) Convert all of the call sites for get_user_pages*(), to
> >>    invoke put_user_page*(), instead of put_page(). This involves dozens of
> >>    call sites, and will take some time.
> >>
> >> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
> >>    implement tracking of these pages. This tracking will be separate from
> >>    the existing struct page refcounting.
> >>
> >> 4) Use the tracking and identification of these pages, to implement
> >>    special handling (especially in writeback paths) when the pages are
> >>    backed by a filesystem. Again, [1] provides details as to why that is
> >>    desirable.
> >
> > I thought at Plumbers we talked about using a page bit to tag pages
> > that have had their reference count elevated by get_user_pages()? That
> > way there is no need to distinguish put_page() from put_user_page() it
> > just happens internally to put_page(). At the conference Matthew was
> > offering to free up a page bit for this purpose.
> >
>
> ...but then, upon further discussion in that same session, we realized that
> that doesn't help. You need a reference count. Otherwise a random put_page
> could affect your dma-pinned pages, etc, etc.

Ok, sorry, I mis-remembered. So, you're effectively trying to capture
the end of the page pin event separate from the final 'put' of the
page? Makes sense.

> I was not able to actually find any place where a single additional page
> bit would help our situation, which is why this still uses LRU fields for
> both the two bits required (the RFC [1] still applies), and the dma_pinned_count.

Except the LRU fields are already in use for ZONE_DEVICE pages... how
does this proposal interact with those?

> [1] https://lore.kernel.org/r/20181110085041.10071-7-jhubbard@nvidia.com
>
> >> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> >>
> >> Reviewed-by: Jan Kara <jack@suse.cz>
> >
> > Wish, you could have been there Jan. I'm missing why it's safe to
> > assume that a single put_user_page() is paired with a get_user_page()?
> >
>
> A put_user_page() per page, or a put_user_pages() for an array of pages. See
> patch 0002 for several examples.

Yes, however I was more concerned about validation and trying to
locate missed places where put_page() is used instead of
put_user_page().

It would be interesting to see if we could have a debug mode where
get_user_pages() returned dynamically allocated pages from a known
address range and catch drivers that operate on a user-pinned page
without using the proper helper to 'put' it. I think we might also
need a ref_user_page() for drivers that may do their own get_page()
and expect the dma_pinned_count to also increase.
