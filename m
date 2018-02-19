Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38F456B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 05:19:38 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w102so5645841wrb.21
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 02:19:38 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id c7si11728839edn.441.2018.02.19.02.19.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 02:19:36 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 12199B86ED
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 10:19:36 +0000 (GMT)
Date: Mon, 19 Feb 2018 10:19:35 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Message-ID: <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180216160121.519788537@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

My skynet.ie/csn.ul.ie address has been defunct for quite some time.
Mail sent to it is not guaranteed to get to me.

On Fri, Feb 16, 2018 at 10:01:11AM -0600, Christoph Lameter wrote:
> Over time as the kernel is churning through memory it will break
> up larger pages and as time progresses larger contiguous allocations
> will no longer be possible. This is an approach to preserve these
> large pages and prevent them from being broken up.
> 
> <SNIP>
> Idea-by: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>
> 
> First performance tests in a virtual enviroment show
> a hackbench improvement by 6% just by increasing
> the page size used by the page allocator to order 3.
> 

The phrasing here is confusing. hackbench is not very intensive in terms of
memory, it's more fork intensive where I find it extremely unlikely that
it would hit problems with fragmentation unless memory was deliberately
fragmented first. Furthermore, the phrasing implies that the minimum order
used by the page allocator is order 3 which is not what the patch appears
to do.

> Signed-off-by: Christopher Lameter <cl@linux.com>
> 
> Index: linux/include/linux/mmzone.h
> ===================================================================
> --- linux.orig/include/linux/mmzone.h
> +++ linux/include/linux/mmzone.h
> @@ -96,6 +96,11 @@ extern int page_group_by_mobility_disabl
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> +	/* We stop breaking up pages of this order if less than
> +	 * min are available. At that point the pages can only
> +	 * be used for allocations of that particular order.
> +	 */
> +	unsigned long		min;
>  };
>  
>  struct pglist_data;
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c
> +++ linux/mm/page_alloc.c
> @@ -1844,7 +1844,12 @@ struct page *__rmqueue_smallest(struct z
>  		area = &(zone->free_area[current_order]);
>  		page = list_first_entry_or_null(&area->free_list[migratetype],
>  							struct page, lru);
> -		if (!page)
> +		/*
> +		 * Continue if no page is found or if our freelist contains
> +		 * less than the minimum pages of that order. In that case
> +		 * we better look for a different order.
> +		 */
> +		if (!page || area->nr_free < area->min)
>  			continue;
>  		list_del(&page->lru);
>  		rmv_page_order(page);

This is surprising to say the least. Assuming reservations are at order-3,
this would refuse to split order-3 even if there was sufficient reserved
pages at higher orders for a reserve. This will cause splits of higher
orders unnecessarily which could cause other fragmentation-related issues
in the future.

This is similar to a memory pool except it's not. There is no concept of a
user of high-order reserves accounting for it. Hence, a user of high-order
pages could allocate the reserve multiple times for long-term purposes
while starving other allocation requests. This could easily happen for slub
with min_order set to the same order as the reserve causing potential OOM
issues. If a pool is to be created, it should be a real pool even if it's
transparently accessed through the page allocator. It should allocate the
requested number of pages and either decide to refill is possible or pass
requests through to the page allocator when the pool is depleted. Also,
as it stands, an OOM due to the reserve would be confusing as there is no
hint the failure may have been due to the reserve.

Access to the pool is unprotected so you might create a reserve for jumbo
frames only to have them consumed by something else entirely. It's not
clear if that is even fixable as GFP flags are too coarse.

It is not covered in the changelog why MIGRATE_HIGHATOMIC was not
sufficient for jumbo frames which are generally expected to be allocated
from atomic context. If there is a problem there then maybe
MIGRATE_HIGHATOMIC should be made more strict instead of a hack like
this. It'll be very difficult, if not impossible, for this to be tuned
properly.

Finally, while I accept that fragmentation over time is a problem for
unmovable allocations (fragmentation protection was originally designed
for THP/hugetlbfs), this is papering over the problem. If greater
protections are needed then the right approach is to be more strict about
fallbacks. Specifically, unmovable allocations should migrate all movable
pages out of migrate_unmovable pageblocks before falling back and that
can be controlled by policy due to the overhead of migration. For atomic
allocations, allow fallback but use kcompact or a workqueue to migrate
movable pages out of migrate_unmovable pageblocks to limit fallbacks in
the future.

I'm not a fan of this patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
