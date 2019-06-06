Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7B4BC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:21:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C0FF20872
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 17:21:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C0FF20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 179466B027D; Thu,  6 Jun 2019 13:21:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A0B6B027E; Thu,  6 Jun 2019 13:21:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019246B027F; Thu,  6 Jun 2019 13:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF786B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 13:21:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f17so4684177eda.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 10:21:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ydmW5jso3JZuPsN2nZdjLKJumvT7JMEr3UYP5iIq71c=;
        b=KmAjtoln+rmWg+MOawj++d47J6DtXCNwzlUUYYo/dm8njiqzaF+FAGUZMyNUQ/7ImO
         AE7rBpDOBPP2+62r1q4svNRNRLGZBMr45drr5vEI8wUijvqeOhbxGv15csv4gtT5Mb7S
         lN90A93vOThlyQhxs+ukWCZMNcDwIVlgXK5xVBLZLKAoz8V2ndwxFlki/eoTeeUPWG8v
         3ZaXSJiLf15MH+aAjMoK2A6oxtQyDq9lo42thA0yrH9k8GoD7KLlWebVk6ESKbpRjJhv
         DIHBQimQ2+kFrxObadMUAMxh7+aW7NAHpQwi6vkGKu8ms1yb+TUXka0iy3CspqhRwpFo
         a5Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW19EYSOEllA9WY5ZTsMqyL4pOmbep6SqSk7k/PX5vft10mgPgR
	hudNUjsnBhArp+b4IguGLMRA0wRCCRdvhmdm8g5vA3HYvjRXg0X2iiMyWxOKCzGJSbLM2nz/n2/
	qmzpkpKCueR1SCE/vyaRBSSaGRN6hyLL1HjXiziPbsiX0rRRmJSpkahnoSLyAUmDSyw==
X-Received: by 2002:aa7:c995:: with SMTP id c21mr51460435edt.254.1559841674120;
        Thu, 06 Jun 2019 10:21:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHjRjEPNsBrj9fiYp2OlDma6DYU2JPhKg+E7NNAAsd1xtqdejo8yfAHHNNKE/EjTuIxKEJ
X-Received: by 2002:aa7:c995:: with SMTP id c21mr51460346edt.254.1559841673148;
        Thu, 06 Jun 2019 10:21:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559841673; cv=none;
        d=google.com; s=arc-20160816;
        b=TKomr4hMQ6GbnoljIINnXOQkkSx8GMdnwko8fLMVOTajmWXoohF2lUrPNnlK4mZxEb
         sDrRiyL2Xgx/mY5pVIsshhYHZ4UrKu68hfXuMPOgxrNxgWAoKN8ny6452DqeQmxZd/HU
         N33J6wDwi5RmH3rhlH/mJIEBHkJxFNHo9jfoAgEbvDIDA3YPD3/9PV8GPddwztKW5Wv/
         die6TFgSVN0J4yiwHOegWZWCKCxlL7z5SrGt+7qJrDj7JKXhbXylFMsdZ0Y7eS6JpikB
         vvEl4fnYcsf7rxTIE3ejxSY6Btor3yd7FDpZ1XbT5BAFFmcPyp5Rycy5fBVTSs6mekJd
         N7Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ydmW5jso3JZuPsN2nZdjLKJumvT7JMEr3UYP5iIq71c=;
        b=KN0CE/e4BaXaN2gdrnpp3XHRWtkVDZm4bq+3HjhX63aDHj7NKFk7QYYn62C2k47ySZ
         FirRu9i5+BzB/dIDwfqu+Wb/1UGes1rNugCbDok1Zm5iZPJEs+QdpF16xkBA85m401hx
         bXLRpBpjfVgMQt/FM0qkM5256TkMLREQRbD94pkMZkN9vS2aovVTiT6L48Blo+VSF9AZ
         G/YAVihRKoytF0akLE0rF7o2XAhnMQgyBahXVMlo7OevekITLlimy8wdg9sNQ5Ysezos
         QOvzpYW2wrZUbR9Ucj9egCNKrYHPDOMir1nzBcZxiJeSB8DK2pu6WF+j/BdOHeo42SoA
         1QOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy21si584562ejb.170.2019.06.06.10.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 10:21:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ADFCEABD0;
	Thu,  6 Jun 2019 17:21:12 +0000 (UTC)
Date: Thu, 6 Jun 2019 19:21:10 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 07/12] mm/sparsemem: Prepare for sub-section ranges
Message-ID: <20190606172110.GC31194@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977191770.2443951.1506588644989416699.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977191770.2443951.1506588644989416699.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:37PM -0700, Dan Williams wrote:
> Prepare the memory hot-{add,remove} paths for handling sub-section
> ranges by plumbing the starting page frame and number of pages being
> handled through arch_{add,remove}_memory() to
> sparse_{add,remove}_one_section().
> 
> This is simply plumbing, small cleanups, and some identifier renames. No
> intended functional changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/memory_hotplug.h |    5 +-
>  mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
>  mm/sparse.c                    |   15 ++---
>  3 files changed, 81 insertions(+), 53 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 79e0add6a597..3ab0282b4fe5 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -348,9 +348,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> -				  struct vmem_altmap *altmap);
> +extern int sparse_add_section(int nid, unsigned long pfn,
> +		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern void sparse_remove_one_section(struct mem_section *ms,
> +		unsigned long pfn, unsigned long nr_pages,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
>  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
>  					  unsigned long pnum);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4b882c57781a..399bf78bccc5 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -252,51 +252,84 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>  }
>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>  
> -static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> -				   struct vmem_altmap *altmap)
> +static int __meminit __add_section(int nid, unsigned long pfn,
> +		unsigned long nr_pages,	struct vmem_altmap *altmap)
>  {
>  	int ret;
>  
> -	if (pfn_valid(phys_start_pfn))
> +	if (pfn_valid(pfn))
>  		return -EEXIST;
>  
> -	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> +	ret = sparse_add_section(nid, pfn, nr_pages, altmap);
>  	return ret < 0 ? ret : 0;
>  }
>  
> +static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
> +		const char *reason)
> +{
> +	/*
> +	 * Disallow all operations smaller than a sub-section and only
> +	 * allow operations smaller than a section for
> +	 * SPARSEMEM_VMEMMAP. Note that check_hotplug_memory_range()
> +	 * enforces a larger memory_block_size_bytes() granularity for
> +	 * memory that will be marked online, so this check should only
> +	 * fire for direct arch_{add,remove}_memory() users outside of
> +	 * add_memory_resource().
> +	 */
> +	unsigned long min_align;
> +
> +	if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
> +		min_align = PAGES_PER_SUBSECTION;
> +	else
> +		min_align = PAGES_PER_SECTION;
> +	if (!IS_ALIGNED(pfn, min_align)
> +			|| !IS_ALIGNED(nr_pages, min_align)) {
> +		WARN(1, "Misaligned __%s_pages start: %#lx end: #%lx\n",
> +				reason, pfn, pfn + nr_pages - 1);
> +		return -EINVAL;
> +	}
> +	return 0;
> +}


This caught my eye.
Back in patch#4 "Convert kmalloc_section_memmap() to populate_section_memmap()",
you placed a mis-usage check for !CONFIG_SPARSEMEM_VMEMMAP in
populate_section_memmap().

populate_section_memmap() gets called from sparse_add_one_section(), which means
that we should have passed this check, otherwise we cannot go further and call
__add_section().

So, unless I am missing something it seems to me that the check from patch#4 could go?
And I think the same applies to depopulate_section_memmap()?

Besides that, it looks good to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

