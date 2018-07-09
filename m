Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4183A6B02FA
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:11:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12-v6so7173714edi.12
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:11:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14-v6si2198669edr.390.2018.07.09.09.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 09:11:55 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:11:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page(), placeholder version
Message-ID: <20180709161154.46chzohwnzzbrtis@quack2.suse.cz>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709080554.21931-2-jhubbard@nvidia.com>
 <20180709155357.GA13496@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709155357.GA13496@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon 09-07-18 09:53:57, Jason Gunthorpe wrote:
> On Mon, Jul 09, 2018 at 01:05:53AM -0700, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > Introduces put_user_page(), which simply calls put_page().
> > This provides a safe way to update all get_user_pages*() callers,
> > so that they call put_user_page(), instead of put_page().
> > 
> > Also adds release_user_pages(), a drop-in replacement for
> > release_pages(). This is intended to be easily grep-able,
> > for later performance improvements, since release_user_pages
> > is not batched like release_pages is, and is significantly
> > slower.
> > 
> > Subsequent patches will add functionality to put_user_page().
> > 
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> >  include/linux/mm.h | 14 ++++++++++++++
> >  1 file changed, 14 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index a0fbb9ffe380..db4a211aad79 100644
> > +++ b/include/linux/mm.h
> > @@ -923,6 +923,20 @@ static inline void put_page(struct page *page)
> >  		__put_page(page);
> >  }
> >  
> > +/* Placeholder version, until all get_user_pages*() callers are updated. */
> > +static inline void put_user_page(struct page *page)
> > +{
> > +	put_page(page);
> > +}
> > +
> > +/* A drop-in replacement for release_pages(): */
> > +static inline void release_user_pages(struct page **pages,
> > +				      unsigned long npages)
> > +{
> > +	while (npages)
> > +		put_user_page(pages[--npages]);
> > +}
> > +
> >  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> >  #define SECTION_IN_PAGE_FLAGS
> >  #endif
> 
> Just as question: Do you think it is worthwhile to have a
> release_user_page_dirtied() helper as well?
> 
> Ie to indicate that a pages that were grabbed under GUP FOLL_WRITE
> were actually written too?
> 
> Keeps more of these unimportant details out of the drivers..

Yeah, I think that would be nice as well.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
