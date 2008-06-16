Date: Mon, 16 Jun 2008 11:26:16 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [Patch 002/005](memory hotplug) align memmap to page size
Message-ID: <20080616102616.GE17016@shadowen.org>
References: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com> <20080407214514.8872.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080407214514.8872.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 07, 2008 at 09:46:19PM +0900, Yasunori Goto wrote:
> To free memmap easier, this patch aligns it to page size.
> Bootmem allocater may mix some objects in one pages.
> It's not good for freeing memmap of memory hot-remove.
> 
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
>  mm/sparse.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2008-04-07 19:18:50.000000000 +0900
> +++ current/mm/sparse.c	2008-04-07 20:08:13.000000000 +0900
> @@ -265,8 +265,8 @@
>  	if (map)
>  		return map;
>  
> -	map = alloc_bootmem_node(NODE_DATA(nid),
> -			sizeof(struct page) * PAGES_PER_SECTION);
> +	map = alloc_bootmem_pages_node(NODE_DATA(nid),
> +		       PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION));
>  	return map;
>  }
>  #endif /* !CONFIG_SPARSEMEM_VMEMMAP */

Ahh ok, we do makes sure the mmap uses up the rest of the space.  That
though is a shame as we cannot slip the usemap in the end of the space
any more (assuming we could).

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
