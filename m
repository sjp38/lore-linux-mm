Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D75CCC282E0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:09:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F8521736
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:09:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="naKeu+d4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F8521736
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 228D36B0003; Fri, 19 Apr 2019 19:09:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B0B46B0006; Fri, 19 Apr 2019 19:09:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 051526B0007; Fri, 19 Apr 2019 19:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3A86B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 19:09:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so4295678pfa.0
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:09:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=LsXD0klpMTgpZM/8Qdv7cRMawphkfxNMAjiWA9I1AKk=;
        b=NA9zaoUqughRLnJoOG1wDtMH1LaVA9L8+FMYbViu9ZUW4ELFCamCVjZG9ekDIr/pe6
         tf0VM/Rhroxw2h6CCIrU3IJhBVt7iuLhZt5i1e47ELkME8yivzD/btsb+B/6V7WyP+0r
         nqMAE1/RfMTneXziA6HR/8HSlHDuY+pEgRg7HWkfayzXwJEEH1U37x0IZ9m+/rc5M0BA
         ZTP58l+99k8bURpQzZhg9GK2asuAn/sNH5AS7e5iHoS5fFACMsz5lK+44S7eTmnWZqn3
         fPTEMl6GSprQpGcRUnnAMwMaccvgcQD7wqJe4pEpiARAA2g8+nG54I88BSkIY+rR6Xj2
         LLXQ==
X-Gm-Message-State: APjAAAW1GXt8pHqtAiSm2Lg+XLGWofDv+2xTxdW1DhLVMmVcbQWd1wWh
	tHOgYQZHefOoTmmw4FEuU0vUjBH64em4y0BoR3dkAX7T+KVFvh9JpeEpTtVOmnJ29iEyK7hc8TO
	LjXbPupT+VBdzGnsX1t1/ICttyoFnQ+SfV1wpSjYkmJRLCHqPFydfrf2aKHxuGSbbTQ==
X-Received: by 2002:a63:5c53:: with SMTP id n19mr6389893pgm.193.1555715393288;
        Fri, 19 Apr 2019 16:09:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkSIKL4SmMw0ob+9MWDVzH9yCm//kO6ycxZsZQPt2WsnG7HkML0RujedOjhmBiezWe4UN2
X-Received: by 2002:a63:5c53:: with SMTP id n19mr6389852pgm.193.1555715392535;
        Fri, 19 Apr 2019 16:09:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555715392; cv=none;
        d=google.com; s=arc-20160816;
        b=GSFD+34QPf24oXSNxdz4UDrCgjODi5ZEdr7KB4HJ6sP8Zywg2Roza04fSe8N3gOfNV
         iAqpZEnoLkn2NcBfiJRKp0YLp4cagrXo91uSu+jfWrRBlq4qDU5Db6vdIAywyG8dYhF2
         rXhJJ0NzpPQt4z9815YR3T7ndRoM6cP7rTmAkGzAJBapTKwooO6YmtxJpYxMt4AKKnX0
         yiSRL4JoN8JzqBZWU5+gIlMI8wWN7EwKGAPg7eafYqNYSSKL/EL65oPD+0Nfl95brN02
         qc9N4tvEYQbXCCBNVJyROSZsDPd8YMCEcD+/N90dZhAIuSjCwAKReZtATZnQaZSPH9+W
         H57w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=LsXD0klpMTgpZM/8Qdv7cRMawphkfxNMAjiWA9I1AKk=;
        b=0NwfGoGfCNyI/waKj5X0gUZMOhRPHiV0Mq/ahb8p/v8CTnTRma6GZAy3GBhNihbdRm
         0lzk7rY1tG7gu1BJLXy4DBHoVbAjuZ1npz+kMrQzwUUhjrYsba+/EqGACcE4q7TZRq6x
         IlnV0A0ot+PBi1rNGTUsAAkGqR6sPK/MxEFwl13csEvcAKBlKnVSwuhjm97Uo6b/GFC4
         y3T/fIeSMToAJiWTyQ3GmpYvFreG3frZoaHtTuy5aVsfvguVMXa6Cx/0d4BuSQA7+eWH
         bYgMr2StqMGtnj9k9vqMHkMnh5Wf8BBZMh0KgLPaJ0B+dnBX58JRUm6Q+SZ428wxxdt8
         gBDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=naKeu+d4;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id p14si6467679pfn.267.2019.04.19.16.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 16:09:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=naKeu+d4;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cba55290000>; Fri, 19 Apr 2019 16:09:29 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Apr 2019 16:09:51 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Apr 2019 16:09:51 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Apr
 2019 23:09:51 +0000
Subject: Re: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
To: Dan Williams <dan.j.williams@intel.com>, <akpm@linux-foundation.org>
CC: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, <linux-mm@kvack.org>,
	<linux-nvdimm@lists.01.org>, <linux-kernel@vger.kernel.org>,
	<david@redhat.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <001f15a6-26bb-cbab-587f-d897b2dc9094@nvidia.com>
Date: Fri, 19 Apr 2019 16:09:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555715370; bh=LsXD0klpMTgpZM/8Qdv7cRMawphkfxNMAjiWA9I1AKk=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=naKeu+d4gLKnO5C+DmaZOCySBAoJ8cnyIa7Zr53HUzI9uYduIhZ1k2Arw1neNJcdn
	 aR+9Tv/IC6YDMK/wVL9YN1vtgnb0vP9YXGs5ivCcr/3cbfnKeMHGteKPNTpi58wYbB
	 ipGbxXkNE7Gt0GK5OYE40P0YsZMCe2FrS7HQZB79Dj3cyL1cU/PA2Z1sJQFa3dX4wE
	 bd2gwNrqZveXL7PvMzhmlhH1VhC/W/NTxXIbhBgI+iQ9pGqcELanGfC31bknXs/rGX
	 wBxEJxxe4sKIxV9tYKJQqCceUIq9hxLGhbm4+NYeiVn7J8LWXu6zC/iPCTWpPy7Ndp
	 V67k15WSlznHg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just noticed this by inspection.
I can't say I'm very familiar with the code.

On 4/17/19 11:39 AM, Dan Williams wrote:
> Sub-section hotplug support reduces the unit of operation of hotplug
> from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
> (PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
> PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
> valid_section(), can toggle.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>   include/linux/mmzone.h |    2 ++
>   mm/memory_hotplug.c    |   16 ++++++++--------
>   2 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index cffde898e345..b13f0cddf75e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1164,6 +1164,8 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
>   
>   #define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
>   #define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
> +#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
> +#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
>   
>   struct mem_section_usage {
>   	/*
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8b7415736d21..d5874f9d4043 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -327,10 +327,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>   {
>   	struct mem_section *ms;
>   
> -	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
> +	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUB_SECTION) {
>   		ms = __pfn_to_section(start_pfn);
>   
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(start_pfn)))
>   			continue;

Note that "struct mem_section *ms;" is now set but not used.
You can remove the definition and initialization of "ms".

>   		if (unlikely(pfn_to_nid(start_pfn) != nid))
> @@ -355,10 +355,10 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>   
>   	/* pfn is the end pfn of a memory section. */
>   	pfn = end_pfn - 1;
> -	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
> +	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUB_SECTION) {
>   		ms = __pfn_to_section(pfn);
>   
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(pfn)))
>   			continue;

Ditto about "ms".

>   		if (unlikely(pfn_to_nid(pfn) != nid))
> @@ -417,10 +417,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>   	 * it check the zone has only hole or not.
>   	 */
>   	pfn = zone_start_pfn;
> -	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
> +	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
>   		ms = __pfn_to_section(pfn);
>   
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(pfn)))
>   			continue;

Ditto about "ms".

>   		if (page_zone(pfn_to_page(pfn)) != zone)
> @@ -485,10 +485,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
>   	 * has only hole or not.
>   	 */
>   	pfn = pgdat_start_pfn;
> -	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
> +	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
>   		ms = __pfn_to_section(pfn);
>   
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(pfn)))
>   			continue;

Ditto about "ms".

>   		if (pfn_to_nid(pfn) != nid)
> 

