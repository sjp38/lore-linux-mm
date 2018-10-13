Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E10896B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 23:55:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o3-v6so10737619pll.7
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:55:21 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id y9-v6si3443692pgs.214.2018.10.12.20.55.19
        for <linux-mm@kvack.org>;
        Fri, 12 Oct 2018 20:55:20 -0700 (PDT)
Date: Sat, 13 Oct 2018 14:55:16 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181013035516.GA18822@dastard>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012060014.10242-5-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Thu, Oct 11, 2018 at 11:00:12PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Add two struct page fields that, combined, are unioned with
> struct page->lru. There is no change in the size of
> struct page. These new fields are for type safety and clarity.
> 
> Also add page flag accessors to test, set and clear the new
> page->dma_pinned_flags field.
> 
> The page->dma_pinned_count field will be used in upcoming
> patches
> 
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/mm_types.h   | 22 +++++++++++++-----
>  include/linux/page-flags.h | 47 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 63 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5ed8f6292a53..017ab82e36ca 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -78,12 +78,22 @@ struct page {
>  	 */
>  	union {
>  		struct {	/* Page cache and anonymous pages */
> -			/**
> -			 * @lru: Pageout list, eg. active_list protected by
> -			 * zone_lru_lock.  Sometimes used as a generic list
> -			 * by the page owner.
> -			 */
> -			struct list_head lru;
> +			union {
> +				/**
> +				 * @lru: Pageout list, eg. active_list protected
> +				 * by zone_lru_lock.  Sometimes used as a
> +				 * generic list by the page owner.
> +				 */
> +				struct list_head lru;
> +				/* Used by get_user_pages*(). Pages may not be
> +				 * on an LRU while these dma_pinned_* fields
> +				 * are in use.
> +				 */
> +				struct {
> +					unsigned long dma_pinned_flags;
> +					atomic_t      dma_pinned_count;
> +				};
> +			};

Isn't this broken for mapped file-backed pages? i.e. they may be
passed as the user buffer to read/write direct IO and so the pages
passed to gup will be on the active/inactive LRUs. hence I can't see
how you can have dual use of the LRU list head like this....

What am I missing here?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
