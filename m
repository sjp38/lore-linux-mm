Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34F2C6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:47:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7-v6so5126605pfi.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:47:27 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b4-v6si5964522pgu.390.2018.06.07.15.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:47:25 -0700 (PDT)
Subject: Re: [PATCH v4 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-5-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <766d4f69-befe-5219-9ede-6c9927f12f0a@intel.com>
Date: Thu, 7 Jun 2018 15:46:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180521101555.25610-5-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

> @@ -297,8 +298,8 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  		if (!present_section_nr(pnum))
>  			continue;
>  
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
> -		if (map_map[pnum])
> +		map_map[nr_consumed_maps] = sparse_mem_map_populate(pnum, nodeid, NULL);
> +		if (map_map[nr_consumed_maps++])
>  			continue;
...

This looks wonky.

This seems to say that even if we fail to sparse_mem_map_populate() (it
returns NULL), we still consume a map.  Is that right?

>  	/* fallback */
> +	nr_consumed_maps = 0;
>  	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
>  		struct mem_section *ms;
>  
>  		if (!present_section_nr(pnum))
>  			continue;
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
> -		if (map_map[pnum])
> +		map_map[nr_consumed_maps] = sparse_mem_map_populate(pnum, nodeid, NULL);
> +		if (map_map[nr_consumed_maps++])
>  			continue;

Same questionable pattern as above...

>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
> +	size2 = sizeof(struct page *) * nr_present_sections;
>  	map_map = memblock_virt_alloc(size2, 0);
>  	if (!map_map)
>  		panic("can not allocate map_map\n");
> @@ -586,27 +594,44 @@ void __init sparse_init(void)
>  				sizeof(map_map[0]));
>  #endif
>  
> +	/* The numner of present sections stored in nr_present_sections

"number"?

Also, this is not correct comment CodingStyle.

> +	 * are kept the same since mem sections are marked as present in
> +	 * memory_present().

Are you just trying to say that we are not making sections present here?

>                         In this for loop, we need check which sections
> +	 * failed to allocate memmap or usemap, then clear its
> +	 * ->section_mem_map accordingly. During this process, we need
> +	 * increase 'alloc_usemap_and_memmap' whether its allocation of
> +	 * memmap or usemap failed or not, so that after we handle the i-th
> +	 * memory section, can get memmap and usemap of (i+1)-th section
> +	 * correctly. */

I'm really scratching my head over this comment.  For instance "increase
'alloc_usemap_and_memmap'" doesn't make any sense to me.  How do you
increase a function?

I wonder if you could give that comment another shot.
