Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7CAAC76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:05:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 688F221019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 688F221019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF2D6B0003; Thu, 18 Jul 2019 08:05:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5AAE6B0005; Thu, 18 Jul 2019 08:05:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20C78E0001; Thu, 18 Jul 2019 08:05:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E05A6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:05:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so19831839edc.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:05:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NY4cIsvYrKx5LHOdr6RzUggBbac0vqzPS1Du+3s3+LQ=;
        b=CsCi8QsvHvMcAPNmvjmfJfkLvGsoXqjhH7RRSxjvYHS4lDZHdQy5tTxLBitw7oZMhj
         a9ocHQAAC/C21oKgNKNMemyRGXwBEzQM8rRRb8rGxqESi+bsowV/Egp6urRxpZ9tkVfI
         +/sMSmV2D/zsvpgR5ny0DaV1GOIWXTzLALrSCAzL+MuayrgBLbgTRA8vy0qcHXAJevpX
         j8R0sUJXaBdyQ0zjyazxbT/IEpSLUDOVCRGkrr9KiTrYWyp9CqTS9P6/sF1S2FAznHjn
         kt07zUvFjSOfn0Qh9e3J7fPF/rJEQllUhfKvNZ2TzfCK+ZWW5GAXG/TZHJOSMAVBs8Pz
         HpJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX/9KXe/TLspiJibsIO5Zs4htopo5WpLJMU1DqYECOUTmwbsYmn
	wUMNlnz4n+I8I7f4frTKxdLje3DyaESvX5936ZT3DnVfVnNZAD4noaRiMZS+yxZwdBzhhtLqZmD
	AA3vzlNS6jq4/JvMHVAc1UjAAdxBZt+O9CrO8ELSzRB7oiNs3bxeND/xplLLCsd9wBA==
X-Received: by 2002:a50:a56b:: with SMTP id z40mr39220963edb.99.1563451552006;
        Thu, 18 Jul 2019 05:05:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/V6NOazwuGZpaKDhJWllTu7r62wZQv1Kfsv+1Fl3amPZ3WRk6WdIf2BBPdZK0apM8ZY60
X-Received: by 2002:a50:a56b:: with SMTP id z40mr39220851edb.99.1563451551002;
        Thu, 18 Jul 2019 05:05:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563451550; cv=none;
        d=google.com; s=arc-20160816;
        b=La4asg7NW2oJ6nU1bo3r1pkgybC2VbzIpG2MBfDScXNX1BXfz+X19WgXtA2DpjEae3
         it3YRgS6tbUrQipxCQXxPtzUh+7Jxof8bU3VO3UbpWgZ77ymT6L3bBcNwIQ82hsQ7ipn
         sd5z4PN0Z7ZxAJ8zwQk6bYvU3t0cOd1R4it3TrKGa6yLTylNtmzDygilel5NjRvPUkVJ
         ZxX7F4cZvMtabYBn4M9trxSHSDFnfe0d8bvoRfVi3m36yhmhF/89ajljhot7Z21pVKbE
         lSFaa4j0jedQ59l/keK6OeIBI+0NgmWaOixm/ToexKzuglakqijSw3M7JyuVRuejEyBt
         npaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NY4cIsvYrKx5LHOdr6RzUggBbac0vqzPS1Du+3s3+LQ=;
        b=ZJG8GeMEN8i5pT7tEVrQS7Z7m7VZWFDowpFfcnVyHBkuxAbvZLcKNC0GZjrCaOeXO6
         Vg/J76/yQLl2T/stRXrvpJHYzLvl4rxP5Uyzoaw8nlxVy3I28EFcLAW/t+xjD14IU4E8
         8lO0skUibiusgFG5O+B7L6A4ArYaofdfRP5AverhOt7Evs8mmCklMbbelYeC+pmNJqdn
         B3W23vmQC6Y8L0InHCT3rtMP4t70oFL7RNxZnsF/Cun/DTv2Uas8cZuj8a0Uge/bwMmE
         8Mo7xGhDucdWIf7m4sXT7v7fvrBNtNCMdlQgO1n0Rs9AmpmB7R/VCsEwgLW7PDRa6hzO
         5eyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20si16905edb.132.2019.07.18.05.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 05:05:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1FAC3AD4D;
	Thu, 18 Jul 2019 12:05:50 +0000 (UTC)
Date: Thu, 18 Jul 2019 14:05:47 +0200
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, david@redhat.com, pasha.tatashin@soleen.com,
	mhocko@suse.com, aneesh.kumar@linux.ibm.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Message-ID: <20190718120543.GA8500@linux>
References: <20190715081549.32577-1-osalvador@suse.de>
 <20190715081549.32577-3-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190715081549.32577-3-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 10:15:49AM +0200, Oscar Salvador wrote:
> Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION granularity.
> The problem is that deactivation of the section occurs later on in
> sparse_remove_section, so pfn_valid()->pfn_section_valid() will always return
> true before we deactivate the {sub}section.
> 
> I spotted this during hotplug hotremove tests, there I always saw that
> spanned_pages was, at least, left with PAGES_PER_SECTION, even if we
> removed all memory linked to that zone.
> 
> Fix this by decoupling section_deactivate from sparse_remove_section, and
> re-order the function calls.
> 
> Now, __remove_section will:
> 
> 1) deactivate section
> 2) shrink {zone,node}'s pages
> 3) remove section
> 
> [1] https://patchwork.kernel.org/patch/11003467/

Hi Andrew,

Please, drop this patch as patch [1] is the easiest way to fix this.

thanks a lot

[1] https://patchwork.kernel.org/patch/11047499/

> 
> Fixes: mmotm ("mm/hotplug: prepare shrink_{zone, pgdat}_span for sub-section removal")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/memory_hotplug.h |  7 ++--
>  mm/memory_hotplug.c            |  6 +++-
>  mm/sparse.c                    | 77 +++++++++++++++++++++++++++++-------------
>  3 files changed, 62 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index f46ea71b4ffd..d2eb917aad5f 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -348,9 +348,10 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern int sparse_add_section(int nid, unsigned long pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
> -extern void sparse_remove_section(struct mem_section *ms,
> -		unsigned long pfn, unsigned long nr_pages,
> -		unsigned long map_offset, struct vmem_altmap *altmap);
> +int sparse_deactivate_section(unsigned long pfn, unsigned long nr_pages);
> +void sparse_remove_section(unsigned long pfn, unsigned long nr_pages,
> +                           unsigned long map_offset, struct vmem_altmap *altmap,
> +                           int section_empty);
>  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
>  					  unsigned long pnum);
>  extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b9ba5b85f9f7..03d535eee60d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -517,12 +517,16 @@ static void __remove_section(struct zone *zone, unsigned long pfn,
>  		struct vmem_altmap *altmap)
>  {
>  	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
> +	int ret;
>  
>  	if (WARN_ON_ONCE(!valid_section(ms)))
>  		return;
>  
> +	ret = sparse_deactivate_section(pfn, nr_pages);
>  	__remove_zone(zone, pfn, nr_pages);
> -	sparse_remove_section(ms, pfn, nr_pages, map_offset, altmap);
> +	if (ret >= 0)
> +		sparse_remove_section(pfn, nr_pages, map_offset, altmap,
> +				      ret);
>  }
>  
>  /**
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 1e224149aab6..d4953ee1d087 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -732,16 +732,47 @@ static void free_map_bootmem(struct page *memmap)
>  }
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
> -static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
> -		struct vmem_altmap *altmap)
> +static void section_remove(unsigned long pfn, unsigned long nr_pages,
> +			   struct vmem_altmap *altmap, int section_empty)
> +{
> +	struct mem_section *ms = __pfn_to_section(pfn);
> +	bool section_early = early_section(ms);
> +	struct page *memmap = NULL;
> +
> +	if (section_empty) {
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +
> +		if (!section_early) {
> +			kfree(ms->usage);
> +			ms->usage = NULL;
> +		}
> +		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
> +		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
> +	}
> +
> +        if (section_early && memmap)
> +		free_map_bootmem(memmap);
> +        else
> +		depopulate_section_memmap(pfn, nr_pages, altmap);
> +}
> +
> +/**
> + * section_deactivate: Deactivate a {sub}section.
> + *
> + * Return:
> + * * -1         - {sub}section has already been deactivated.
> + * * 0          - Section is not empty
> + * * 1          - Section is empty
> + */
> +
> +static int section_deactivate(unsigned long pfn, unsigned long nr_pages)
>  {
>  	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
>  	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
>  	struct mem_section *ms = __pfn_to_section(pfn);
> -	bool section_is_early = early_section(ms);
> -	struct page *memmap = NULL;
>  	unsigned long *subsection_map = ms->usage
>  		? &ms->usage->subsection_map[0] : NULL;
> +	int section_empty = 0;
>  
>  	subsection_mask_set(map, pfn, nr_pages);
>  	if (subsection_map)
> @@ -750,7 +781,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>  	if (WARN(!subsection_map || !bitmap_equal(tmp, map, SUBSECTIONS_PER_SECTION),
>  				"section already deactivated (%#lx + %ld)\n",
>  				pfn, nr_pages))
> -		return;
> +		return -1;
>  
>  	/*
>  	 * There are 3 cases to handle across two configurations
> @@ -770,21 +801,10 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>  	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
>  	 */
>  	bitmap_xor(subsection_map, map, subsection_map, SUBSECTIONS_PER_SECTION);
> -	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
> -		unsigned long section_nr = pfn_to_section_nr(pfn);
> -
> -		if (!section_is_early) {
> -			kfree(ms->usage);
> -			ms->usage = NULL;
> -		}
> -		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
> -		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
> -	}
> +	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION))
> +		section_empty = 1;
>  
> -	if (section_is_early && memmap)
> -		free_map_bootmem(memmap);
> -	else
> -		depopulate_section_memmap(pfn, nr_pages, altmap);
> +	return section_empty;
>  }
>  
>  static struct page * __meminit section_activate(int nid, unsigned long pfn,
> @@ -834,7 +854,11 @@ static struct page * __meminit section_activate(int nid, unsigned long pfn,
>  
>  	memmap = populate_section_memmap(pfn, nr_pages, nid, altmap);
>  	if (!memmap) {
> -		section_deactivate(pfn, nr_pages, altmap);
> +		int ret;
> +
> +		ret = section_deactivate(pfn, nr_pages);
> +		if (ret >= 0)
> +			section_remove(pfn, nr_pages, altmap, ret);
>  		return ERR_PTR(-ENOMEM);
>  	}
>  
> @@ -919,12 +943,17 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  }
>  #endif
>  
> -void sparse_remove_section(struct mem_section *ms, unsigned long pfn,
> -		unsigned long nr_pages, unsigned long map_offset,
> -		struct vmem_altmap *altmap)
> +int sparse_deactivate_section(unsigned long pfn, unsigned long nr_pages)
> +{
> +	return section_deactivate(pfn, nr_pages);
> +}
> +
> +void sparse_remove_section(unsigned long pfn, unsigned long nr_pages,
> +			   unsigned long map_offset, struct vmem_altmap *altmap,
> +			   int section_empty)
>  {
>  	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
>  			nr_pages - map_offset);
> -	section_deactivate(pfn, nr_pages, altmap);
> +	section_remove(pfn, nr_pages, altmap, section_empty);
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> -- 
> 2.12.3
> 

-- 
Oscar Salvador
SUSE L3

