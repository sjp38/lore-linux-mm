Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0366B0260
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:13:33 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i199so21109919ioi.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 15:13:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 187si9185326iov.29.2016.07.27.15.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 15:13:32 -0700 (PDT)
Date: Thu, 28 Jul 2016 01:13:26 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
Message-ID: <20160728010921-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Wed, Jul 27, 2016 at 09:23:35AM +0800, Liang Li wrote:
> Save the free page info into a page bitmap, will be used in virtio
> balloon device driver.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> ---
>  mm/page_alloc.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 46 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7da61ad..3ad8b10 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4523,6 +4523,52 @@ unsigned long get_max_pfn(void)
>  }
>  EXPORT_SYMBOL(get_max_pfn);
>  
> +static void mark_free_pages_bitmap(struct zone *zone, unsigned long start_pfn,
> +	unsigned long end_pfn, unsigned long *bitmap, unsigned long len)
> +{
> +	unsigned long pfn, flags, page_num;
> +	unsigned int order, t;
> +	struct list_head *curr;
> +
> +	if (zone_is_empty(zone))
> +		return;
> +	end_pfn = min(start_pfn + len, end_pfn);
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	for_each_migratetype_order(order, t) {

Why not do each order separately? This way you can
use a single bit to pass a huge page to host.

Not a requirement but hey.

Alternatively (and maybe that is a better idea0
if you wanted to, you could just skip lone 4K pages.
It's not clear that they are worth bothering with.
Add a flag to start with some reasonably large order and go from there.


> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> +			if (pfn >= start_pfn && pfn <= end_pfn) {
> +				page_num = 1UL << order;
> +				if (pfn + page_num > end_pfn)
> +					page_num = end_pfn - pfn;
> +				bitmap_set(bitmap, pfn - start_pfn, page_num);
> +			}
> +		}
> +	}
> +
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
> +int get_free_pages(unsigned long start_pfn, unsigned long end_pfn,
> +		unsigned long *bitmap, unsigned long len)
> +{
> +	struct zone *zone;
> +	int ret = 0;
> +
> +	if (bitmap == NULL || start_pfn > end_pfn || start_pfn >= max_pfn)
> +		return 0;
> +	if (end_pfn < max_pfn)
> +		ret = 1;
> +	if (end_pfn >= max_pfn)
> +		ret = 0;
> +
> +	for_each_populated_zone(zone)
> +		mark_free_pages_bitmap(zone, start_pfn, end_pfn, bitmap, len);
> +	return ret;
> +}
> +EXPORT_SYMBOL(get_free_pages);
> +
>  static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
>  {
>  	zoneref->zone = zone;
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
