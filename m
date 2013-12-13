Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4266B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:37:39 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i7so1978627yha.39
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:37:39 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id l26si3246455yhg.287.2013.12.13.13.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 13:37:38 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so2000729yha.12
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:37:38 -0800 (PST)
Date: Fri, 13 Dec 2013 16:37:35 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131213213735.GM27070@htj.dyndns.org>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
 <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Mon, Dec 09, 2013 at 04:50:41PM -0500, Santosh Shilimkar wrote:
> Introduce memblock memory allocation APIs which allow to support
> PAE or LPAE extension on 32 bits archs where the physical memory
> start address can be beyond 4GB. In such cases, existing bootmem
> APIs which operate on 32 bit addresses won't work and needs
> memblock layer which operates on 64 bit addresses.

The overall API looks good to me.  Thanks for doing this!

> +static void * __init memblock_virt_alloc_internal(
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t min_addr, phys_addr_t max_addr,
> +				int nid)
> +{
> +	phys_addr_t alloc;
> +	void *ptr;
> +
> +	if (nid == MAX_NUMNODES)
> +		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
> +			__func__);

Why not use WARN_ONCE()?  Also, shouldn't nid be set to NUMA_NO_NODE
here?

...
> +	if (nid != NUMA_NO_NODE) {

Otherwise, the above test is broken.

> +		alloc = memblock_find_in_range_node(size, align, min_addr,
> +						    max_addr,  NUMA_NO_NODE);
> +		if (alloc)
> +			goto done;
> +	}

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
