Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26F5EC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B75DC20665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:45:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B75DC20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4838E001C; Thu,  1 Aug 2019 10:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5068E0001; Thu,  1 Aug 2019 10:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16CA98E001C; Thu,  1 Aug 2019 10:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E797D8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:45:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k125so61314021qkc.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=h/BN/gGgg+qPIl3P9gbXLl+KMTTQDPsJswQHoMHIOoI=;
        b=WwaV4eWDf6NjYLpMayfAa45Rrifl3kIQVojro6TD6IKHK6pQ0SWR6jLzOOu/0tT9i3
         ZiWnobNH/x3JGE7J1Vglh0ZbqzspwLxCFTXgZJmgtIqxmFSHVO4RemMX8iIgLVfGN2FY
         /kesEgJGDGF3T2DI4Hv9gjnvRP5Frt6FXlPucBdlwdxuq/v0NGe4MF19mZEg1FF3Ff+Y
         f47x72wcOv6e/dSQ7HEaaHG3GmzJ9wjcFGsVGZoiKpynrw1xRoDIJYUMIChznYZnIYB6
         dzOXn6UNHmOcdMzMKWCXIh0Y/CDAeeaONj8Aa1jNKLDeKRu5qcaXK74HyG4Zk9zxWlZa
         uk+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVOlB9KLksbCcOw54IKAyKc4UoLyu6SETGlwNneGEJDfZudEx5c
	nznTNl4T3psLJ2MsfJZ6Rtz5xIepuHDcBml9yAd3d9PKqciVddWSqyBJSKYlxP8kGyVfrDkhNKn
	BdfuESWWThk+9WGzlTwsno8JcHiGkpXn0g5CAMatyApi5DopqlpYdn7TCIb9sIpD2vQ==
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr92194352qth.136.1564670706646;
        Thu, 01 Aug 2019 07:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlTE2jLk+TN+QzbyzVkr/dLfGcK8tO9vcyiQzrSgKV2n7/8my2Xqtm1KCLtMM9JUl1rsua
X-Received: by 2002:aed:3fb0:: with SMTP id s45mr92194290qth.136.1564670705784;
        Thu, 01 Aug 2019 07:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564670705; cv=none;
        d=google.com; s=arc-20160816;
        b=UJCkuTrW2s4bXPLFvRJdD4zUTAsp8IpwvWMufpZAmjmjLat7t0tyEBC2mqcX5/+O19
         cPlZDrTmWSvZRN3NuSamZ2hn0nl9/jikm1zovvBkUG4ublOjOiedCZRgM6aH3iMnumqs
         T9WE8K7lwBv1HKbUjQYtmi6Y4tOriWgTx51ZOytQOHslQOCi4Jj+vbQs6WZgZHKqSpAa
         mHteoyvbsn0MC/DMAdO96rVjBUw92T3k/5kW2CT+CGEZ/nw8V1qF0agyCTW/o7a1iCdy
         ITtVYp0dEzkc4h1HGKwixHLccRFvKrNI8yqihEphgZ29sPSd9/YPLpZyRFEFrWX4SThc
         8y4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=h/BN/gGgg+qPIl3P9gbXLl+KMTTQDPsJswQHoMHIOoI=;
        b=EK90fbRk9qPuMLgBYnQDBXalZVUs8Mi3AJjKiyVfmwSY6NfOhgrnbeQyRA6v74fIG7
         xFphNsCJ0bdNzMQY5ZYqZRNA6J1QcgSRrawL3DtwvRJPoeWbWctDS+a3MkzhV0UWeLjL
         hZE30WuW/KtVNnux4RPsdburZ+Bgz9VjQfSqG2p26gIPpKNMkqI+qIrp2m2sENnDf7AS
         kJLXpQTqHlitNSZRjECq5/x5xcbqMkOrCvDHnthLMchDjwsi9pIDTQmu3dnwSCnmw2Ze
         YAaUnkDJrqbk7RLbcN0ianuj2fQyTWmlNRGGqiY862cMV5gMO+jjJqbv+Rag+3I4UV7r
         hrSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n37si39643209qte.331.2019.08.01.07.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:45:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8FDD5B2DF0;
	Thu,  1 Aug 2019 14:45:04 +0000 (UTC)
Received: from [10.36.116.115] (ovpn-116-115.ams2.redhat.com [10.36.116.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3C3826012D;
	Thu,  1 Aug 2019 14:45:02 +0000 (UTC)
Subject: Re: [PATCH v3 3/5] mm,sparse: Add SECTION_USE_VMEMMAP flag
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, pasha.tatashin@soleen.com, mhocko@suse.com,
 anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-4-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <37d24c2e-093a-d377-a45d-5363c5e597a2@redhat.com>
Date: Thu, 1 Aug 2019 16:45:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725160207.19579-4-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 01 Aug 2019 14:45:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 18:02, Oscar Salvador wrote:
> When hot-removing memory, we need to be careful about two things:
> 
> 1) Memory range must be memory_block aligned. This is what
>    check_hotplug_memory_range() checks for.
> 
> 2) If a range was hot-added using MHP_MEMMAP_ON_MEMORY, we need to check
>    whether the caller is removing memory with the same granularity that
>    it was added.

The second step does only apply to MMAP_ON_MEMORY and is not universally
true.

> 
> So to check against case 2), we mark all sections used by vmemmap
> (not only the ones containing vmemmap pages, but all sections spanning
> the memory range) with SECTION_USE_VMEMMAP.

SECTION_USE_VMEMAP is misleding.

Rather SECTION_MMAP_ON_MEMORY (TBD). Please *really* add a description
(these sections)

> 
> This will allow us to do some sanity checks when in hot-remove stage.
> 

One idea: lookup the struct page of the lowest memory address you are
removing and test if it lies on a PageVmemmap(). Then, from the stored
info along the vmemmap page (start + length) you can test if all memory
the vmemmap is responsible for is removed.

This should work or am I missing something?

> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/memory_hotplug.h | 3 ++-
>  include/linux/mmzone.h         | 8 +++++++-
>  mm/memory_hotplug.c            | 2 +-
>  mm/sparse.c                    | 9 +++++++--
>  4 files changed, 17 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 45dece922d7c..6b20008d9297 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -366,7 +366,8 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern int sparse_add_section(int nid, unsigned long pfn,
> -		unsigned long nr_pages, struct vmem_altmap *altmap);
> +		unsigned long nr_pages, struct vmem_altmap *altmap,
> +		bool vmemmap_section);
>  extern void sparse_remove_section(struct mem_section *ms,
>  		unsigned long pfn, unsigned long nr_pages,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d77d717c620c..259c326962f5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1254,7 +1254,8 @@ extern size_t mem_section_usage_size(void);
>  #define SECTION_HAS_MEM_MAP	(1UL<<1)
>  #define SECTION_IS_ONLINE	(1UL<<2)
>  #define SECTION_IS_EARLY	(1UL<<3)
> -#define SECTION_MAP_LAST_BIT	(1UL<<4)
> +#define SECTION_USE_VMEMMAP	(1UL<<4)
> +#define SECTION_MAP_LAST_BIT	(1UL<<5)
>  #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
>  #define SECTION_NID_SHIFT	3
>  
> @@ -1265,6 +1266,11 @@ static inline struct page *__section_mem_map_addr(struct mem_section *section)
>  	return (struct page *)map;
>  }
>  
> +static inline int vmemmap_section(struct mem_section *section)
> +{
> +	return (section && (section->section_mem_map & SECTION_USE_VMEMMAP));
> +}
> +
>  static inline int present_section(struct mem_section *section)
>  {
>  	return (section && (section->section_mem_map & SECTION_MARKED_PRESENT));
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3d97c3711333..c2338703ce80 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -314,7 +314,7 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  
>  		pfns = min(nr_pages, PAGES_PER_SECTION
>  				- (pfn & ~PAGE_SECTION_MASK));
> -		err = sparse_add_section(nid, pfn, pfns, altmap);
> +		err = sparse_add_section(nid, pfn, pfns, altmap, 0);
>  		if (err)
>  			break;
>  		pfn += pfns;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 79355a86064f..09cac39e39d9 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -856,13 +856,18 @@ static struct page * __meminit section_activate(int nid, unsigned long pfn,
>   * * -ENOMEM	- Out of memory.
>   */
>  int __meminit sparse_add_section(int nid, unsigned long start_pfn,
> -		unsigned long nr_pages, struct vmem_altmap *altmap)
> +		unsigned long nr_pages, struct vmem_altmap *altmap,
> +		bool vmemmap_section)
>  {
>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +	unsigned long flags = 0;
>  	struct mem_section *ms;
>  	struct page *memmap;
>  	int ret;
>  
> +	if (vmemmap_section)
> +		flags = SECTION_USE_VMEMMAP;
> +
>  	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0)
>  		return ret;
> @@ -884,7 +889,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>  	/* Align memmap to section boundary in the subsection case */
>  	if (section_nr_to_pfn(section_nr) != start_pfn)
>  		memmap = pfn_to_kaddr(section_nr_to_pfn(section_nr));
> -	sparse_init_one_section(ms, section_nr, memmap, ms->usage, 0);
> +	sparse_init_one_section(ms, section_nr, memmap, ms->usage, flags);
>  
>  	return 0;
>  }
> 


-- 

Thanks,

David / dhildenb

