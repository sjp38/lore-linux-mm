Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1739A6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 17:48:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h9-v6so8031371pgs.11
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 14:48:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6-v6sor7459912plh.12.2018.10.05.14.48.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 14:48:30 -0700 (PDT)
Date: Fri, 5 Oct 2018 15:48:26 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v2 2/3] mm: introduce put_user_page[s](), placeholder
 versions
Message-ID: <20181005214826.GD20776@ziepe.ca>
References: <20181005040225.14292-1-jhubbard@nvidia.com>
 <20181005040225.14292-3-jhubbard@nvidia.com>
 <20181005151726.GA20776@ziepe.ca>
 <c6f31004-3a67-880b-47bb-b560dfd85343@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6f31004-3a67-880b-47bb-b560dfd85343@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>

On Fri, Oct 05, 2018 at 12:49:06PM -0700, John Hubbard wrote:
> On 10/5/18 8:17 AM, Jason Gunthorpe wrote:
> > On Thu, Oct 04, 2018 at 09:02:24PM -0700, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> Introduces put_user_page(), which simply calls put_page().
> >> This provides a way to update all get_user_pages*() callers,
> >> so that they call put_user_page(), instead of put_page().
> >>
> >> Also introduces put_user_pages(), and a few dirty/locked variations,
> >> as a replacement for release_pages(), for the same reasons.
> >> These may be used for subsequent performance improvements,
> >> via batching of pages to be released.
> >>
> >> This prepares for eventually fixing the problem described
> >> in [1], and is following a plan listed in [2], [3], [4].
> >>
> >> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> >>
> >> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
> >>     Proposed steps for fixing get_user_pages() + DMA problems.
> >>
> >> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
> >>     Bounce buffers (otherwise [2] is not really viable).
> >>
> >> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
> >>     Follow-up discussions.
> >>
> [...]
> >>  
> >> +/* Placeholder version, until all get_user_pages*() callers are updated. */
> >> +static inline void put_user_page(struct page *page)
> >> +{
> >> +	put_page(page);
> >> +}
> >> +
> >> +/* For get_user_pages*()-pinned pages, use these variants instead of
> >> + * release_pages():
> >> + */
> >> +static inline void put_user_pages_dirty(struct page **pages,
> >> +					unsigned long npages)
> >> +{
> >> +	while (npages) {
> >> +		set_page_dirty(pages[npages]);
> >> +		put_user_page(pages[npages]);
> >> +		--npages;
> >> +	}
> >> +}
> > 
> > Shouldn't these do the !PageDirty(page) thing?
> > 
> 
> Well, not yet. This is the "placeholder" patch, in which I planned to keep
> the behavior the same, while I go to all the get_user_pages call sites and change 
> put_page() and release_pages() over to use these new routines.

Hmm.. Well, if it is the right thing to do here, why not include it and
take it out of callers when doing the conversion?

If it is the wrong thing, then let us still take it out of callers
when doing the conversion :)

Just seems like things will be in a better place to make future
changes if all the call sights are de-duplicated and correct.

Jason
