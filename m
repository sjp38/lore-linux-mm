Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24AA26B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 12:40:59 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so1986403pac.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:40:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xq3si7081788pac.194.2016.07.27.09.40.56
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 09:40:58 -0700 (PDT)
Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5798E418.7080608@intel.com>
Date: Wed, 27 Jul 2016 09:40:56 -0700
MIME-Version: 1.0
In-Reply-To: <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 07/26/2016 06:23 PM, Liang Li wrote:
> +	for_each_migratetype_order(order, t) {
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

Nit:  The 'page_num' nomenclature really confused me here.  It is the
number of bits being set in the bitmap.  Seems like calling it nr_pages
or num_pages would be more appropriate.

Isn't this bitmap out of date by the time it's send up to the
hypervisor?  Is there something that makes the inaccuracy OK here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
