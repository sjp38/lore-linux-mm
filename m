Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8AB96B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 09:10:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16-v6so3972981pgv.17
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:10:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1-v6si15139025plv.205.2018.11.11.06.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 06:10:57 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABE98kW005070
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 09:10:56 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2npdv7fe2q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 09:10:56 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 11 Nov 2018 14:10:53 -0000
Date: Sun, 11 Nov 2018 16:10:43 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 2/6] mm: introduce put_user_page*(), placeholder
 versions
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <20181110085041.10071-3-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181110085041.10071-3-jhubbard@nvidia.com>
Message-Id: <20181111141042.GC9857@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

Hi,

On Sat, Nov 10, 2018 at 12:50:37AM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Introduces put_user_page(), which simply calls put_page().
> This provides a way to update all get_user_pages*() callers,
> so that they call put_user_page(), instead of put_page().
> 
> Also introduces put_user_pages(), and a few dirty/locked variations,
> as a replacement for release_pages(), and also as a replacement
> for open-coded loops that release multiple pages.
> These may be used for subsequent performance improvements,
> via batching of pages to be released.
> 
> This is the first step of fixing the problem described in [1]. The steps
> are:
> 
> 1) (This patch): provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem. Again, [1] provides details as to why that is
>    desirable.
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/mm.h | 20 ++++++++++++
>  mm/swap.c          | 80 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 100 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363..09fbb2c81aba 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -963,6 +963,26 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
> 
> +/*
> + * put_user_page() - release a page that had previously been acquired via
> + * a call to one of the get_user_pages*() functions.

If your intention was to make it kernel-doc comment, it should start with

/**

and the @page parameter description should follow the brief description.

> + *
> + * Pages that were pinned via get_user_pages*() must be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below. This is so that eventually, pages that are pinned via
> + * get_user_pages*() can be separately tracked and uniquely handled. In
> + * particular, interactions with RDMA and filesystems need special
> + * handling.
> + */
> +static inline void put_user_page(struct page *page)
> +{
> +	put_page(page);
> +}
> +
> +void put_user_pages_dirty(struct page **pages, unsigned long npages);
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> +void put_user_pages(struct page **pages, unsigned long npages);
> +
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif
> diff --git a/mm/swap.c b/mm/swap.c
> index aa483719922e..bb8c32595e5f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -133,6 +133,86 @@ void put_pages_list(struct list_head *pages)
>  }
>  EXPORT_SYMBOL(put_pages_list);
> 
> +typedef int (*set_dirty_func)(struct page *page);
> +
> +static void __put_user_pages_dirty(struct page **pages,
> +				   unsigned long npages,
> +				   set_dirty_func sdf)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		struct page *page = compound_head(pages[index]);
> +
> +		if (!PageDirty(page))
> +			sdf(page);
> +
> +		put_user_page(page);
> +	}
> +}
> +
> +/*

/**

> + * put_user_pages_dirty() - for each page in the @pages array, make
> + * that page (or its head page, if a compound page) dirty, if it was
> + * previously listed as clean. Then, release the page using
> + * put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * set_page_dirty(), which does not lock the page, is used here.
> + * Therefore, it is the caller's responsibility to ensure that this is
> + * safe. If not, then put_user_pages_dirty_lock() should be called instead.
> + *
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *

The parameter descriptions should be after the brief function description
and before the details

> + */
> +void put_user_pages_dirty(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty);
> +
> +/*
> + * put_user_pages_dirty_lock() - for each page in the @pages array, make
> + * that page (or its head page, if a compound page) dirty, if it was
> + * previously listed as clean. Then, release the page using
> + * put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * This is just like put_user_pages_dirty(), except that it invokes
> + * set_page_dirty_lock(), instead of set_page_dirty().
> + *
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.

Same here

> + *
> + */
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty_lock);
> +
> +/*
> + * put_user_pages() - for each page in the @pages array, release the page
> + * using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *

And here.

> + */
> +void put_user_pages(struct page **pages, unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++)
> +		put_user_page(pages[index]);
> +}
> +EXPORT_SYMBOL(put_user_pages);
> +
>  /*
>   * get_kernel_pages() - pin kernel pages in memory
>   * @kiov:	An array of struct kvec structures
> -- 
> 2.19.1
> 

-- 
Sincerely yours,
Mike.
