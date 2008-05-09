Date: Fri, 9 May 2008 11:31:46 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] sparsemem vmemmap: initialize memmap.
Message-ID: <20080509103132.GB10210@shadowen.org>
References: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 08:38:56AM +0200, Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Trying to online a new memory section that was added via memory hotplug
> results in lots of messages of pages in bad page state.
> Reason is that the alloacted virtual memmap isn't initialized.
> This is only an issue for memory sections that get added after boot
> time since for all other memmaps the bootmem allocator was used which
> returns only initialized memory.
> 
> I noticed this on s390 which has its private vmemmap_populate function
> without using callbacks to the common code. But as far as I can see the
> generic code has the same bug, so fix it just once.
> 
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  mm/sparse-vmemmap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/sparse-vmemmap.c
> ===================================================================
> --- linux-2.6.orig/mm/sparse-vmemmap.c
> +++ linux-2.6/mm/sparse-vmemmap.c
> @@ -154,6 +154,6 @@ struct page * __meminit sparse_mem_map_p
>  	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
>  	if (error)
>  		return NULL;
> -
> +	memset(map, 0, PAGES_PER_SECTION * sizeof(struct page));
>  	return map;
>  }

The normal expectation is that all allocations are made using
vmemmap_alloc_block() which allocates from the appropriate place.  Once
the buddy is up and available it uses:

	struct page *page = alloc_pages_node(node,
			GFP_KERNEL | __GFP_ZERO, get_order(size));

to get the memory so it should all be zero'd.  So I would expect all
existing users to be covered by that?  Can you not simply use __GFP_ZERO
for your allocations or use vmemmap_alloc_block() ?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
