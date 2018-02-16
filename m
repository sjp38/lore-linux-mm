Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E49E66B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 19:40:36 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id z2so218234ite.5
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 16:40:36 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f10si717549ioa.222.2018.02.15.16.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 16:40:35 -0800 (PST)
Subject: Re: [RFC PATCH 1/3] mm: make start_isolate_page_range() fail if
 already isolated
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
 <20180212222056.9735-2-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <eea67841-0656-6a60-af92-46a2e1a53350@oracle.com>
Date: Thu, 15 Feb 2018 16:40:28 -0800
MIME-Version: 1.0
In-Reply-To: <20180212222056.9735-2-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On 02/12/2018 02:20 PM, Mike Kravetz wrote:
> start_isolate_page_range() is used to set the migrate type of a
> page block to MIGRATE_ISOLATE while attempting to start a
> migration operation.  It is assumed that only one thread is
> attempting such an operation, and due to the limited number of
> callers this is generally the case.  However, there are no
> guarantees and it is 'possible' for two threads to operate on
> the same range.

I confirmed my suspicions that this is possible today.

As a test, I created a large CMA area at boot time.   I wrote some
code to exercise large allocations and frees via cma_alloc()/cma_release().
At the same time, I just allocated and freed'ed gigantic pages via the
sysfs interface.

After a little bit of running, 'free memory' on the system went to
zero.  After 'stopping' the tests, I observed that most zone normal
page blocks were marked as MIGRATE_ISOLATE.  Hence 'not available'.

As mentioned in the commit message, I doubt we will see this is
normal operations.  But, my testing confirms that it is possible.
Therefore, we should consider a patch like this or some other form
of mitigation even of we don't move forward with adding the new
interface.

-- 
Mike Kravetz

> 
> Since start_isolate_page_range() is called at the beginning of
> such operations, have it return -EBUSY if MIGRATE_ISOLATE is
> already set.
> 
> This will allow start_isolate_page_range to serve as a
> synchronization mechanism and will allow for more general use
> of callers making use of these interfaces.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/page_alloc.c     |  8 ++++----
>  mm/page_isolation.c | 10 +++++++++-
>  2 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 76c9688b6a0a..064458f317bf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7605,11 +7605,11 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   * @gfp_mask:	GFP mask to use during compaction
>   *
>   * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
> - * aligned, however it's the caller's responsibility to guarantee that
> - * we are the only thread that changes migrate type of pageblocks the
> - * pages fall in.
> + * aligned.  The PFN range must belong to a single zone.
>   *
> - * The PFN range must belong to a single zone.
> + * The first thing this routine does is attempt to MIGRATE_ISOLATE all
> + * pageblocks in the range.  Once isolated, the pageblocks should not
> + * be modified by others.
>   *
>   * Returns zero on success or negative error code.  On success all
>   * pages which PFN is in [start, end) are allocated for the caller and
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 165ed8117bd1..e815879d525f 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -28,6 +28,13 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
>  
>  	spin_lock_irqsave(&zone->lock, flags);
>  
> +	/*
> +	 * We assume we are the only ones trying to isolate this block.
> +	 * If MIGRATE_ISOLATE already set, return -EBUSY
> +	 */
> +	if (is_migrate_isolate_page(page))
> +		goto out;
> +
>  	pfn = page_to_pfn(page);
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = pageblock_nr_pages;
> @@ -166,7 +173,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>   * future will not be allocated again.
>   *
>   * start_pfn/end_pfn must be aligned to pageblock_order.
> - * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
> + * Returns 0 on success and -EBUSY if any part of range cannot be isolated
> + * or any part of the range is already set to MIGRATE_ISOLATE.
>   */
>  int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			     unsigned migratetype, bool skip_hwpoisoned_pages)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
