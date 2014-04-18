Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBE46B0038
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:17:30 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1872367eek.9
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:17:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si41344467eel.223.2014.04.18.11.17.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:17:28 -0700 (PDT)
Message-ID: <53515DFD.4090009@suse.cz>
Date: Fri, 18 Apr 2014 19:16:45 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 10/16] mm: page_alloc: Use word-based accesses for get/set
 pageblock bitmaps
References: <1397832643-14275-1-git-send-email-mgorman@suse.de> <1397832643-14275-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM layout <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 04/18/2014 04:50 PM, Mel Gorman wrote:
> The test_bit operations in get/set pageblock flags are expensive. This patch
> reads the bitmap on a word basis and use shifts and masks to isolate the bits
> of interest. Similarly masks are used to set a local copy of the bitmap and then
> use cmpxchg to update the bitmap if there have been no other changes made in
> parallel.
> 
> In a test running dd onto tmpfs the overhead of the pageblock-related
> functions went from 1.27% in profiles to 0.5%.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/mmzone.h          |  6 +++++- 
>  include/linux/pageblock-flags.h | 21 ++++++++++++++++----
>  mm/page_alloc.c                 | 43 +++++++++++++++++++++++++----------------
>  3 files changed, 48 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index c1dbe0b..c97b4bc 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -75,9 +75,13 @@ enum {
>  
>  extern int page_group_by_mobility_disabled;
>  
> +#define NR_MIGRATETYPE_BITS 3
> +#define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
> +
>  static inline int get_pageblock_migratetype(struct page *page)
>  {
> -	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
> +	BUILD_BUG_ON(PB_migrate_end - PB_migrate != 2);
> +	return get_pageblock_flags_mask(page, NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK);
>  }
>  
>  struct free_area {
> diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
> index 2ee8cd2..c89ac75 100644
> --- a/include/linux/pageblock-flags.h
> +++ b/include/linux/pageblock-flags.h
> @@ -30,9 +30,12 @@ enum pageblock_bits {
>  	PB_migrate,
>  	PB_migrate_end = PB_migrate + 3 - 1,
>  			/* 3 bits required for migrate types */
> -#ifdef CONFIG_COMPACTION
>  	PB_migrate_skip,/* If set the block is skipped by compaction */
> -#endif /* CONFIG_COMPACTION */
> +
> +	/*
> +	 * Assume the bits will always align on a word. If this assumption
> +	 * changes then get/set pageblock needs updating.
> +	 */
>  	NR_PAGEBLOCK_BITS
>  };
>  
> @@ -62,9 +65,19 @@ extern int pageblock_order;
>  /* Forward declaration */
>  struct page;
>  
> +unsigned long get_pageblock_flags_mask(struct page *page,
> +				unsigned long nr_flag_bits,
> +				unsigned long mask);
> +
>  /* Declarations for getting and setting flags. See mm/page_alloc.c */
> -unsigned long get_pageblock_flags_group(struct page *page,
> -					int start_bitidx, int end_bitidx);
> +static inline unsigned long get_pageblock_flags_group(struct page *page,
> +					int start_bitidx, int end_bitidx)
> +{
> +	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
> +	unsigned long mask = (1 << nr_flag_bits) - 1;
> +
> +	return get_pageblock_flags_mask(page, nr_flag_bits, mask);
> +}
>  void set_pageblock_flags_group(struct page *page, unsigned long flags,
>  					int start_bitidx, int end_bitidx);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 737577c..6047866 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6012,25 +6012,24 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
>   * @end_bitidx: The last bit of interest
>   * returns pageblock_bits flags
>   */
> -unsigned long get_pageblock_flags_group(struct page *page,
> -					int start_bitidx, int end_bitidx)
> +unsigned long get_pageblock_flags_mask(struct page *page,
> +					unsigned long nr_flag_bits,
> +					unsigned long mask)

I don't think this can work with just nr_flag_bits and mask, without
taking start_bitidx into account. This probably only works when
start_bitidx == 0, which is true for PB_migrate, but not PB_migrate_skip.

>  {
>  	struct zone *zone;
>  	unsigned long *bitmap;
> -	unsigned long pfn, bitidx;
> -	unsigned long flags = 0;
> -	unsigned long value = 1;
> +	unsigned long pfn, bitidx, word_bitidx;
> +	unsigned long word;
>  
>  	zone = page_zone(page);
>  	pfn = page_to_pfn(page);
>  	bitmap = get_pageblock_bitmap(zone, pfn);
>  	bitidx = pfn_to_bitidx(zone, pfn);
> +	word_bitidx = bitidx / BITS_PER_LONG;
> +	bitidx &= (BITS_PER_LONG-1);
>  
> -	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> -		if (test_bit(bitidx + start_bitidx, bitmap))
> -			flags |= value;
> -
> -	return flags;
> +	word = bitmap[word_bitidx];
> +	return (word >> (BITS_PER_LONG - (bitidx + nr_flag_bits))) & mask;

Ugh, so for bitidx == 0, this shifts by 61 bits, so bits 61-63 is read.
Now consider this being called by get_pageblock_skip(). That will have
nr_flags_bit == 1, so shift by 63 -> bit 63 is read, but you probably
wanted bit 60? Or 60-62 for migratetype and 63 for the skip bit. I'm not
sure anymore which one matches the old bitmap layout and how endianness
plays a role here :) Friday evening... But, changing the order of bits,
and 4-bits within words doesn't matter I guess, except making sure that
the bitmap is now being allocated aligned to whole words so that we
don't read/write past the end of it.

>  }
>  
>  /**
> @@ -6045,20 +6044,30 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
>  {
>  	struct zone *zone;
>  	unsigned long *bitmap;
> -	unsigned long pfn, bitidx;
> -	unsigned long value = 1;
> +	unsigned long pfn, bitidx, word_bitidx;
> +	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
> +	unsigned long mask = (1 << nr_flag_bits) - 1;
> +	unsigned long old_word, new_word;
> +
> +	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
>  
>  	zone = page_zone(page);
>  	pfn = page_to_pfn(page);
>  	bitmap = get_pageblock_bitmap(zone, pfn   );
>  	bitidx = pfn_to_bitidx(zone, pfn);
> +	word_bitidx = bitidx / BITS_PER_LONG;
> +	bitidx &= (BITS_PER_LONG-1);
> +
>  	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
>  
> -	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> -		if (flags & value)
> -			__set_bit(bitidx + start_bitidx, bitmap);
> -		else
> -			__clear_bit(bitidx + start_bitidx, bitmap);
> +	end_bitidx = bitidx + (end_bitidx - start_bitidx);
> +	mask <<= (BITS_PER_LONG - end_bitidx - 1);
> +	flags <<= (BITS_PER_LONG - end_bitidx - 1);

Again, for bitidx == 0 and migratetype this will shift by 61, for skip
bit it will shift by 63 and overlap. Again, start_bitidx is not
considered except when subtracted from end_bitidx.
It would be also better if the code did not differ so much from the get_
version, which makes it harder to decide they operate on the same bits.

> +	do {
> +		old_word = ACCESS_ONCE(bitmap[word_bitidx]);
> +		new_word = (old_word & ~mask) | flags;
> +	} while (cmpxchg(&bitmap[word_bitidx], old_word, new_word) != old_word);

It seems that cmpxchg is not available for SMP that's not x86 :(

>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
