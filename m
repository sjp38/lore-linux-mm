Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id E96FC6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 09:52:16 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id j6so4411318oag.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 06:52:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130725134227.GT3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
	<1373594635-131067-5-git-send-email-holt@sgi.com>
	<CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
	<20130725022543.GR3421@sgi.com>
	<CAE9FiQV7Va8iAESoXsPCFJo8-jeA=-7SW2b9BmKnUrVonLV1=g@mail.gmail.com>
	<20130725134227.GT3421@sgi.com>
Date: Thu, 25 Jul 2013 06:52:15 -0700
Message-ID: <CAE9FiQUkbWNK7unUYJVCvdPypa0TkfybSm-Jtv917MNV=vok6w@mail.gmail.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Thu, Jul 25, 2013 at 6:42 AM, Robin Holt <holt@sgi.com> wrote:
> On Thu, Jul 25, 2013 at 05:50:57AM -0700, Yinghai Lu wrote:
>> On Wed, Jul 24, 2013 at 7:25 PM, Robin Holt <holt@sgi.com> wrote:
>> >>
>> >> How about holes that is not in memblock.reserved?
>> >>
>> >> before this patch:
>> >> free_area_init_node/free_area_init_core/memmap_init_zone
>> >> will mark all page in node range to Reserved in struct page, at first.
>> >>
>> >> but those holes is not mapped via kernel low mapping.
>> >> so it should be ok not touch "struct page" for them.
>> >>
>> >> Now you only mark reserved for memblock.reserved at first, and later
>> >> mark {memblock.memory} - { memblock.reserved} to be available.
>> >> And that is ok.
>> >>
>> >> but should split that change to another patch and add some comment
>> >> and change log for the change.
>> >> in case there is some user like UEFI etc do weird thing.
>> >
>> > Nate and I talked this over today.  Sorry for the delay, but it was the
>> > first time we were both free.  Neither of us quite understands what you
>> > are asking for here.  My interpretation is that you would like us to
>> > change the use of the PageReserved flag such that during boot, we do not
>> > set the flag at all from memmap_init_zone, and then only set it on pages
>> > which, at the time of free_all_bootmem, have been allocated/reserved in
>> > the memblock allocator.  Is that correct?  I will start to work that up
>> > on the assumption that is what you are asking for.
>>
>> Not exactly.
>>
>> your change should be right, but there is some subtle change about
>> holes handling.
>>
>> before mem holes between memory ranges in memblock.memory, get struct page,
>> and initialized with to Reserved in memmap_init_zone.
>> Those holes is not in memory.reserved, with your patches, those hole's
>> struct page
>> will still have all 0.
>>
>> Please separate change about set page to reserved according to memory.reserved
>> to another patch.
>
>
> Just want to make sure this is where you want me to go.  Here is my
> currently untested patch.  Is that what you were expecting to have done?
> One thing I don't like about this patch is it seems to slow down boot in
> my simulator environment.  I think I am going to look at restructuring
> things a bit to see if I can eliminate that performance penalty.
> Otherwise, I think I am following your directions.

>
> From bdd2fefa59af18f283af6f066bc644ddfa5c7da8 Mon Sep 17 00:00:00 2001
> From: Robin Holt <holt@sgi.com>
> Date: Thu, 25 Jul 2013 04:25:15 -0500
> Subject: [RFC -v2-pre2 4/5] ZZZ Only SegPageReserved() on memblock reserved
>  pages.

yes.

>
> ---
>  include/linux/mm.h |  2 ++
>  mm/nobootmem.c     |  3 +++
>  mm/page_alloc.c    | 18 +++++++++++-------
>  3 files changed, 16 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e0c8528..b264a26 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1322,6 +1322,8 @@ static inline void adjust_managed_page_count(struct page *page, long count)
>         totalram_pages += count;
>  }
>
> +extern void reserve_bootmem_region(unsigned long start, unsigned long end);
> +
>  /* Free the reserved page into the buddy system, so it gets managed. */
>  static inline void __free_reserved_page(struct page *page)
>  {
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 2159e68..0840af2 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -117,6 +117,9 @@ static unsigned long __init free_low_memory_core_early(void)
>         phys_addr_t start, end, size;
>         u64 i;
>
> +       for_each_reserved_mem_region(i, &start, &end)
> +               reserve_bootmem_region(start, end);
> +
>         for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
>                 count += __free_memory_core(start, end);
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 048e166..3aa30b7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -698,7 +698,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  }
>
>  static void __init_single_page(unsigned long pfn, unsigned long zone,
> -                              int nid, int reserved)
> +                              int nid, int page_count)
>  {
>         struct page *page = pfn_to_page(pfn);
>         struct zone *z = &NODE_DATA(nid)->node_zones[zone];
> @@ -708,12 +708,9 @@ static void __init_single_page(unsigned long pfn, unsigned long zone,
>         init_page_count(page);
>         page_mapcount_reset(page);
>         page_nid_reset_last(page);
> -       if (reserved) {
> -               SetPageReserved(page);
> -       } else {
> -               ClearPageReserved(page);
> -               set_page_count(page, 0);
> -       }
> +       ClearPageReserved(page);
> +       set_page_count(page, page_count);
> +
>         /*
>          * Mark the block movable so that blocks are reserved for
>          * movable at startup. This will force kernel allocations
> @@ -741,6 +738,13 @@ static void __init_single_page(unsigned long pfn, unsigned long zone,
>  #endif
>  }
>
> +void reserve_bootmem_region(unsigned long start, unsigned long end)
> +{
> +       for (; start < end; start++)
> +               if (pfn_valid(start))
> +                       SetPageReserved(pfn_to_page(start));
> +}
> +
>  static bool free_pages_prepare(struct page *page, unsigned int order)
>  {
>         int i;
> --
> 1.8.2.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
