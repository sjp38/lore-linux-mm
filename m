Date: Mon, 2 May 2005 23:43:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: swap space address layout improvements in -mm
Message-Id: <20050502234356.0ad52176.akpm@osdl.org>
In-Reply-To: <20050420172310.GA8871@logos.cnet>
References: <20050420172310.GA8871@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> Hi Andrew,
> 
> I have spent some time reading your swap space allocation patch.
> 
> + * We divide the swapdev into 1024 kilobyte chunks.  We use the cookie and the
> + * upper bits of the index to select a chunk and the rest of the index as the
> + * offset into the selected chunk.
> + */
> +#define CHUNK_SHIFT    (20 - PAGE_SHIFT)
> +#define CHUNK_MASK     (-1UL << CHUNK_SHIFT)
> +
> +static int
> +scan_swap_map(struct swap_info_struct *si, void *cookie, pgoff_t index)
> +{
> +       unsigned long chunk;
> +       unsigned long nchunks;
> +       unsigned long block;
> +       unsigned long scan;
> +
> +       nchunks = si->max >> CHUNK_SHIFT;
> +       chunk = 0;
> +       if (nchunks)
> +               chunk = hash_long((unsigned long)cookie + (index & CHUNK_MASK),
> +                                       BITS_PER_LONG) % nchunks;
> +
> +       block = (chunk << CHUNK_SHIFT) + (index & ~CHUNK_MASK);
> 
> >From what I can understand you're aiming at having virtually contiguous pages sequentially 
> allocated on disk.  

Yeah.

+ * We attempt to lay pages out on swap to that virtually-contiguous pages are
+ * contiguous on-disk.  To do this we utilise page->index (offset into vma) and
+ * page->mapping (the anon_vma's address).

The idea is that swapspace is chunked up into I think 1MB chunks.  And for
every 1MB chunk of the user's virtual address space we'll choose a random
1MB chunk of swap in which to place that 1MB of user address space.

> I just dont understand how you want that to be achieved using the hash function, which is 
> quite randomic... In practice, the calculated hash values have most of its MostSignificantBit's 
> changed at each increment of 255, resulting in non sequential block values at such 
> index increments. 

The hash function is supposed to randomly choose one of the swap device's
1MB chunks.

> The first and subsequent block allocations are simply randomic, instead of being sequential.
> Hit me with your cluebat.

`index' is supposed to be "the offset of this page into the anon vma".  So
once we've randomly chosen our 1MB chunk of swap, an entire 1MB of user
anon address space will be mapped to that 1MB chunk of swapspace in a
linear-by-virtual-address fashion.

I hope ;)

> >From what I know, it is interesting to allocate from (0 in direction to -> end block) 
> (roughly what sct allocation scheme does).
> 
> I suspect a more advanced fs-like swap allocation scheme is wanted. 

That's what it's trying to do.  I did have lots of printks and things in
there and did confirm that it was doing what I intended it to do.  But it
was a long time ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
