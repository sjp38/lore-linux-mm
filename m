Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE7D76B0006
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 20:14:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z12-v6so7614857pfl.17
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 17:14:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i189-v6si20685722pfg.281.2018.10.08.17.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 17:14:44 -0700 (PDT)
Date: Mon, 8 Oct 2018 17:14:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
Message-Id: <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
In-Reply-To: <20181008211623.30796-3-jhubbard@nvidia.com>
References: <20181008211623.30796-1-jhubbard@nvidia.com>
	<20181008211623.30796-3-jhubbard@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On Mon,  8 Oct 2018 14:16:22 -0700 john.hubbard@gmail.com wrote:

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
> This prepares for eventually fixing the problem described
> in [1], and is following a plan listed in [2], [3], [4].
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>     Proposed steps for fixing get_user_pages() + DMA problems.
> 
> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
>     Bounce buffers (otherwise [2] is not really viable).
> 
> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
>     Follow-up discussions.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -137,6 +137,8 @@ extern int overcommit_ratio_handler(struct ctl_table *, int, void __user *,
>  				    size_t *, loff_t *);
>  extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
>  				    size_t *, loff_t *);
> +int set_page_dirty(struct page *page);
> +int set_page_dirty_lock(struct page *page);
>  
>  #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
>  
> @@ -943,6 +945,51 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> +/*
> + * Pages that were pinned via get_user_pages*() should be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below.
> + */
> +static inline void put_user_page(struct page *page)
> +{
> +	put_page(page);
> +}
> +
> +static inline void put_user_pages_dirty(struct page **pages,
> +					unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		if (!PageDirty(pages[index]))

Both put_page() and set_page_dirty() handle compound pages.  But
because of the above statement, put_user_pages_dirty() might misbehave? 
Or maybe it won't - perhaps the intent here is to skip dirtying the
head page if the sub page is clean?  Please clarify, explain and add
comment if so.

> +			set_page_dirty(pages[index]);
> +
> +		put_user_page(pages[index]);
> +	}
> +}
> +
> +static inline void put_user_pages_dirty_lock(struct page **pages,
> +					     unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		if (!PageDirty(pages[index]))
> +			set_page_dirty_lock(pages[index]);

Ditto.

> +		put_user_page(pages[index]);
> +	}
> +}
> +
> +static inline void put_user_pages(struct page **pages,
> +				  unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++)
> +		put_user_page(pages[index]);
> +}
> +

Otherwise looks OK.  Ish.  But it would be nice if that comment were to
explain *why* get_user_pages() pages must be released with
put_user_page().

Also, maintainability.  What happens if someone now uses put_page() by
mistake?  Kernel fails in some mysterious fashion?  How can we prevent
this from occurring as code evolves?  Is there a cheap way of detecting
this bug at runtime?
