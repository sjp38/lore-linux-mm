Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2BAC6B0008
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:11:27 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b185-v6so17720520qkg.19
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:11:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z13-v6si4797679qkf.190.2018.07.01.19.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 19:11:27 -0700 (PDT)
Date: Mon, 2 Jul 2018 10:11:21 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Message-ID: <20180702021121.GL3223@MiWiFi-R3L-srv>
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702020417.21281-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

Hi Pavel,

Thanks for your quick fix. You might have missed another comment to v2
patch 1/2 which is at the bottom.

On 07/01/18 at 10:04pm, Pavel Tatashin wrote:
> +/*
> + * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
> + * And number of present sections in this node is map_count.
> + */
> +void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> +				   unsigned long pnum_end,
> +				   unsigned long map_count)
> +{
> +	unsigned long pnum, usemap_longs, *usemap, map_index;
> +	struct page *map, *map_base;
> +
> +	usemap_longs = BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS);
> +	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
> +							  usemap_size() *
> +							  map_count);
> +	if (!usemap) {
> +		pr_err("%s: usemap allocation failed", __func__);
> +		goto failed;
> +	}
> +	map_base = sparse_populate_node(pnum_begin, pnum_end,
> +					map_count, nid);
> +	map_index = 0;
> +	for_each_present_section_nr(pnum_begin, pnum) {
> +		if (pnum >= pnum_end)
> +			break;
> +
> +		BUG_ON(map_index == map_count);
> +		map = sparse_populate_node_section(map_base, map_index,
> +						   pnum, nid);
> +		if (!map) {

Here, I think it might be not right to jump to 'failed' directly if one
section of the node failed to populate memmap. I think the original code
is only skipping the section which memmap failed to populate by marking
it as not present with "ms->section_mem_map = 0".

> +			pr_err("%s: memory map backing failed. Some memory will not be available.",
> +			       __func__);
> +			pnum_begin = pnum;
> +			goto failed;
> +		}
> +		check_usemap_section_nr(nid, usemap);
> +		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> +					usemap);
> +		map_index++;
> +		usemap += usemap_longs;
> +	}
> +	return;
> +failed:
> +	/* We failed to allocate, mark all the following pnums as not present */
> +	for_each_present_section_nr(pnum_begin, pnum) {
> +		struct mem_section *ms;
> +
> +		if (pnum >= pnum_end)
> +			break;
> +		ms = __nr_to_section(pnum);
> +		ms->section_mem_map = 0;
> +	}
> +}
> +
>  /*
>   * Allocate the accumulated non-linear sections, allocate a mem_map
>   * for each and record the physical to section mapping.
> -- 
> 2.18.0
> 
