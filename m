Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE48C6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 17:37:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so19085241pfg.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 14:37:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e27si2392409plj.871.2017.07.24.14.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 14:37:28 -0700 (PDT)
Date: Mon, 24 Jul 2017 17:37:13 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 09/10] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170724213712.GE91613@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-10-dennisz@fb.com>
 <20170717232756.GC585283@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170717232756.GC585283@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 17, 2017 at 07:27:56PM -0400, Tejun Heo wrote:
> I think it'd be nice to have a similar table for allocation patterns
> which aren't ideal for the original allocator.  The biggest goal is
> avoiding cases where the allocator collapses and just glancing at the
> table doesn't seem very compelling.

I've added new data to the cover letter and in the commit log to
demonstrate poor allocation performance.

> >  /*
> > + * This determines the size of each metadata block.  There are several subtle
> > + * constraints around this variable.  The reserved_region and dynamic_region
>                               ^
> 			      constant
> 			      

Fixed.

> > + * of the first chunk must be multiples of PCPU_BITMAP_BLOCK_SIZE.  This is
> > + * not a problem if the BLOCK_SIZE encompasses a page, but if exploring blocks
> > + * that are backing multiple pages, this needs to be accounted for.
> > + */
> > +#define PCPU_BITMAP_BLOCK_SIZE		(PAGE_SIZE >> PCPU_MIN_ALLOC_SHIFT)
> 
> Given that percpu allocator can align only upto a page, the
> restriction makes sense to me.  I'm kinda curious whether PAGE_SIZE
> blocks is optimal tho.  Why did you pick PAGE_SIZE?
> 

I've refactored v2 to be able to handle block sizes with certain
constraints. The PAGE_SIZE blocks really just were a balance between
amount required to scan and the number of metadata blocks. I tested 2KB
blocks and they seemed to perform marginally worse.

> > +/*
>    ^^
>    /**
> 
> Ditto for other comments.
> 

Fixed.

> > + * pcpu_nr_pages_to_blocks - converts nr_pages to # of md_blocks
> > + * @chunk: chunk of interest
> > + *
> > + * This conversion is from the number of physical pages that the chunk
> > + * serves to the number of bitmap blocks required.  It converts to bytes
> > + * served to bits required and then blocks used.
> > + */
> > +static inline int pcpu_nr_pages_to_blocks(struct pcpu_chunk *chunk)
> 
> Maybe just pcpu_chunk_nr_blocks()?
> 

Renamed.

> > +{
> > +	return chunk->nr_pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE /
> > +	       PCPU_BITMAP_BLOCK_SIZE;
> > +}
> > +
> > +/*
> > + * pcpu_pages_to_bits - converts the pages to size of bitmap
> > + * @pages: number of physical pages
> > + *
> > + * This conversion is from physical pages to the number of bits
> > + * required in the bitmap.
> > + */
> > +static inline int pcpu_pages_to_bits(int pages)
> 
> pcpu_nr_pages_to_map_bits()?
> 

Renamed.

> > +{
> > +	return pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE;
> > +}
> > +
> > +/*
> > + * pcpu_nr_pages_to_bits - helper to convert nr_pages to size of bitmap
> > + * @chunk: chunk of interest
> > + *
> > + * This conversion is from the number of physical pages that the chunk
> > + * serves to the number of bits in the bitmap.
> > + */
> > +static inline int pcpu_nr_pages_to_bits(struct pcpu_chunk *chunk)
> 
> pcpu_chunk_map_bits()?
> 

Renamed.

> > @@ -86,10 +90,13 @@
> >  
> >  #include "percpu-internal.h"
> >  
> > -#define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
> > -#define PCPU_DFL_MAP_ALLOC		16	/* start a map with 16 ents */
> > -#define PCPU_ATOMIC_MAP_MARGIN_LOW	32
> > -#define PCPU_ATOMIC_MAP_MARGIN_HIGH	64
> > +/*
> > + * The metadata is managed in terms of bits with each bit mapping to
> > + * a fragment of size PCPU_MIN_ALLOC_SIZE.  Thus, the slots are calculated
> > + * with respect to the number of bits available.
> > + */
> > +#define PCPU_SLOT_BASE_SHIFT		3
> 
> Ah, so this is actually the same as before 3 + 2, order 5.  Can you
> please note the explicit number in the comment?
> 

With the refactor in v2, the slots are back to being managed in bytes.

> >  #define PCPU_EMPTY_POP_PAGES_LOW	2
> >  #define PCPU_EMPTY_POP_PAGES_HIGH	4
> 
> and these numbers too.  I can't tell how these numbers would map.
> Also, any chance we can have these numbers in a more intuitive unit?
> 

Those are from the original implementation to decide when to schedule
work to repopulate the empty free page pool.


> > @@ -212,25 +220,25 @@ static bool pcpu_addr_in_reserved_chunk(void *addr)
> >  	       pcpu_reserved_chunk->nr_pages * PAGE_SIZE;
> >  }
> >  
> > -static int __pcpu_size_to_slot(int size)
> > +static int __pcpu_size_to_slot(int bit_size)
> 
> Wouldn't sth like @map_bits more intuitive than @bit_size?  We can
> just use @bits too.
> 

Back to bytes.

> >  {
> > -	int highbit = fls(size);	/* size is in bytes */
> > +	int highbit = fls(bit_size);	/* size is in bits */
> >  	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
> >  }
> >  
> > -static int pcpu_size_to_slot(int size)
> > +static int pcpu_size_to_slot(int bit_size)
> 
> Ditto.
> 

Back to bytes.

> > +static void pcpu_chunk_update_hint(struct pcpu_chunk *chunk)
> 
> It's a span iteration problem.  When abstracted properly, it shouldn't
> be too difficult to follow.
> 

I agree, I've refactored to use an iterator.

> > +static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
 
> It's a lot simpler here but this too might look simpler with an
> appropriate interation abstraction.

Generalized the populated bitmap iterators so it can be used here.

> 
> Hmm... why do we need is_left/right_free?  Can't we reset them to zero
> at the top and update directly during the loop?
> 

Yes. Done.

> 
> @update_chunk seems unnecessary.
> 

I've moved the chunk refresh call to be here.

> 
> So, if you do the above with inclusive range, it becomes
> 
> 	s_index = pcpu_off_to_block_index(start_bit);
> 	e_index = pcpu_off_to_block_index(end_bit - 1);
> 	s_off = pcpu_off_to_block_off(start_bit);
> 	e_off = pcpu_off_to_block_off(end_bit - 1) + 1;
> 
> and you can just comment that you're using inclusive range so that the
> e_index always points to the last block in the range.  Wouldn't that
> be easier?  People do use inclusive ranges for these sorts of
> calculations.

Ah I see, thanks. Done.

> 
> How about something like the following?  It's kinda weird to have an
> extra loop var which isn't really used for anything.  The same goes
> for other places too.
> 
> 		for (block = chunk->md_blocks + s_index + 1;
> 		     block < chunk->md_blocks + e_index; block++)
> 

I've rewritten most for loops to do this.

> > +			block->first_free = 0;
 
> > +static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int bit_size,
> > +			       size_t align, bool pop_only)
> 
> Wouldn't this function be a lot simpler too if there were free span
> iterator?
> 

Yes added an iterator for this.

> > +
> > +	/* update alloc map */
> > +	bitmap_set(chunk->alloc_map, bit_off, bit_size);
> 
> blank line
> 

Added.

> 
> Do we ever not update chunk hint when block hint indicates that it's
> necessary?  If not, maybe just call it from the previous function?
> 

No. I've added the call to the previous function.

> > @@ -787,6 +1179,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
> >  
> >  	bitmap_set(chunk->populated, page_start, nr);
> >  	chunk->nr_populated += nr;
> > +	chunk->nr_empty_pop_pages += nr;
> >  	pcpu_nr_empty_pop_pages += nr;
> >  }
> >  
> > @@ -809,6 +1202,7 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
> >  
> >  	bitmap_clear(chunk->populated, page_start, nr);
> >  	chunk->nr_populated -= nr;
> > +	chunk->nr_empty_pop_pages -= nr;
> >  	pcpu_nr_empty_pop_pages -= nr;
> >  }
> 
> Didn't we add this field in an earlier patch?  Do the above changes
> belong in this patch?
> 

Yes, moved to previous patch.

> > +	size_t bit_size, bit_align;
> >  
> >  	/*
> > +	 * There is now a minimum allocation size of PCPU_MIN_ALLOC_SIZE.
> > +	 * Therefore alignment must be a minimum of that many bytes as well
> > +	 * as the allocation will have internal fragmentation from
> > +	 * rounding up by up to PCPU_MIN_ALLOC_SIZE - 1 bytes.
> >  	 */
> > +	if (unlikely(align < PCPU_MIN_ALLOC_SIZE))
> > +		align = PCPU_MIN_ALLOC_SIZE;
> > +	size = ALIGN(size, PCPU_MIN_ALLOC_SIZE);
> > +	bit_size = size >> PCPU_MIN_ALLOC_SHIFT;
> > +	bit_align = align >> PCPU_MIN_ALLOC_SHIFT;
> 
> Shouldn't the above have happened earlier when MIN_ALLOC_SIZE was
> introduced?
> 

Yes, moved to previous patch.

> > @@ -1363,15 +1710,15 @@ bool is_kernel_percpu_address(unsigned long addr)
> >   * address.  The caller is responsible for ensuring @addr stays valid
> >   * until this function finishes.
> >   *
> > - * percpu allocator has special setup for the first chunk, which currently
> > + * Percpu allocator has special setup for the first chunk, which currently
> >   * supports either embedding in linear address space or vmalloc mapping,
> >   * and, from the second one, the backing allocator (currently either vm or
> >   * km) provides translation.
> >   *
> >   * The addr can be translated simply without checking if it falls into the
> > - * first chunk. But the current code reflects better how percpu allocator
> > + * first chunk.  But the current code reflects better how percpu allocator
> >   * actually works, and the verification can discover both bugs in percpu
> > - * allocator itself and per_cpu_ptr_to_phys() callers. So we keep current
> > + * allocator itself and per_cpu_ptr_to_phys() callers.  So we keep current
> 
> Let's please move out what can be to other patches.  This patch is big
> enough as it is.
> 

Removed.

> > @@ -1417,9 +1764,10 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
> >  		else
> >  			return page_to_phys(vmalloc_to_page(addr)) +
> >  			       offset_in_page(addr);
> > -	} else
> > +	} else {
> >  		return page_to_phys(pcpu_addr_to_page(addr)) +
> >  		       offset_in_page(addr);
> > +	}
> 
> Ditto.
> 

Removed.

> > @@ -1555,10 +1903,12 @@ static void pcpu_dump_alloc_info(const char *lvl,
> >   * static areas on architectures where the addressing model has
> >   * limited offset range for symbol relocations to guarantee module
> >   * percpu symbols fall inside the relocatable range.
> > + * @ai->static_size + @ai->reserved_size is expected to be page aligned.
> >   *
> >   * @ai->dyn_size determines the number of bytes available for dynamic
> > - * allocation in the first chunk.  The area between @ai->static_size +
> > - * @ai->reserved_size + @ai->dyn_size and @ai->unit_size is unused.
> > + * allocation in the first chunk. Both the start and the end are expected
> > + * to be page aligned. The area between @ai->static_size + @ai->reserved_size
> > + * + @ai->dyn_size and @ai->unit_size is unused.
>      ^^^
>      contam
> 

This is for the math continuing from the previous line.

> >   *
> >   * @ai->unit_size specifies unit size and must be aligned to PAGE_SIZE
> >   * and equal to or larger than @ai->static_size + @ai->reserved_size +
> > @@ -1581,11 +1931,11 @@ static void pcpu_dump_alloc_info(const char *lvl,
> >   * copied static data to each unit.
> >   *
> >   * If the first chunk ends up with both reserved and dynamic areas, it
> > - * is served by two chunks - one to serve the core static and reserved
> > - * areas and the other for the dynamic area.  They share the same vm
> > - * and page map but uses different area allocation map to stay away
> > - * from each other.  The latter chunk is circulated in the chunk slots
> > - * and available for dynamic allocation like any other chunks.
> > + * is served by two chunks - one to serve the reserved area and the other
> > + * for the dynamic area.  They share the same vm and page map but use
> > + * different area allocation map to stay away from each other.  The latter
> > + * chunk is circulated in the chunk slots and available for dynamic allocation
> > + * like any other chunks.
> 
> ditto
> 

Split into another patch.

> > @@ -1703,7 +2051,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> >  	 * Allocate chunk slots.  The additional last slot is for
> >  	 * empty chunks.
> >  	 */
> > -	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
> > +	pcpu_nr_slots = __pcpu_size_to_slot(
> > +				pcpu_pages_to_bits(pcpu_unit_pages)) + 2;
> 
> I get that we wanna be using bits inside the area allocator proper but
> can we keep things outside in bytes?  These things don't really have
> anything to do with what granularity the area allocator is operating
> at.
> 

The refactor keeps this in bytes.


> > @@ -1727,69 +2076,50 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
> >  	tmp_addr = (unsigned long)base_addr + ai->static_size;
> >  	aligned_addr = tmp_addr & PAGE_MASK;
> >  	pcpu_reserved_offset = tmp_addr - aligned_addr;
> > +	begin_fill_bits = pcpu_reserved_offset / PCPU_MIN_ALLOC_SIZE;
> >  
> >  	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
> >  			 pcpu_reserved_offset;
> > +
> >  	chunk_pages = map_size_bytes >> PAGE_SHIFT;
> >  
> >  	/* chunk adjacent to static region allocation */
> > +	chunk = pcpu_alloc_first_chunk(chunk_pages);
> >  	chunk->base_addr = (void *)aligned_addr;
> >  	chunk->immutable = true;
> >  
> > +	/* set metadata */
> > +	chunk->contig_hint = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
> > +	chunk->free_bits = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
> >  
> > +	/*
> > +	 * If the beginning of the reserved region overlaps the end of the
> > +	 * static region, hide that portion in the metadata.
> > +	 */
> > +	if (begin_fill_bits) {
> >  		chunk->has_reserved = true;
> > +		bitmap_fill(chunk->alloc_map, begin_fill_bits);
> > +		set_bit(0, chunk->bound_map);
> > +		set_bit(begin_fill_bits, chunk->bound_map);
> > +
> > +		if (pcpu_block_update_hint_alloc(chunk, 0, begin_fill_bits))
> > +			pcpu_chunk_update_hint(chunk);
> >  	}
> >  
> > +	/* init dynamic chunk if necessary */
> > +	if (ai->reserved_size) {
> > +		pcpu_reserved_chunk = chunk;
> > +
> >  		chunk_pages = dyn_size >> PAGE_SHIFT;
> >  
> >  		/* chunk allocation */
> > +		chunk = pcpu_alloc_first_chunk(chunk_pages);
> >  		chunk->base_addr = base_addr + ai->static_size +
> >  				    ai->reserved_size;
> > +
> > +		/* set metadata */
> > +		chunk->contig_hint = pcpu_nr_pages_to_bits(chunk);
> > +		chunk->free_bits = pcpu_nr_pages_to_bits(chunk);
> >  	}
> >  
> >  	/* link the first chunk in */
> 
> I *think* that quite a bit of the above can be moved into a separate
> patch.
> 

The last one was quite a bit of work. It is the first handful of
patches in v2. The first chunk creation logic has been consolidated and
the reserved region is no longer expanded. The reserved region needs to
be a multiple of PCPU_MIN_ALLOC_SIZE and the static region is aligned up
while the dynamic region is shrunk by the aligned up amount. This is fine
as the dynamic region is expanded to be page aligned. If there was a
need to align up the static region, that means the dynamic region
initially expanded to use that space.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
