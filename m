Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2916B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 04:46:25 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id u194so15966663qka.20
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 01:46:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t58si2480931qtt.337.2018.02.13.01.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 01:46:24 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1D9iJX5102035
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 04:46:23 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g3tbcqc45-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 04:46:22 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 13 Feb 2018 09:46:19 -0000
Date: Tue, 13 Feb 2018 11:46:11 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm: make start_isolate_page_range() fail if
 already isolated
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
 <20180212222056.9735-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180212222056.9735-2-mike.kravetz@oracle.com>
Message-Id: <20180213094610.GA2196@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On Mon, Feb 12, 2018 at 02:20:54PM -0800, Mike Kravetz wrote:
> start_isolate_page_range() is used to set the migrate type of a
> page block to MIGRATE_ISOLATE while attempting to start a
> migration operation.  It is assumed that only one thread is
> attempting such an operation, and due to the limited number of
> callers this is generally the case.  However, there are no
> guarantees and it is 'possible' for two threads to operate on
> the same range.
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

Nit: please s/Returns/Return:/ and keep the period in the end 

> + * or any part of the range is already set to MIGRATE_ISOLATE.
>   */
>  int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  			     unsigned migratetype, bool skip_hwpoisoned_pages)
> -- 
> 2.13.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
