Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 159B26B0089
	for <linux-mm@kvack.org>; Mon,  5 May 2014 08:40:41 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x12so1275524wgg.33
        for <linux-mm@kvack.org>; Mon, 05 May 2014 05:40:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si10021543een.5.2014.05.05.05.40.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 05:40:40 -0700 (PDT)
Message-ID: <536786C6.8040805@suse.cz>
Date: Mon, 05 May 2014 14:40:38 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 08/17] mm: page_alloc: Use word-based accesses for get/set
 pageblock bitmaps
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-9-git-send-email-mgorman@suse.de> <53641D8C.6040601@oracle.com> <20140504131454.GS23991@suse.de>
In-Reply-To: <20140504131454.GS23991@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/04/2014 03:14 PM, Mel Gorman wrote:
> On Fri, May 02, 2014 at 06:34:52PM -0400, Sasha Levin wrote:
>> Hi Mel,
>>
>> Vlastimil Babka suggested I should try this patch to work around a different
>> issue I'm seeing, and noticed that it doesn't build because:
>>
>
> Rebasing SNAFU. Can you try this instead?
>
> ---8<---
> mm: page_alloc: Use word-based accesses for get/set pageblock bitmaps
>
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
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fac5509..c84703d 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -75,9 +75,14 @@ enum {
>
>   extern int page_group_by_mobility_disabled;
>
> +#define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
> +#define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
> +
>   static inline int get_pageblock_migratetype(struct page *page)
>   {
> -	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
> +	BUILD_BUG_ON(PB_migrate_end - PB_migrate != 2);
> +	return get_pageblock_flags_mask(page, PB_migrate_end,
> +					NR_MIGRATETYPE_BITS, MIGRATETYPE_MASK);
>   }
>
>   struct free_area {
> diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
> index 2ee8cd2..bc37036 100644
> --- a/include/linux/pageblock-flags.h
> +++ b/include/linux/pageblock-flags.h
> @@ -30,9 +30,12 @@ enum pageblock_bits {
>   	PB_migrate,
>   	PB_migrate_end = PB_migrate + 3 - 1,
>   			/* 3 bits required for migrate types */
> -#ifdef CONFIG_COMPACTION
>   	PB_migrate_skip,/* If set the block is skipped by compaction */
> -#endif /* CONFIG_COMPACTION */
> +
> +	/*
> +	 * Assume the bits will always align on a word. If this assumption
> +	 * changes then get/set pageblock needs updating.
> +	 */
>   	NR_PAGEBLOCK_BITS
>   };
>
> @@ -62,11 +65,35 @@ extern int pageblock_order;
>   /* Forward declaration */
>   struct page;
>
> +unsigned long get_pageblock_flags_mask(struct page *page,
> +				unsigned long end_bitidx,
> +				unsigned long nr_flag_bits,
> +				unsigned long mask);
> +void set_pageblock_flags_mask(struct page *page,
> +				unsigned long flags,
> +				unsigned long end_bitidx,
> +				unsigned long nr_flag_bits,
> +				unsigned long mask);
> +

The nr_flag_bits parameter is not used anymore and can be dropped.

>   /* Declarations for getting and setting flags. See mm/page_alloc.c */
> -unsigned long get_pageblock_flags_group(struct page *page,
> -					int start_bitidx, int end_bitidx);
> -void set_pageblock_flags_group(struct page *page, unsigned long flags,
> -					int start_bitidx, int end_bitidx);
> +static inline unsigned long get_pageblock_flags_group(struct page *page,
> +					int start_bitidx, int end_bitidx)
> +{
> +	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
> +	unsigned long mask = (1 << nr_flag_bits) - 1;
> +
> +	return get_pageblock_flags_mask(page, end_bitidx, nr_flag_bits, mask);
> +}
> +
> +static inline void set_pageblock_flags_group(struct page *page,
> +					unsigned long flags,
> +					int start_bitidx, int end_bitidx)
> +{
> +	unsigned long nr_flag_bits = end_bitidx - start_bitidx + 1;
> +	unsigned long mask = (1 << nr_flag_bits) - 1;
> +
> +	set_pageblock_flags_mask(page, flags, end_bitidx, nr_flag_bits, mask);
> +}
>
>   #ifdef CONFIG_COMPACTION
>   #define get_pageblock_skip(page) \
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dc123ff..f393b0e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6032,53 +6032,64 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
>    * @end_bitidx: The last bit of interest
>    * returns pageblock_bits flags
>    */
> -unsigned long get_pageblock_flags_group(struct page *page,
> -					int start_bitidx, int end_bitidx)
> +unsigned long get_pageblock_flags_mask(struct page *page,
> +					unsigned long end_bitidx,
> +					unsigned long nr_flag_bits,
> +					unsigned long mask)
>   {
>   	struct zone *zone;
>   	unsigned long *bitmap;
> -	unsigned long pfn, bitidx;
> -	unsigned long flags = 0;
> -	unsigned long value = 1;
> +	unsigned long pfn, bitidx, word_bitidx;
> +	unsigned long word;
>
>   	zone = page_zone(page);
>   	pfn = page_to_pfn(page);
>   	bitmap = get_pageblock_bitmap(zone, pfn);
>   	bitidx = pfn_to_bitidx(zone, pfn);
> +	word_bitidx = bitidx / BITS_PER_LONG;
> +	bitidx &= (BITS_PER_LONG-1);
>
> -	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> -		if (test_bit(bitidx + start_bitidx, bitmap))
> -			flags |= value;
> -
> -	return flags;
> +	word = bitmap[word_bitidx];

I wonder if on some architecture this may result in inconsistent word 
when racing with set(), i.e. cmpxchg? We need consistency at least on 
the granularity of byte to prevent the problem with bogus migratetype 
values being read.

> +	bitidx += end_bitidx;
> +	return (word >> (BITS_PER_LONG - bitidx - 1)) & mask;

Yes that looks correct to me, bits don't seem to overlap anymore.

>   }
>
>   /**
> - * set_pageblock_flags_group - Set the requested group of flags for a pageblock_nr_pages block of pages
> + * set_pageblock_flags_mask - Set the requested group of flags for a pageblock_nr_pages block of pages
>    * @page: The page within the block of interest
>    * @start_bitidx: The first bit of interest
>    * @end_bitidx: The last bit of interest
>    * @flags: The flags to set
>    */
> -void set_pageblock_flags_group(struct page *page, unsigned long flags,
> -					int start_bitidx, int end_bitidx)
> +void set_pageblock_flags_mask(struct page *page, unsigned long flags,
> +					unsigned long end_bitidx,
> +					unsigned long nr_flag_bits,
> +					unsigned long mask)
>   {
>   	struct zone *zone;
>   	unsigned long *bitmap;
> -	unsigned long pfn, bitidx;
> -	unsigned long value = 1;
> +	unsigned long pfn, bitidx, word_bitidx;
> +	unsigned long old_word, new_word;
> +
> +	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
>
>   	zone = page_zone(page);
>   	pfn = page_to_pfn(page);
>   	bitmap = get_pageblock_bitmap(zone, pfn);
>   	bitidx = pfn_to_bitidx(zone, pfn);
> +	word_bitidx = bitidx / BITS_PER_LONG;
> +	bitidx &= (BITS_PER_LONG-1);
> +
>   	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
>
> -	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> -		if (flags & value)
> -			__set_bit(bitidx + start_bitidx, bitmap);
> -		else
> -			__clear_bit(bitidx + start_bitidx, bitmap);
> +	bitidx += end_bitidx;
> +	mask <<= (BITS_PER_LONG - bitidx - 1);
> +	flags <<= (BITS_PER_LONG - bitidx - 1);
> +
> +	do {
> +		old_word = ACCESS_ONCE(bitmap[word_bitidx]);
> +		new_word = (old_word & ~mask) | flags;
> +	} while (cmpxchg(&bitmap[word_bitidx], old_word, new_word) != old_word);

The bitfield logic here seems fine as well.

>   }
>
>   /*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
