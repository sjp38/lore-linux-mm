Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABD346B0273
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 00:50:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so3175777plq.8
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 21:50:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h3-v6si9664230plt.258.2018.06.15.21.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Jun 2018 21:50:12 -0700 (PDT)
Date: Fri, 15 Jun 2018 21:50:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v33 1/4] mm: add a function to get free page blocks
Message-ID: <20180616045005.GA14936@bombadil.infradead.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Fri, Jun 15, 2018 at 12:43:10PM +0800, Wei Wang wrote:
> +/**
> + * get_from_free_page_list - get free page blocks from a free page list
> + * @order: the order of the free page list to check
> + * @buf: the array to store the physical addresses of the free page blocks
> + * @size: the array size
> + *
> + * This function offers hints about free pages. There is no guarantee that
> + * the obtained free pages are still on the free page list after the function
> + * returns. pfn_to_page on the obtained free pages is strongly discouraged
> + * and if there is an absolute need for that, make sure to contact MM people
> + * to discuss potential problems.
> + *
> + * The addresses are currently stored to the array in little endian. This
> + * avoids the overhead of converting endianness by the caller who needs data
> + * in the little endian format. Big endian support can be added on demand in
> + * the future.
> + *
> + * Return the number of free page blocks obtained from the free page list.
> + * The maximum number of free page blocks that can be obtained is limited to
> + * the caller's array size.
> + */

Please use:

 * Return: The number of free page blocks obtained from the free page list.

Also, please include a

 * Context: Any context.

or

 * Context: Process context.

or whatever other conetext this function can be called from.  Since you're
taking the lock irqsafe, I assume this can be called from any context, but
I wonder if it makes sense to have this function callable from interrupt
context.  Maybe this should be callable from process context only.

> +uint32_t get_from_free_page_list(int order, __le64 buf[], uint32_t size)
> +{
> +	struct zone *zone;
> +	enum migratetype mt;
> +	struct page *page;
> +	struct list_head *list;
> +	unsigned long addr, flags;
> +	uint32_t index = 0;
> +
> +	for_each_populated_zone(zone) {
> +		spin_lock_irqsave(&zone->lock, flags);
> +		for (mt = 0; mt < MIGRATE_TYPES; mt++) {
> +			list = &zone->free_area[order].free_list[mt];
> +			list_for_each_entry(page, list, lru) {
> +				addr = page_to_pfn(page) << PAGE_SHIFT;
> +				if (likely(index < size)) {
> +					buf[index++] = cpu_to_le64(addr);
> +				} else {
> +					spin_unlock_irqrestore(&zone->lock,
> +							       flags);
> +					return index;
> +				}
> +			}
> +		}
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +	}
> +
> +	return index;
> +}

I wonder if (to address Michael's concern), you shouldn't instead use
the first free chunk of pages to return the addresses of all the pages.
ie something like this:

	__le64 *ret = NULL;
	unsigned int max = (PAGE_SIZE << order) / sizeof(__le64);

	for_each_populated_zone(zone) {
		spin_lock_irq(&zone->lock);
		for (mt = 0; mt < MIGRATE_TYPES; mt++) {
			list = &zone->free_area[order].free_list[mt];
			list_for_each_entry_safe(page, list, lru, ...) {
				if (index == size)
					break;
				addr = page_to_pfn(page) << PAGE_SHIFT;
				if (!ret) {
					list_del(...);
					ret = addr;
				}
				ret[index++] = cpu_to_le64(addr);
			}
		}
		spin_unlock_irq(&zone->lock);
	}

	return ret;
}

You'll need to return the page to the freelist afterwards, but free_pages()
should take care of that.
