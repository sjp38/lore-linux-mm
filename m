Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18C4C6B0397
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 16:02:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u195so38742724pgb.1
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 13:02:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s128si24675096pgc.85.2017.04.13.13.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 13:02:20 -0700 (PDT)
Date: Thu, 13 Apr 2017 13:02:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 3/5] mm: function to offer a page block on the free
 list
Message-Id: <20170413130217.2316b0394192d8677f5ddbdf@linux-foundation.org>
In-Reply-To: <1492076108-117229-4-git-send-email-wei.w.wang@intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
	<1492076108-117229-4-git-send-email-wei.w.wang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, 13 Apr 2017 17:35:06 +0800 Wei Wang <wei.w.wang@intel.com> wrote:

> Add a function to find a page block on the free list specified by the
> caller. Pages from the page block may be used immediately after the
> function returns. The caller is responsible for detecting or preventing
> the use of such pages.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4498,6 +4498,93 @@ void show_free_areas(unsigned int filter)
>  	show_swap_cache_info();
>  }
>  
> +/**
> + * Heuristically get a page block in the system that is unused.
> + * It is possible that pages from the page block are used immediately after
> + * inquire_unused_page_block() returns. It is the caller's responsibility
> + * to either detect or prevent the use of such pages.
> + *
> + * The free list to check: zone->free_area[order].free_list[migratetype].
> + *
> + * If the caller supplied page block (i.e. **page) is on the free list, offer
> + * the next page block on the list to the caller. Otherwise, offer the first
> + * page block on the list.
> + *
> + * Return 0 when a page block is found on the caller specified free list.
> + */
> +int inquire_unused_page_block(struct zone *zone, unsigned int order,
> +			      unsigned int migratetype, struct page **page)
> +{

Perhaps we can wrap this in the appropriate ifdef so the kernels which
won't be using virtio-balloon don't carry the added overhead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
