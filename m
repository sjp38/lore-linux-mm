Date: Sat, 28 Jun 2003 17:08:37 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.5.73-mm2
Message-ID: <20030628170837.A10514@infradead.org>
References: <20030627202130.066c183b.akpm@digeo.com> <20030628155436.GY20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030628155436.GY20413@holomorphy.com>; from wli@holomorphy.com on Sat, Jun 28, 2003 at 08:54:36AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 28, 2003 at 08:54:36AM -0700, William Lee Irwin III wrote:
> +config HIGHPMD
> +	bool "Allocate 2nd-level pagetables from highmem"
> +	depends on HIGHMEM64G
> +	help
> +	  The VM uses one pmd entry for each pagetable page of physical
> +	  memory allocated. For systems with extreme amounts of highmem,
> +	  this cannot be tolerated. Setting this option will put
> +	  userspace 2nd-level pagetables in highmem.

Does this make sense for !HIGHPTE?  In fact does it make sense to
carry along HIGHPTE as an option still? ..

> +#ifndef CONFIG_HIGHPMD /* Oh boy. Error reporting is going to blow major goats. */

Any chance you can rearragne the code to avoid the ifndef in favour
of an ifdef?

>  		set_pte(dst_pte, entry);
> +		pmd_unmap(dst_pte);
> +		pmd_unmap_nested(src_pte);

<Lots more pmd_unmap* calls snipped>

Looks like you changed some API so that pmds are now returned mapped?
It might make sense to change their names into foo_map then so the
breakage is at the API level if someone misses updates for the changes.

> +#ifdef CONFIG_HIGHPMD
> +#define	GFP_PMD		(__GFP_REPEAT|__GFP_HIGHMEM|GFP_KERNEL)
> +#else
> +#define GFP_PMD		(__GFP_REPEAT|GFP_KERNEL)
> +#endif

So what?  Do you want to use a space or tab after the #define? :)

Also Given that GFP_PMD is used just once it's argueable whether it makes
sense to get rid of the defintion and use the expanded values directly.


Otherwise the patch looks fine to me and should allow to get some more
free lowmem on those insanely big 32bit machines.. :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
