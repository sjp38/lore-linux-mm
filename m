Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8512C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 11:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85E432075E
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 11:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85E432075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30EE06B0003; Fri,  3 May 2019 07:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BF586B0005; Fri,  3 May 2019 07:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AEB66B0007; Fri,  3 May 2019 07:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFB1D6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 07:00:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so2393888edi.20
        for <linux-mm@kvack.org>; Fri, 03 May 2019 04:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6x37b0I8Rxe8Q7s4Zid/ePUHTH+3u9HDNCZ72lMlPw4=;
        b=Sd210MXlWTDLMFDPW6RjTKvOWSV8e4boaTPngvUjzmqRHE2LJxWexa4qqTojKMr5QL
         +ajSnw1EGfzazqZhZ2hfchKyc7JBXa7pZxE0Fc/QWPZWBh9Ysdg7KW94DiIlKj0pc3tB
         7yW7pTEtfZA1PopTKokVkb3AaSMcWsaABbUzvpRs2cBdP9SqALymnxwyRm9czXvXF3Ea
         2Izdnhl03gLIW2LnzEhd6djcK5FD3ypr3fgM9SQBbcphGPVyxktOjgUfOTire7+d0mZd
         1Z8i4/MhZoT4SQUflFXxYg727r1u7J/zJHCh33IkbRBSGnfIWn43tvGMnXeSb7zYfMYL
         pYAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWB3QdHAPVxHsB1Cdmp34Ltgg7VrLnbYzrYhJX1CpWGOKAEUnX9
	7NE42rD0f0BcdPY+i07XS3HsrEtiy1gHed+uxOc6LxjPd4AcwJiiTr/u5CfAjeT+4SC/0x4yJbO
	Yxuh2wldxxUldy7ygF+BmNhPn6TSJuxM1tzh79/UwrfvCnLp5jKU0PuqZ7lgjJNYN2A==
X-Received: by 2002:a50:8877:: with SMTP id c52mr4988549edc.253.1556881224307;
        Fri, 03 May 2019 04:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXui4f7iLtAVYbrn0uXgXXlTwbbvTmjK3ewh485JPzBmlrGhDCZlsqk5Q8nrMKoMwZQRve
X-Received: by 2002:a50:8877:: with SMTP id c52mr4988419edc.253.1556881223264;
        Fri, 03 May 2019 04:00:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556881223; cv=none;
        d=google.com; s=arc-20160816;
        b=r6X491z9iszAi7RQ3RHOroHoX2mddcJQRXljOo8ut7cPbYC1dEnjNIzk/vbAIy+UsZ
         MFQ8zzXIiu/rY0U8oUV2ft0RpW1JJSqiRmy1w8xFIRG+JUjMi6vuAJ7oNXZP4h9vbqBl
         zLxwm6cvIcLhbq9x/VfkiSrKRKDqGQ7GTv3TNosIqeKmOd8wv0tJvnYpocBxCJho9szV
         gfbPIhWJRUDYeAiOrXbbqm5nCbNmoo7JpniMSSeqKoDQHNaG0XzFMWcp4g1wpai2V5mZ
         EvwddIA4TcuN0pFeuDst0Kisyu4KmuWd9ZAsFyEJGPdjo5ZnE3TtJW1jHaFl7b/wICb9
         36+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6x37b0I8Rxe8Q7s4Zid/ePUHTH+3u9HDNCZ72lMlPw4=;
        b=je0khSSxoVcRM4e1o6rbzWuUGlVQ5ygIFFTJj/tBQOl96O6qKs7r7M8cjLVQqoi/iq
         FM05o0FySDHUcgDZeNsuVX7vN8wfnBRdwH4DrDHaaDsjmszWho2tyceZhLidEb6pBcHo
         h8u3kfHrrcIxudppTheGWBExXJj1ufzJbiNBtSUhV7/JhLa8moS4NbrOc4VJ7cE2FJTO
         DODmfBc7LQdRekGv/KYpG7dMFl2fM52TPW70prbGdCI+l+MU32x2/sLcDj+n41H0rv5D
         /sv0tm+S3JUeDtbaHpHypxAiBRNHgBUfCuNWXH0sF9D6bEKlKhVZrxipeUKHQXPJyizN
         S2VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h21si1346798edj.48.2019.05.03.04.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 04:00:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 973F9AEDB;
	Fri,  3 May 2019 11:00:22 +0000 (UTC)
Date: Fri, 3 May 2019 13:00:19 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 08/12] mm/sparsemem: Prepare for sub-section ranges
Message-ID: <20190503110019.GG15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677656509.2336373.4432941742094481750.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677656509.2336373.4432941742094481750.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:56:05PM -0700, Dan Williams wrote:
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
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/memory_hotplug.h |    7 +-
>  mm/memory_hotplug.c            |  118 +++++++++++++++++++++++++---------------
>  mm/sparse.c                    |    7 +-
>  3 files changed, 83 insertions(+), 49 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ae892eef8b82..835a94650ee3 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -354,9 +354,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> -				  struct vmem_altmap *altmap);
> -extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
> +extern int sparse_add_section(int nid, unsigned long pfn,
> +		unsigned long nr_pages, struct vmem_altmap *altmap);
> +extern void sparse_remove_section(struct zone *zone, struct mem_section *ms,
> +		unsigned long pfn, unsigned long nr_pages,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
>  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
>  					  unsigned long pnum);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 108380e20d8f..9f73332af910 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -251,22 +251,44 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>  }
>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>  
> -static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> -		struct vmem_altmap *altmap, bool want_memblock)
> +static int __meminit __add_section(int nid, unsigned long pfn,
> +		unsigned long nr_pages,	struct vmem_altmap *altmap,
> +		bool want_memblock)
>  {
>  	int ret;
>  
> -	if (pfn_valid(phys_start_pfn))
> +	if (pfn_valid(pfn))
>  		return -EEXIST;
>  
> -	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> +	ret = sparse_add_section(nid, pfn, nr_pages, altmap);
>  	if (ret < 0)
>  		return ret;
>  
>  	if (!want_memblock)
>  		return 0;
>  
> -	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
> +	return hotplug_memory_register(nid, __pfn_to_section(pfn));
> +}
> +
> +static int subsection_check(unsigned long pfn, unsigned long nr_pages,
> +		unsigned long flags, const char *reason)
> +{
> +	/*
> +	 * Only allow partial section hotplug for !memblock ranges,
> +	 * since register_new_memory() requires section alignment, and

What is register_new_memory?

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

