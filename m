Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDF16B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 03:32:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 13so108471579pgg.8
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:32:42 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id g3si9522938plb.309.2017.06.26.00.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 00:32:41 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] mm/hotplug: walk_memroy_range on memory_block uit
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-3-richard.weiyang@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <eeb06db0-086a-29f9-306d-a702984594df@nvidia.com>
Date: Mon, 26 Jun 2017 00:32:40 -0700
MIME-Version: 1.0
In-Reply-To: <20170625025227.45665-3-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

On 06/24/2017 07:52 PM, Wei Yang wrote:
> hotplug memory range is memory_block aligned and walk_memroy_range guarded
> with check_hotplug_memory_range(). This is save to iterate on the
> memory_block base.> 
> This patch adjust the iteration unit and assume there is not hole in
> hotplug memory range.

Hi Wei,

In the patch subject, s/memroy/memory/ , and s/uit/unit/, and
s/save/safe.

Actually, I still have a tough time with it, so maybe the 
description above could instead be worded approximately
like this:

Given that a hotpluggable memory range is now block-aligned,
it is safe for walk_memory_range to iterate by blocks.

Change walk_memory_range() so that it iterates at block
boundaries, rather than section boundaries. Also, skip the check
for whether pages are present in the section, and assume 
that there are no holes in the range. (<Insert reason why 
that is safe, here>)


> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/memory_hotplug.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f5d06afc8645..a79a83ec965f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1858,17 +1858,11 @@ int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>  	unsigned long pfn, section_nr;
>  	int ret;
>  
> -	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +	for (pfn = start_pfn; pfn < end_pfn;
> +		pfn += PAGES_PER_SECTION * sections_per_block) {

Here, and in one or two other spots in the patch, it would be nice
to repeat your approach from patch 0001, where you introduced a
pages_per_block variable. That definitely helps when reading the code.

>  		section_nr = pfn_to_section_nr(pfn);
> -		if (!present_section_nr(section_nr))
> -			continue;

Why is it safe to assume no holes in the memory range? (Maybe Michal's 
patch already covered this and I haven't got that far yet?)

The documentation for this routine says that it walks through all
present memory sections in the range, so it seems like this patch
breaks that.

>  
>  		section = __nr_to_section(section_nr);
> -		/* same memblock? */
> -		if (mem)
> -			if ((section_nr >= mem->start_section_nr) &&
> -			    (section_nr <= mem->end_section_nr))
> -				continue;

Yes, that deletion looks good.

thanks,
john h

>  
>  		mem = find_memory_block_hinted(section, mem);
>  		if (!mem)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
