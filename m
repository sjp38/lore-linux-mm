Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F177DC4646C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:31:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81C6A2082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:31:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81C6A2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBDF36B0003; Thu, 20 Jun 2019 06:31:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6F028E0002; Thu, 20 Jun 2019 06:31:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B370F8E0001; Thu, 20 Jun 2019 06:31:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 911466B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:31:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 5so3064233qki.2
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:31:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=kfvuWgds8NobdQcGReWJjBLL+2NNohkB+B2DAZ7kWDs=;
        b=VfZBLDRMrTt9Em3nXRHelJPNhx5hwe1OJgM703U9LGgLop/mSJ3+0ymRI3Ol0GL5Kx
         r78XlfVTnmRwuuycuVu9ofpHtHPyBlyPsyKstfZI66ZruUZJA3rTo1wjxLG67s7103+7
         YOE728IygH8/wUtsWQuZI3N9fMHthMk+S0KW3mu94vgn/S3qbyBbcWEcwgbE5fMz86yt
         vpQP/u5FZr3TLquLwe1vQZEb+ot8uRIdw38VeCKA9TAwm+B3EkNpwrM/oQZP9MiMJNYj
         G9yde2OJagjpJVi25MllyQ4zbhSik5BMxtSGLG3n7RgB9Max9YG8W/CVEUbYnT78CWX+
         2+eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzuxp111OIoVLqkbW79bHch2/PUc4iKwhAfkc84crCwyV+V2cA
	ghfYM9EoyMSISZOXjiyricSxuSwb8U0JyGjZ+9uz1AqCwLQVuz1tZOGt4jHhstn6AriEbU+ZbGl
	Gclrphyd9O9oDRrhrifxgIuKbJvZyHxR7lS3/jRBzhvEJvpEHvuQCZKsz+qR2vfUcaA==
X-Received: by 2002:a37:7847:: with SMTP id t68mr101718907qkc.128.1561026680327;
        Thu, 20 Jun 2019 03:31:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd8sMLLnHSw91MCakHTPKcASneL+1VCKM8t7ARG8h5MITKrNFT6jV/b12XcjW4hBcDYCpO
X-Received: by 2002:a37:7847:: with SMTP id t68mr101718852qkc.128.1561026679455;
        Thu, 20 Jun 2019 03:31:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026679; cv=none;
        d=google.com; s=arc-20160816;
        b=SYXswCjlr2viWhPUxKDz0lKW6+7VUTaGxZs7S9W6JzOsFxjkvdHmXA797c72i98D9G
         h08c9gHWpIQnscNLMf3AS0FoptVkrlZdFJeB4LA5MkmjQCLxPQNhf2hBX/3tXJtIMjY4
         BdqPMds6MFsicVgyNYqXlq0TZ2OJuIpC4ATBSdI3tbeLcY4TxkKOPnvPyoAiIZ1QFFDs
         26zQk+YxptAa+D1TIGtjTsewG9Z9cKK0CI0gE0wbE1stxZazNlMMu/zlVyDVaRmt9EC/
         N2EzrC4EFhYcHcf7IwVgnu7VRjM96Brx1+u4hhK3fQhSjxQpU5c195KoncxRPh6k8q3F
         tA/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=kfvuWgds8NobdQcGReWJjBLL+2NNohkB+B2DAZ7kWDs=;
        b=ej/DxrVrbgDpa9YeOdMIgns3txyfZeF8EtpIj006DZ3/6Q3km7Y1EEwWcNP9cu66/g
         YQCIinbdTggJCBRr9UOtcv/HsAXCPf3K6/M69wJiaU3qmPK6WUlcHqPvhUNylTh2R4m8
         bHrG/n37BB1aBELxiQlbmAcysJunmFnbKE6QqVlPj4cYihbxTSI3UZrhakECyhxb14yY
         oEb0BBowFWk1XPHkaPxB1kZksQ11IygAUcs7Wb9dfbEJpymiUpy+j9GI+uRXD333fxCX
         6cP/o/4noy83afMVsFWOJd+xldthoTGEcIoKHYulGOCXOeb4d2hfzk/aNp1AjrZAXZRh
         xOwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 18si12022718qvj.176.2019.06.20.03.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:31:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 739C36EB8E;
	Thu, 20 Jun 2019 10:31:13 +0000 (UTC)
Received: from [10.36.117.88] (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D3D54604CC;
	Thu, 20 Jun 2019 10:31:08 +0000 (UTC)
Subject: Re: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <70f3559b-2832-67eb-0715-ed9f856f6ed9@redhat.com>
Date: Thu, 20 Jun 2019 12:31:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 20 Jun 2019 10:31:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 07:52, Dan Williams wrote:
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
>  mm/sparse.c                    |   16 ++----
>  3 files changed, 81 insertions(+), 54 deletions(-)
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
> +
>  /*
>   * Reasonably generic function for adding memory.  It is
>   * expected that archs that support memory hotplug will
>   * call this function after deciding the zone to which to
>   * add the new pages.
>   */
> -int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> -		unsigned long nr_pages, struct mhp_restrictions *restrictions)
> +int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
> +		struct mhp_restrictions *restrictions)
>  {
>  	unsigned long i;
> -	int err = 0;
> -	int start_sec, end_sec;
> +	int start_sec, end_sec, err;
>  	struct vmem_altmap *altmap = restrictions->altmap;
>  
> -	/* during initialize mem_map, align hot-added range to section */
> -	start_sec = pfn_to_section_nr(phys_start_pfn);
> -	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> -
>  	if (altmap) {
>  		/*
>  		 * Validate altmap is within bounds of the total request
>  		 */
> -		if (altmap->base_pfn != phys_start_pfn
> +		if (altmap->base_pfn != pfn
>  				|| vmem_altmap_offset(altmap) > nr_pages) {
>  			pr_warn_once("memory add fail, invalid altmap\n");
> -			err = -EINVAL;
> -			goto out;
> +			return -EINVAL;
>  		}
>  		altmap->alloc = 0;
>  	}
>  
> +	err = check_pfn_span(pfn, nr_pages, "add");
> +	if (err)
> +		return err;
> +
> +	start_sec = pfn_to_section_nr(pfn);
> +	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
>  	for (i = start_sec; i <= end_sec; i++) {
> -		err = __add_section(nid, section_nr_to_pfn(i), altmap);
> +		unsigned long pfns;
> +
> +		pfns = min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK));
> +		err = __add_section(nid, pfn, pfns, altmap);
> +		pfn += pfns;
> +		nr_pages -= pfns;
>  
>  		/*
>  		 * EEXIST is finally dealt with by ioresource collision
> @@ -309,7 +342,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  		cond_resched();
>  	}
>  	vmemmap_populate_print_last();
> -out:
>  	return err;
>  }
>  
> @@ -487,10 +519,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
>  	pgdat->node_spanned_pages = 0;
>  }
>  
> -static void __remove_zone(struct zone *zone, unsigned long start_pfn)
> +static void __remove_zone(struct zone *zone, unsigned long start_pfn,
> +		unsigned long nr_pages)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
> -	int nr_pages = PAGES_PER_SECTION;
>  	unsigned long flags;
>  
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
> @@ -499,27 +531,23 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>  }
>  
> -static void __remove_section(struct zone *zone, struct mem_section *ms,
> -			     unsigned long map_offset,
> -			     struct vmem_altmap *altmap)
> +static void __remove_section(struct zone *zone, unsigned long pfn,
> +		unsigned long nr_pages, unsigned long map_offset,
> +		struct vmem_altmap *altmap)
>  {
> -	unsigned long start_pfn;
> -	int scn_nr;
> +	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
>  
>  	if (WARN_ON_ONCE(!valid_section(ms)))
>  		return;
>  
> -	scn_nr = __section_nr(ms);
> -	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
> -	__remove_zone(zone, start_pfn);
> -
> -	sparse_remove_one_section(ms, map_offset, altmap);
> +	__remove_zone(zone, pfn, nr_pages);
> +	sparse_remove_one_section(ms, pfn, nr_pages, map_offset, altmap);
>  }
>  
>  /**
>   * __remove_pages() - remove sections of pages from a zone
>   * @zone: zone from which pages need to be removed
> - * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
> + * @pfn: starting pageframe (must be aligned to start of a section)
>   * @nr_pages: number of pages to remove (must be multiple of section size)
>   * @altmap: alternative device page map or %NULL if default memmap is used
>   *
> @@ -528,31 +556,31 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
>   * sure that pages are marked reserved and zones are adjust properly by
>   * calling offline_pages().
>   */
> -void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> +void __remove_pages(struct zone *zone, unsigned long pfn,
>  		    unsigned long nr_pages, struct vmem_altmap *altmap)
>  {
> -	unsigned long i;
>  	unsigned long map_offset = 0;
> -	int sections_to_remove;
> +	int i, start_sec, end_sec;

As mentioned in v9, use "unsigned long" for start_sec and end_sec please.

-- 

Thanks,

David / dhildenb

