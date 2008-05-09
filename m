Date: Fri, 9 May 2008 09:25:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] sparsemem vmemmap: initialize memmap.
In-Reply-To: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.64.0805090923550.18195@schroedinger.engr.sgi.com>
References: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nack. vmemmap_alloc_block does 

void * __meminit vmemmap_alloc_block(unsigned long size, int node)
{
        /* If the main allocator is up use that, fallback to bootmem. */
        if (slab_is_available()) {
                struct page *page = alloc_pages_node(node,
                                GFP_KERNEL | __GFP_ZERO, get_order(size));
                if (page)
                        return page_address(page);
                return NULL;
        } else
                return __earlyonly_bootmem_alloc(node, size, size,
                                __pa(MAX_DMA_ADDRESS));
}

memory is always zeroed. Maybe you use an alternate implementation that is 
broken?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
