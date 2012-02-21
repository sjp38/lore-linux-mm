Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6AEFD6B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 16:30:13 -0500 (EST)
Date: Tue, 21 Feb 2012 21:30:07 +0000 (UTC)
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCHv22 13/16] drivers: add Contiguous Memory Allocator
In-Reply-To: <1329507036-24362-14-git-send-email-m.szyprowski@samsung.com>
Message-ID: <alpine.DEB.2.00.1202212121560.962@localhost>
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com> <1329507036-24362-14-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

Hi,

On Fri, 17 Feb 2012, Marek Szyprowski wrote:
> +/**
> + * dma_release_from_contiguous() - release allocated pages
> + * @dev:   Pointer to device for which the pages were allocated.
> + * @pages: Allocated pages.
> + * @count: Number of allocated pages.
> + *
> + * This function releases memory allocated by dma_alloc_from_contiguous().
> + * It returns false when provided pages do not belong to contiguous area and
> + * true otherwise.
> + */
> +bool dma_release_from_contiguous(struct device *dev, struct page *pages,
> +				 int count)
> +{
> +	struct cma *cma = dev_get_cma_area(dev);
> +	unsigned long pfn;
> +
> +	if (!cma || !pages)
> +		return false;
> +
> +	pr_debug("%s(page %p)\n", __func__, (void *)pages);
> +
> +	pfn = page_to_pfn(pages);
> +
> +	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
> +		return false;
> +
> +	VM_BUG_ON(pfn + count > cma->base_pfn);

Are you sure the VM_BUG_ON() condition is correct here?

> +	mutex_lock(&cma_mutex);
> +	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
> +	free_contig_range(pfn, count);
> +	mutex_unlock(&cma_mutex);
> +
> +	return true;
> +}

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
