Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98E226B7403
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:16:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so9442411edm.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:16:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f48si1691045ede.180.2018.12.05.03.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:16:50 -0800 (PST)
Date: Wed, 5 Dec 2018 12:16:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181205111646.GF22304@quack2.suse.cz>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue 04-12-18 13:56:36, John Hubbard wrote:
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

Exactly.

> I was not able to actually find any place where a single additional page
> bit would help our situation, which is why this still uses LRU fields for
> both the two bits required (the RFC [1] still applies), and the dma_pinned_count.

So single page bit could help you with performance. In 99% of cases there's
just one reference from GUP. So if you could store that info in page flags,
you could safe yourself a relatively expensive removal from LRU and putting
it back to make space in struct page for proper refcount. But since you
report that the performance isn't that horrible, I'd leave this idea on a
backburner. We can always implement it later in case we find in future we
need to improve the performance.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
