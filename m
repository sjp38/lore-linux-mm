Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 02EA48D0039
	for <linux-mm@kvack.org>; Wed,  2 Feb 2011 07:43:53 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p12ChhvC003527
	for <linux-mm@kvack.org>; Wed, 2 Feb 2011 23:43:43 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p12ChdRU1830974
	for <linux-mm@kvack.org>; Wed, 2 Feb 2011 23:43:43 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12ChcCN025845
	for <linux-mm@kvack.org>; Wed, 2 Feb 2011 23:43:39 +1100
Date: Wed, 2 Feb 2011 18:13:33 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCHv8 07/12] mm: cma: Contiguous Memory Allocator added
Message-ID: <20110202124333.GB26396@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <eb8f43235c8ff2816ada7b56ffe371ea6140cae8.1292443200.git.m.nazarewicz@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb8f43235c8ff2816ada7b56ffe371ea6140cae8.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

On Wed, Dec 15, 2010 at 09:34:27PM +0100, Michal Nazarewicz wrote:
> The Contiguous Memory Allocator is a set of functions that lets
> one initialise a region of memory which then can be used to perform
> allocations of contiguous memory chunks from.
> 
> CMA allows for creation of private and non-private contexts.
> The former is reserved for CMA and no other kernel subsystem can
> use it.  The latter allows for movable pages to be allocated within
> CMA's managed memory so that it can be used for page cache when
> CMA devices do not use it.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
> 

<snip>

> +/************************* Initialise CMA *************************/
> +
> +unsigned long cma_reserve(unsigned long start, unsigned long size,
> +			  unsigned long alignment)
> +{
> +	pr_debug("%s(%p+%p/%p)\n", __func__, (void *)start, (void *)size,
> +		 (void *)alignment);
> +
> +	/* Sanity checks */
> +	if (!size || (alignment & (alignment - 1)))
> +		return (unsigned long)-EINVAL;
> +
> +	/* Sanitise input arguments */
> +	start = PAGE_ALIGN(start);
> +	size  = PAGE_ALIGN(size);
> +	if (alignment < PAGE_SIZE)
> +		alignment = PAGE_SIZE;
> +
> +	/* Reserve memory */
> +	if (start) {
> +		if (memblock_is_region_reserved(start, size) ||
> +		    memblock_reserve(start, size) < 0)
> +			return (unsigned long)-EBUSY;
> +	} else {
> +		/*
> +		 * Use __memblock_alloc_base() since
> +		 * memblock_alloc_base() panic()s.
> +		 */
> +		u64 addr = __memblock_alloc_base(size, alignment, 0);
> +		if (!addr) {
> +			return (unsigned long)-ENOMEM;
> +		} else if (addr + size > ~(unsigned long)0) {
> +			memblock_free(addr, size);
> +			return (unsigned long)-EOVERFLOW;
> +		} else {
> +			start = addr;
> +		}
> +	}
> +

Reserving the areas of memory belonging to CMA using memblock_reserve,
would preclude that range from the zones, due to which it would not be
available for buddy allocations right ?

> +	return start;
> +}
> +
> +

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
