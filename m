Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB2066B02EF
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 11:54:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t78-v6so11911894pfa.8
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 08:54:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12-v6sor4826749plt.115.2018.07.09.08.53.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 08:53:59 -0700 (PDT)
Date: Mon, 9 Jul 2018 09:53:57 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page(), placeholder version
Message-ID: <20180709155357.GA13496@ziepe.ca>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709080554.21931-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709080554.21931-2-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon, Jul 09, 2018 at 01:05:53AM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Introduces put_user_page(), which simply calls put_page().
> This provides a safe way to update all get_user_pages*() callers,
> so that they call put_user_page(), instead of put_page().
> 
> Also adds release_user_pages(), a drop-in replacement for
> release_pages(). This is intended to be easily grep-able,
> for later performance improvements, since release_user_pages
> is not batched like release_pages is, and is significantly
> slower.
> 
> Subsequent patches will add functionality to put_user_page().
> 
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>  include/linux/mm.h | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9ffe380..db4a211aad79 100644
> +++ b/include/linux/mm.h
> @@ -923,6 +923,20 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> +/* Placeholder version, until all get_user_pages*() callers are updated. */
> +static inline void put_user_page(struct page *page)
> +{
> +	put_page(page);
> +}
> +
> +/* A drop-in replacement for release_pages(): */
> +static inline void release_user_pages(struct page **pages,
> +				      unsigned long npages)
> +{
> +	while (npages)
> +		put_user_page(pages[--npages]);
> +}
> +
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif

Just as question: Do you think it is worthwhile to have a
release_user_page_dirtied() helper as well?

Ie to indicate that a pages that were grabbed under GUP FOLL_WRITE
were actually written too?

Keeps more of these unimportant details out of the drivers..

Jason
