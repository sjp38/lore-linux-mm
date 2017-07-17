Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0BDF6B02F4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 19:28:03 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a66so1704030qkb.13
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 16:28:03 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id r49si470662qte.305.2017.07.17.16.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 16:28:01 -0700 (PDT)
Received: by mail-qk0-x22d.google.com with SMTP id p73so3709271qka.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 16:28:01 -0700 (PDT)
Date: Mon, 17 Jul 2017 19:27:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/10] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170717232756.GC585283@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-10-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-10-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:14PM -0400, Dennis Zhou wrote:
...
> While it does add to the allocation latency, the allocation scenario
> here is optimal for the area map allocator. The second problem of
> additional scanning can result in the area map allocator completing in
> 52 minutes. The same workload takes only 14 seconds to complete for the
> bitmap allocator. This was produced under a more contrived scenario of
> allocating 1 milion 4-byte objects with 8-byte alignment.

I think it'd be nice to have a similar table for allocation patterns
which aren't ideal for the original allocator.  The biggest goal is
avoiding cases where the allocator collapses and just glancing at the
table doesn't seem very compelling.

>  /*
> + * This determines the size of each metadata block.  There are several subtle
> + * constraints around this variable.  The reserved_region and dynamic_region
                              ^
			      constant
			      
> + * of the first chunk must be multiples of PCPU_BITMAP_BLOCK_SIZE.  This is
> + * not a problem if the BLOCK_SIZE encompasses a page, but if exploring blocks
> + * that are backing multiple pages, this needs to be accounted for.
> + */
> +#define PCPU_BITMAP_BLOCK_SIZE		(PAGE_SIZE >> PCPU_MIN_ALLOC_SHIFT)

Given that percpu allocator can align only upto a page, the
restriction makes sense to me.  I'm kinda curious whether PAGE_SIZE
blocks is optimal tho.  Why did you pick PAGE_SIZE?

> @@ -44,6 +62,44 @@ extern struct pcpu_chunk *pcpu_first_chunk;
>  extern struct pcpu_chunk *pcpu_reserved_chunk;
>  extern unsigned long pcpu_reserved_offset;
>  
> +/*
   ^^
   /**

Ditto for other comments.

> + * pcpu_nr_pages_to_blocks - converts nr_pages to # of md_blocks
> + * @chunk: chunk of interest
> + *
> + * This conversion is from the number of physical pages that the chunk
> + * serves to the number of bitmap blocks required.  It converts to bytes
> + * served to bits required and then blocks used.
> + */
> +static inline int pcpu_nr_pages_to_blocks(struct pcpu_chunk *chunk)

Maybe just pcpu_chunk_nr_blocks()?

> +{
> +	return chunk->nr_pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE /
> +	       PCPU_BITMAP_BLOCK_SIZE;
> +}
> +
> +/*
> + * pcpu_pages_to_bits - converts the pages to size of bitmap
> + * @pages: number of physical pages
> + *
> + * This conversion is from physical pages to the number of bits
> + * required in the bitmap.
> + */
> +static inline int pcpu_pages_to_bits(int pages)

pcpu_nr_pages_to_map_bits()?

> +{
> +	return pages * PAGE_SIZE / PCPU_MIN_ALLOC_SIZE;
> +}
> +
> +/*
> + * pcpu_nr_pages_to_bits - helper to convert nr_pages to size of bitmap
> + * @chunk: chunk of interest
> + *
> + * This conversion is from the number of physical pages that the chunk
> + * serves to the number of bits in the bitmap.
> + */
> +static inline int pcpu_nr_pages_to_bits(struct pcpu_chunk *chunk)

pcpu_chunk_map_bits()?

> @@ -86,10 +90,13 @@
>  
>  #include "percpu-internal.h"
>  
> -#define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
> -#define PCPU_DFL_MAP_ALLOC		16	/* start a map with 16 ents */
> -#define PCPU_ATOMIC_MAP_MARGIN_LOW	32
> -#define PCPU_ATOMIC_MAP_MARGIN_HIGH	64
> +/*
> + * The metadata is managed in terms of bits with each bit mapping to
> + * a fragment of size PCPU_MIN_ALLOC_SIZE.  Thus, the slots are calculated
> + * with respect to the number of bits available.
> + */
> +#define PCPU_SLOT_BASE_SHIFT		3

Ah, so this is actually the same as before 3 + 2, order 5.  Can you
please note the explicit number in the comment?

>  #define PCPU_EMPTY_POP_PAGES_LOW	2
>  #define PCPU_EMPTY_POP_PAGES_HIGH	4

and these numbers too.  I can't tell how these numbers would map.
Also, any chance we can have these numbers in a more intuitive unit?

> @@ -212,25 +220,25 @@ static bool pcpu_addr_in_reserved_chunk(void *addr)
>  	       pcpu_reserved_chunk->nr_pages * PAGE_SIZE;
>  }
>  
> -static int __pcpu_size_to_slot(int size)
> +static int __pcpu_size_to_slot(int bit_size)

Wouldn't sth like @map_bits more intuitive than @bit_size?  We can
just use @bits too.

>  {
> -	int highbit = fls(size);	/* size is in bytes */
> +	int highbit = fls(bit_size);	/* size is in bits */
>  	return max(highbit - PCPU_SLOT_BASE_SHIFT + 2, 1);
>  }
>  
> -static int pcpu_size_to_slot(int size)
> +static int pcpu_size_to_slot(int bit_size)

Ditto.

> +static void pcpu_chunk_update_hint(struct pcpu_chunk *chunk)
> +{
> +	bool is_page_empty = true;
> +	int i, off, cur_contig, nr_empty_pop_pages, l_pop_off;
> +	struct pcpu_bitmap_md *block;
> +
> +	chunk->contig_hint = cur_contig = 0;
> +	off = nr_empty_pop_pages = 0;
> +	l_pop_off = pcpu_block_get_first_page(chunk->first_free_block);
> +
> +	for (i = chunk->first_free_block, block = chunk->md_blocks + i;
> +	     i < pcpu_nr_pages_to_blocks(chunk); i++, block++) {
> +		/* Manage nr_empty_pop_pages.

		The first line of a winged comment should be blank, so...

		/*
		 * Manage nr_empty_pop_pages.

> +		 *
> +		 * This is tricky.  So the the background work function is
                                       ^^^^^^^

> +		 * triggered when there are not enough free populated pages.
> +		 * This is necessary to make sure atomic allocations can
> +		 * succeed.
> +		 *
> +		 * The first page of each block is kept track of here allowing
> +		 * this to scale in both situations where there are > 1 page
> +		 * per block and where a block may be a portion of a page.
> +		 */
> +		int pop_off = pcpu_block_get_first_page(i);
> +
> +		if (pop_off > l_pop_off) {
> +			if (is_page_empty)
> +				nr_empty_pop_pages +=
> +					pcpu_cnt_pop_pages(chunk, l_pop_off,
> +							   pop_off);

IIUC, this is trying to handle multi-page block size, right?

> +			l_pop_off = pop_off;
> +			is_page_empty = true;
> +		}
> +		if (block->contig_hint != PCPU_BITMAP_BLOCK_SIZE)

But isn't this assuming that each block is page sized?

> +			is_page_empty = false;
>  
> +		/* continue from prev block adding to the cur_contig hint */
> +		if (cur_contig) {
> +			cur_contig += block->left_free;
> +			if (block->left_free == PCPU_BITMAP_BLOCK_SIZE) {
> +				continue;
> +			} else if (cur_contig > chunk->contig_hint) {

The "else" here is superflous, right?  The if block always continues.

> +				chunk->contig_hint = cur_contig;
> +				chunk->contig_hint_start = off;
>  			}
> +			cur_contig = 0;
>  		}
> +		/* check if the block->contig_hint is larger */
> +		if (block->contig_hint > chunk->contig_hint) {
> +			chunk->contig_hint = block->contig_hint;
> +			chunk->contig_hint_start =
> +				pcpu_block_off_to_off(i,
> +						      block->contig_hint_start);
> +		}
> +		/* let the next iteration catch the right_free */
> +		cur_contig = block->right_free;
> +		off = (i + 1) * PCPU_BITMAP_BLOCK_SIZE - block->right_free;
>  	}
>  
> +	/* catch last iteration if the last block ends with free space */
> +	if (cur_contig > chunk->contig_hint) {
> +		chunk->contig_hint = cur_contig;
> +		chunk->contig_hint_start = off;
> +	}
>  
> +	/*
> +	 * Keep track of nr_empty_pop_pages.
> +	 *
> +	 * The chunk is maintains the previous number of free pages it held,
> +	 * so the delta is used to update the global counter.  The reserved
> +	 * chunk is not part of the free page count as they are populated
> +	 * at init and are special to serving reserved allocations.
> +	 */
> +	if (is_page_empty) {
> +		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, l_pop_off,
> +							 chunk->nr_pages);
> +	}

Unnecessary {}.

> +	if (chunk != pcpu_reserved_chunk)
> +		pcpu_nr_empty_pop_pages +=
> +			(nr_empty_pop_pages - chunk->nr_empty_pop_pages);
> +	chunk->nr_empty_pop_pages = nr_empty_pop_pages;
>  }

I am really not a big fan of the above implementation.  All it wants
to do is calculating the biggest free span and count unpopulated pages
in the chunk.  There gotta be a more readable way to implement this.
For example, would it be possible to implement span iterator over a
chunk which walks free spans of the chunk so that the above function
can do something similar to the following?

	for_each_free_span(blah blah) {
		nr_pop_free += count populated whole pages in the span;
		update contig hint;
	}

It's a span iteration problem.  When abstracted properly, it shouldn't
be too difficult to follow.

>  /**
> + * pcpu_block_update_hint
>   * @chunk: chunk of interest
> + * @index: block index of the metadata block
>   *
> + * Full scan over the entire block to recalculate block-level metadata.
> + */
> +static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
> +{
> +	unsigned long *alloc_map = pcpu_index_alloc_map(chunk, index);
> +	struct pcpu_bitmap_md *block = chunk->md_blocks + index;
> +	bool is_left_free = false, is_right_free = false;
> +	int contig;
> +	unsigned long start, end;
> +
> +	block->contig_hint = 0;
> +	start = end = block->first_free;
> +	while (start < PCPU_BITMAP_BLOCK_SIZE) {
> +		/*
> +		 * Scans the allocation map corresponding to this block
> +		 * to find free fragments and update metadata accordingly.
> +		 */
> +		start = find_next_zero_bit(alloc_map, PCPU_BITMAP_BLOCK_SIZE,
> +					   start);
> +		if (start >= PCPU_BITMAP_BLOCK_SIZE)
> +			break;

It's a lot simpler here but this too might look simpler with an
appropriate interation abstraction.

> +		/* returns PCPU_BITMAP_BLOCK_SIZE if no next bit is found */
> +		end = find_next_bit(alloc_map, PCPU_BITMAP_BLOCK_SIZE, start);

This isn't by no means a hard rule but it's often easier on the eyes
to have a blank line when code and comment are packed like this.

> +		/* update left_free */
> +		contig = end - start;
> +		if (start == 0) {
> +			block->left_free = contig;
> +			is_left_free = true;
> +		}
> +		/* update right_free */
> +		if (end == PCPU_BITMAP_BLOCK_SIZE) {
> +			block->right_free = contig;
> +			is_right_free = true;
> +		}
> +		/* update block contig_hints */
> +		if (block->contig_hint < contig) {
> +			block->contig_hint = contig;
> +			block->contig_hint_start = start;
> +		}
> +		start = end;
> +	}
> +
> +	/* clear left/right free hints */
> +	if (!is_left_free)
> +		block->left_free = 0;
> +	if (!is_right_free)
> +		block->right_free = 0;

Hmm... why do we need is_left/right_free?  Can't we reset them to zero
at the top and update directly during the loop?

> +static bool pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
> +					 int bit_size)
>  {
> +	bool update_chunk = false;
> +	int i;
> +	int s_index, e_index, s_off, e_off;
> +	struct pcpu_bitmap_md *s_block, *e_block, *block;
>  
> +	/* calculate per block offsets */
> +	s_index = pcpu_off_to_block_index(bit_off);
> +	e_index = pcpu_off_to_block_index(bit_off + bit_size);
> +	s_off = pcpu_off_to_block_off(bit_off);
> +	e_off = pcpu_off_to_block_off(bit_off + bit_size);
>  
> +	/*
> +	 * If the offset is the beginning of the next block, set it to the
> +	 * end of the previous block as the last bit is the exclusive.
> +	 */
> +	if (e_off == 0) {
> +		e_off = PCPU_BITMAP_BLOCK_SIZE;
> +		e_index--;
> +	}
>  
> +	s_block = chunk->md_blocks + s_index;
> +	e_block = chunk->md_blocks + e_index;
>  
> +	/*
> +	 * Update s_block.
> +	 *
> +	 * block->first_free must be updated if the allocation takes its place.
> +	 * If the allocation breaks the contig_hint, a scan is required to
> +	 * restore this hint.
> +	 */
> +	if (s_off == s_block->first_free)
> +		s_block->first_free = find_next_zero_bit(
> +					pcpu_index_alloc_map(chunk, s_index),
> +					PCPU_BITMAP_BLOCK_SIZE,
> +					s_off + bit_size);
> +
> +	if (s_off >= s_block->contig_hint_start &&
> +	    s_off < s_block->contig_hint_start + s_block->contig_hint) {
> +		pcpu_block_refresh_hint(chunk, s_index);
> +	} else {
> +		/* update left and right contig manually */
> +		s_block->left_free = min(s_block->left_free, s_off);
> +		if (s_index == e_index)
> +			s_block->right_free = min_t(int, s_block->right_free,
> +					PCPU_BITMAP_BLOCK_SIZE - e_off);
> +		else
> +			s_block->right_free = 0;
> +	}
>  
> +	/*
> +	 * Update e_block.
> +	 * If they are different, then e_block's first_free is guaranteed to
> +	 * be the extend of e_off.  first_free must be updated and a scan
> +	 * over e_block is issued.
> +	 */
> +	if (s_index != e_index) {
> +		e_block->first_free = find_next_zero_bit(
> +				pcpu_index_alloc_map(chunk, e_index),
> +				PCPU_BITMAP_BLOCK_SIZE, e_off);
>  
> +		pcpu_block_refresh_hint(chunk, e_index);
> +	}
>  
> +	/* update in-between md_blocks */
> +	for (i = s_index + 1, block = chunk->md_blocks + i; i < e_index;
> +	     i++, block++) {
> +		block->contig_hint = 0;
> +		block->left_free = 0;
> +		block->right_free = 0;
> +	}
>  
>  	/*
> +	 * The only time a full chunk scan is required is if the global
> +	 * contig_hint is broken.  Otherwise, it means a smaller space
> +	 * was used and therefore the global contig_hint is still correct.
>  	 */
> +	if (bit_off >= chunk->contig_hint_start &&
> +	    bit_off < chunk->contig_hint_start + chunk->contig_hint)
> +		update_chunk = true;
>  
> +	return update_chunk;

@update_chunk seems unnecessary.

> +static bool pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
> +					int bit_size)
>  {
> +	bool update_chunk = false;
> +	int i;
> +	int s_index, e_index, s_off, e_off;
> +	int start, end, contig;
> +	struct pcpu_bitmap_md *s_block, *e_block, *block;
>  
> +	/* calculate per block offsets */
> +	s_index = pcpu_off_to_block_index(bit_off);
> +	e_index = pcpu_off_to_block_index(bit_off + bit_size);
> +	s_off = pcpu_off_to_block_off(bit_off);
> +	e_off = pcpu_off_to_block_off(bit_off + bit_size);
> +
> +	/*
> +	 * If the offset is the beginning of the next block, set it to the
> +	 * end of the previous block as the last bit is the exclusive.
> +	 */
> +	if (e_off == 0) {
> +		e_off = PCPU_BITMAP_BLOCK_SIZE;
> +		e_index--;
> +	}

So, if you do the above with inclusive range, it becomes

	s_index = pcpu_off_to_block_index(start_bit);
	e_index = pcpu_off_to_block_index(end_bit - 1);
	s_off = pcpu_off_to_block_off(start_bit);
	e_off = pcpu_off_to_block_off(end_bit - 1) + 1;

and you can just comment that you're using inclusive range so that the
e_index always points to the last block in the range.  Wouldn't that
be easier?  People do use inclusive ranges for these sorts of
calculations.

> +	s_block = chunk->md_blocks + s_index;
> +	e_block = chunk->md_blocks + e_index;
> +
> +	/*
> +	 * Check if the freed area aligns with the block->contig_hint.
> +	 * If it does, then the scan to find the beginning/end of the
> +	 * larger free area can be avoided.
> +	 *
> +	 * start and end refer to beginning and end of the free region
> +	 * within each their respective blocks.  This is not necessarily
> +	 * the entire free region as it may span blocks past the beginning
> +	 * or end of the block.
> +	 */
> +	start = s_off;
> +	if (s_off == s_block->contig_hint + s_block->contig_hint_start) {
> +		start = s_block->contig_hint_start;
> +	} else {
> +		int l_bit = find_last_bit(pcpu_index_alloc_map(chunk, s_index),
> +					  start);
> +		start = (start == l_bit) ? 0 : l_bit + 1;
> +	}
> +
> +	end = e_off;
> +	if (e_off == e_block->contig_hint_start)
> +		end = e_block->contig_hint_start + e_block->contig_hint;
> +	else
> +		end = find_next_bit(pcpu_index_alloc_map(chunk, e_index),
> +				    PCPU_BITMAP_BLOCK_SIZE, end);
>  
> +	/* freeing in the same block */
> +	if (s_index == e_index) {
> +		contig = end - start;
>  
> +		if (start == 0)
> +			s_block->left_free = contig;
>  
> +		if (end == PCPU_BITMAP_BLOCK_SIZE)
> +			s_block->right_free = contig;
> +
> +		s_block->first_free = min(s_block->first_free, start);
> +		if (contig > s_block->contig_hint) {
> +			s_block->contig_hint = contig;
> +			s_block->contig_hint_start = start;
> +		}
> +
> +	} else {
>  		/*
> +		 * Freeing across md_blocks.
> +		 *
> +		 * If the start is at the beginning of the block, just
> +		 * reset the block instead.
>  		 */
> +		if (start == 0) {

The above comment can be moved here and lose the if in the sentence.
ie. "As the start is ..., just .."

> +			s_index--;
> +		} else {
> +			/*
> +			 * Knowing that the free is across blocks, this means
> +			 * the hint can be updated on the right side and the
> +			 * left side does not need to be touched.
> +			 */
> +			s_block->first_free = min(s_block->first_free, start);
> +			contig = PCPU_BITMAP_BLOCK_SIZE - start;
> +			s_block->right_free = contig;
> +			if (contig > s_block->contig_hint) {
> +				s_block->contig_hint = contig;
> +				s_block->contig_hint_start = start;
> +			}
> +		}

Blank line, please.

> +		/*
> +		 * If end is the entire e_block, just reset the block
> +		 * as well.
> +		 */
> +		if (end == PCPU_BITMAP_BLOCK_SIZE) {

ditto

> +			e_index++;
> +		} else {
> +			/*
> +			 * The hint must only be on the left side, so
> +			 * update accordingly.
> +			 */
> +			e_block->first_free = 0;
> +			e_block->left_free = end;
> +			if (end > e_block->contig_hint) {
> +				e_block->contig_hint = end;
> +				e_block->contig_hint_start = 0;
> +			}
> +		}
> +
> +		/* reset md_blocks in the middle */
> +		for (i = s_index + 1, block = chunk->md_blocks + i;
> +		     i < e_index; i++, block++) {

How about something like the following?  It's kinda weird to have an
extra loop var which isn't really used for anything.  The same goes
for other places too.

		for (block = chunk->md_blocks + s_index + 1;
		     block < chunk->md_blocks + e_index; block++)

> +			block->first_free = 0;
> +			block->contig_hint_start = 0;
> +			block->contig_hint = PCPU_BITMAP_BLOCK_SIZE;
> +			block->left_free = PCPU_BITMAP_BLOCK_SIZE;
> +			block->right_free = PCPU_BITMAP_BLOCK_SIZE;
> +		}
>  	}
> +
> +	/*
> +	 * The hint is only checked in the s_block and e_block when
> +	 * freeing and particularly only when it is self contained within
> +	 * its own block.  A scan is required if the free space spans
> +	 * blocks or makes a block whole as the scan will take into
> +	 * account free space across blocks.
> +	 */
> +	if ((start == 0 && end == PCPU_BITMAP_BLOCK_SIZE) ||
> +	    s_index != e_index) {
> +		update_chunk = true;
> +	} else if (s_block->contig_hint > chunk->contig_hint) {
> +		/* check if block contig_hint is bigger */
> +		chunk->contig_hint = s_block->contig_hint;
> +		chunk->contig_hint_start =
> +			pcpu_block_off_to_off(s_index,
> +					      s_block->contig_hint_start);
> +	}
> +
> +	return update_chunk;

Ditto with @update_chunk.

> +static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int bit_size,
> +			       size_t align, bool pop_only)
>  {
> +	int i, cur_free;
> +	int s_index, block_off, next_index, end_off; /* interior alloc index */
> +	struct pcpu_bitmap_md *block;
> +	unsigned long *alloc_map;
>  
> +	lockdep_assert_held(&pcpu_lock);
>  
> +	cur_free = block_off = 0;
> +	s_index = chunk->first_free_block;
> +	for (i = chunk->first_free_block; i < pcpu_nr_pages_to_blocks(chunk);
> +	     i++) {
> +		alloc_map = pcpu_index_alloc_map(chunk, i);
> +		block = chunk->md_blocks + i;
> +
> +		/* continue from prev block */
> +		cur_free += block->left_free;
> +		if (cur_free >= bit_size) {
> +			end_off = bit_size;
> +			goto check_populated;
> +		} else if (block->left_free == PCPU_BITMAP_BLOCK_SIZE) {
>  			continue;
>  		}
>  
>  		/*
> +		 * Can this block hold this alloc?
> +		 *
> +		 * Here the block->contig_hint is used to guarantee a fit,
> +		 * but the block->first_free is returned as we may be able
> +		 * to serve the allocation earlier.  The population check
> +		 * must take into account the area beginning at first_free
> +		 * through the end of the contig_hint.
>  		 */
> +		cur_free = 0;
> +		s_index = i;
> +		block_off = ALIGN(block->contig_hint_start, align);
> +		block_off -= block->contig_hint_start;
> +		if (block->contig_hint >= block_off + bit_size) {
> +			block_off = block->first_free;
> +			end_off = block->contig_hint_start - block_off +
> +				  bit_size;
> +			goto check_populated;
>  		}
>  
> +		/* check right */
> +		block_off = ALIGN(PCPU_BITMAP_BLOCK_SIZE - block->right_free,
> +				  align);
> +		/* reset to start looking in the next block */
> +		if (block_off >= PCPU_BITMAP_BLOCK_SIZE) {
> +			s_index++;
> +			cur_free = block_off = 0;
> +			continue;
>  		}
> +		cur_free = PCPU_BITMAP_BLOCK_SIZE - block_off;
> +		if (cur_free >= bit_size) {
> +			end_off = bit_size;
> +check_populated:
> +			if (!pop_only ||
> +			    pcpu_is_populated(chunk, s_index, block_off,
> +					      end_off, &next_index))
> +				break;
>  
> +			i = next_index - 1;
> +			s_index = next_index;
> +			cur_free = block_off = 0;
>  		}
> +	}
>  
> +	/* nothing found */
> +	if (i == pcpu_nr_pages_to_blocks(chunk))
> +		return -1;
>  
> +	return s_index * PCPU_BITMAP_BLOCK_SIZE + block_off;
> +}

Wouldn't this function be a lot simpler too if there were free span
iterator?

> +static int pcpu_alloc_area(struct pcpu_chunk *chunk, int bit_size,
> +			   size_t align, int start)
> +{
> +	size_t align_mask = (align) ? (align - 1) : 0;
> +	int i, bit_off, oslot;
> +	struct pcpu_bitmap_md *block;
> +
> +	lockdep_assert_held(&pcpu_lock);
> +
> +	oslot = pcpu_chunk_slot(chunk);
> +
> +	/* search to find fit */
> +	bit_off = bitmap_find_next_zero_area(chunk->alloc_map,
> +					     pcpu_nr_pages_to_bits(chunk),
> +					     start, bit_size, align_mask);
> +
> +	if (bit_off >= pcpu_nr_pages_to_bits(chunk))
> +		return -1;
> +
> +	/* update alloc map */
> +	bitmap_set(chunk->alloc_map, bit_off, bit_size);

blank line

> +	/* update boundary map */
> +	set_bit(bit_off, chunk->bound_map);
> +	bitmap_clear(chunk->bound_map, bit_off + 1, bit_size - 1);
> +	set_bit(bit_off + bit_size, chunk->bound_map);
> +
> +	chunk->free_bits -= bit_size;
> +
> +	if (pcpu_block_update_hint_alloc(chunk, bit_off, bit_size))
> +		pcpu_chunk_update_hint(chunk);
> +
> +	/* update chunk first_free */
> +	for (i = chunk->first_free_block, block = chunk->md_blocks + i;
> +	     i < pcpu_nr_pages_to_blocks(chunk); i++, block++)
> +		if (block->contig_hint != 0)
> +			break;
> +
> +	chunk->first_free_block = i;
>  
>  	pcpu_chunk_relocate(chunk, oslot);
>  
> +	return bit_off * PCPU_MIN_ALLOC_SIZE;
>  }
>  
>  /**
> + * pcpu_free_area - frees the corresponding offset
>   * @chunk: chunk of interest
> + * @off: addr offset into chunk
>   *
> + * This function determines the size of an allocation to free using
> + * the boundary bitmap and clears the allocation map.  A block metadata
> + * update is triggered and potentially a chunk update occurs.
>   */
> +static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
>  {
> +	int bit_off, bit_size, index, end, oslot;
> +	struct pcpu_bitmap_md *block;
>  
>  	lockdep_assert_held(&pcpu_lock);
>  	pcpu_stats_area_dealloc(chunk);
>  
> +	oslot = pcpu_chunk_slot(chunk);
>  
> +	bit_off = off / PCPU_MIN_ALLOC_SIZE;
>  
> +	/* find end index */
> +	end = find_next_bit(chunk->bound_map, pcpu_nr_pages_to_bits(chunk),
> +			    bit_off + 1);
> +	bit_size = end - bit_off;
>  
> +	bitmap_clear(chunk->alloc_map, bit_off, bit_size);
>  
> +	chunk->free_bits += bit_size;
> +
> +	/* update first_free */
> +	index = pcpu_off_to_block_index(bit_off);
> +	block = chunk->md_blocks + index;
> +	block->first_free = min_t(int, block->first_free,
> +				  bit_off % PCPU_BITMAP_BLOCK_SIZE);
> +
> +	chunk->first_free_block = min(chunk->first_free_block, index);
> +
> +	if (pcpu_block_update_hint_free(chunk, bit_off, bit_size))
> +		pcpu_chunk_update_hint(chunk);

Do we ever not update chunk hint when block hint indicates that it's
necessary?  If not, maybe just call it from the previous function?

>  static void pcpu_free_chunk(struct pcpu_chunk *chunk)
>  {
>  	if (!chunk)
>  		return;
> +	pcpu_mem_free(chunk->md_blocks);
> +	pcpu_mem_free(chunk->bound_map);
> +	pcpu_mem_free(chunk->alloc_map);
>  	pcpu_mem_free(chunk);
>  }
>  
> @@ -787,6 +1179,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
>  
>  	bitmap_set(chunk->populated, page_start, nr);
>  	chunk->nr_populated += nr;
> +	chunk->nr_empty_pop_pages += nr;
>  	pcpu_nr_empty_pop_pages += nr;
>  }
>  
> @@ -809,6 +1202,7 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
>  
>  	bitmap_clear(chunk->populated, page_start, nr);
>  	chunk->nr_populated -= nr;
> +	chunk->nr_empty_pop_pages -= nr;
>  	pcpu_nr_empty_pop_pages -= nr;
>  }

Didn't we add this field in an earlier patch?  Do the above changes
belong in this patch?

> @@ -890,19 +1284,23 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>  	struct pcpu_chunk *chunk;
>  	const char *err;
>  	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
> +	int slot, off, cpu, ret;
>  	unsigned long flags;
>  	void __percpu *ptr;
> +	size_t bit_size, bit_align;
>  
>  	/*
> +	 * There is now a minimum allocation size of PCPU_MIN_ALLOC_SIZE.
> +	 * Therefore alignment must be a minimum of that many bytes as well
> +	 * as the allocation will have internal fragmentation from
> +	 * rounding up by up to PCPU_MIN_ALLOC_SIZE - 1 bytes.
>  	 */
> +	if (unlikely(align < PCPU_MIN_ALLOC_SIZE))
> +		align = PCPU_MIN_ALLOC_SIZE;
> +	size = ALIGN(size, PCPU_MIN_ALLOC_SIZE);
> +	bit_size = size >> PCPU_MIN_ALLOC_SHIFT;
> +	bit_align = align >> PCPU_MIN_ALLOC_SHIFT;

Shouldn't the above have happened earlier when MIN_ALLOC_SIZE was
introduced?

> @@ -1363,15 +1710,15 @@ bool is_kernel_percpu_address(unsigned long addr)
>   * address.  The caller is responsible for ensuring @addr stays valid
>   * until this function finishes.
>   *
> - * percpu allocator has special setup for the first chunk, which currently
> + * Percpu allocator has special setup for the first chunk, which currently
>   * supports either embedding in linear address space or vmalloc mapping,
>   * and, from the second one, the backing allocator (currently either vm or
>   * km) provides translation.
>   *
>   * The addr can be translated simply without checking if it falls into the
> - * first chunk. But the current code reflects better how percpu allocator
> + * first chunk.  But the current code reflects better how percpu allocator
>   * actually works, and the verification can discover both bugs in percpu
> - * allocator itself and per_cpu_ptr_to_phys() callers. So we keep current
> + * allocator itself and per_cpu_ptr_to_phys() callers.  So we keep current

Let's please move out what can be to other patches.  This patch is big
enough as it is.

> @@ -1417,9 +1764,10 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
>  		else
>  			return page_to_phys(vmalloc_to_page(addr)) +
>  			       offset_in_page(addr);
> -	} else
> +	} else {
>  		return page_to_phys(pcpu_addr_to_page(addr)) +
>  		       offset_in_page(addr);
> +	}

Ditto.

> @@ -1555,10 +1903,12 @@ static void pcpu_dump_alloc_info(const char *lvl,
>   * static areas on architectures where the addressing model has
>   * limited offset range for symbol relocations to guarantee module
>   * percpu symbols fall inside the relocatable range.
> + * @ai->static_size + @ai->reserved_size is expected to be page aligned.
>   *
>   * @ai->dyn_size determines the number of bytes available for dynamic
> - * allocation in the first chunk.  The area between @ai->static_size +
> - * @ai->reserved_size + @ai->dyn_size and @ai->unit_size is unused.
> + * allocation in the first chunk. Both the start and the end are expected
> + * to be page aligned. The area between @ai->static_size + @ai->reserved_size
> + * + @ai->dyn_size and @ai->unit_size is unused.
     ^^^
     contam

>   *
>   * @ai->unit_size specifies unit size and must be aligned to PAGE_SIZE
>   * and equal to or larger than @ai->static_size + @ai->reserved_size +
> @@ -1581,11 +1931,11 @@ static void pcpu_dump_alloc_info(const char *lvl,
>   * copied static data to each unit.
>   *
>   * If the first chunk ends up with both reserved and dynamic areas, it
> - * is served by two chunks - one to serve the core static and reserved
> - * areas and the other for the dynamic area.  They share the same vm
> - * and page map but uses different area allocation map to stay away
> - * from each other.  The latter chunk is circulated in the chunk slots
> - * and available for dynamic allocation like any other chunks.
> + * is served by two chunks - one to serve the reserved area and the other
> + * for the dynamic area.  They share the same vm and page map but use
> + * different area allocation map to stay away from each other.  The latter
> + * chunk is circulated in the chunk slots and available for dynamic allocation
> + * like any other chunks.

ditto

> @@ -1703,7 +2051,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  	 * Allocate chunk slots.  The additional last slot is for
>  	 * empty chunks.
>  	 */
> -	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
> +	pcpu_nr_slots = __pcpu_size_to_slot(
> +				pcpu_pages_to_bits(pcpu_unit_pages)) + 2;

I get that we wanna be using bits inside the area allocator proper but
can we keep things outside in bytes?  These things don't really have
anything to do with what granularity the area allocator is operating
at.

> @@ -1727,69 +2076,50 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  	tmp_addr = (unsigned long)base_addr + ai->static_size;
>  	aligned_addr = tmp_addr & PAGE_MASK;
>  	pcpu_reserved_offset = tmp_addr - aligned_addr;
> +	begin_fill_bits = pcpu_reserved_offset / PCPU_MIN_ALLOC_SIZE;
>  
>  	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
>  			 pcpu_reserved_offset;
> +
>  	chunk_pages = map_size_bytes >> PAGE_SHIFT;
>  
>  	/* chunk adjacent to static region allocation */
> +	chunk = pcpu_alloc_first_chunk(chunk_pages);
>  	chunk->base_addr = (void *)aligned_addr;
>  	chunk->immutable = true;
>  
> +	/* set metadata */
> +	chunk->contig_hint = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
> +	chunk->free_bits = pcpu_nr_pages_to_bits(chunk) - begin_fill_bits;
>  
> +	/*
> +	 * If the beginning of the reserved region overlaps the end of the
> +	 * static region, hide that portion in the metadata.
> +	 */
> +	if (begin_fill_bits) {
>  		chunk->has_reserved = true;
> +		bitmap_fill(chunk->alloc_map, begin_fill_bits);
> +		set_bit(0, chunk->bound_map);
> +		set_bit(begin_fill_bits, chunk->bound_map);
> +
> +		if (pcpu_block_update_hint_alloc(chunk, 0, begin_fill_bits))
> +			pcpu_chunk_update_hint(chunk);
>  	}
>  
> +	/* init dynamic chunk if necessary */
> +	if (ai->reserved_size) {
> +		pcpu_reserved_chunk = chunk;
> +
>  		chunk_pages = dyn_size >> PAGE_SHIFT;
>  
>  		/* chunk allocation */
> +		chunk = pcpu_alloc_first_chunk(chunk_pages);
>  		chunk->base_addr = base_addr + ai->static_size +
>  				    ai->reserved_size;
> +
> +		/* set metadata */
> +		chunk->contig_hint = pcpu_nr_pages_to_bits(chunk);
> +		chunk->free_bits = pcpu_nr_pages_to_bits(chunk);
>  	}
>  
>  	/* link the first chunk in */

I *think* that quite a bit of the above can be moved into a separate
patch.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
