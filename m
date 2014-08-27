Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFDC6B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:05:18 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fa1so104151pad.12
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:05:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gl10si3032856pbd.139.2014.08.27.16.05.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:05:17 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:05:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
Message-Id: <20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
In-Reply-To: <20140827225927.602319674@asylum.americas.sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
	<20140827225927.602319674@asylum.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>

On Wed, 27 Aug 2014 17:59:28 -0500 Mike Travis <travis@sgi.com> wrote:

> Since the ioremap operation is verifying that the specified address range
> is NOT RAM, it will search the entire ioresource list if the condition
> is true.  To make matters worse, it does this one 4k page at a time.
> For a 128M BAR region this is 32 passes to determine the entire region
> does not contain any RAM addresses.
> 
> This patch provides another resource lookup function, region_is_ram,
> that searches for the entire region specified, verifying that it is
> completely contained within the resource region.  If it is found, then
> it is checked to be RAM or not, within a single pass.
> 
> The return result reflects if it was found or not (-1), and whether it is
> RAM (1) or not (0).  This allows the caller to fallback to the previous
> page by page search if it was not found.
> 
> ...
>
> --- linux.orig/kernel/resource.c
> +++ linux/kernel/resource.c
> @@ -494,6 +494,43 @@ int __weak page_is_ram(unsigned long pfn
>  }
>  EXPORT_SYMBOL_GPL(page_is_ram);
>  
> +/*
> + * Search for a resouce entry that fully contains the specified region.
> + * If found, return 1 if it is RAM, 0 if not.
> + * If not found, or region is not fully contained, return -1
> + *
> + * Used by the ioremap functions to insure user not remapping RAM and is as
> + * vast speed up over walking through the resource table page by page.
> + */
> +int __weak region_is_ram(resource_size_t start, unsigned long size)
> +{
> +	struct resource *p;
> +	resource_size_t end = start + size - 1;
> +	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	const char *name = "System RAM";
> +	int ret = -1;
> +
> +	read_lock(&resource_lock);
> +	for (p = iomem_resource.child; p ; p = p->sibling) {
> +		if (end < p->start)
> +			continue;
> +
> +		if (p->start <= start && end <= p->end) {
> +			/* resource fully contains region */
> +			if ((p->flags != flags) || strcmp(p->name, name))
> +				ret = 0;
> +			else
> +				ret = 1;
> +			break;
> +		}
> +		if (p->end < start)
> +			break;	/* not found */
> +	}
> +	read_unlock(&resource_lock);
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(region_is_ram);

Exporting a __weak symbol is strange.  I guess it works, but neither
the __weak nor the export are actually needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
