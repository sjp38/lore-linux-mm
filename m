Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F1B3C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E55B20882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:02:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E55B20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9C16B000A; Thu,  4 Apr 2019 11:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A66556B000C; Thu,  4 Apr 2019 11:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9077D6B000D; Thu,  4 Apr 2019 11:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6835F6B000A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:02:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v18so2518642qtk.5
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xd9j3KbiXyBuVy6weuJDj+cb1JpDyVExOQHwGpFJ+D4=;
        b=I+DMgvYblfLzx5IYQjMf3MY2CjPb1oYqmtQowS/sTXR9PzOVzwo7C7LjrVC6ErOxlJ
         Ljj2dyzww5jKyng97f7Rs5G6jfUx0A98Wmb96qEJhFlNpR/s1QePzMC9+eYqKaHdBTy1
         0XvpFx2ACp98t/CFSyanGnwGXxeJYgNF0lj0Nc040vCeCJBagjFfYtdU/0KY3+XAQb9t
         kyQ+/4RpozOeWCo4B4pOZ6wbQBllys0G2HhFBtM0IGdL7fiWNz/flXm8eMt9uk06IwNb
         zts8fYhGN54elpW7y5WYyMv7xLPJOLKIesd5cla6NT6ZH9+AcTISwWJkc2J6hmb1yk7u
         vD/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXuK4clIReHWvVj2TscMPblw+OLHqIyuQAeJVAZrchQqras077f
	LhVmJ6sqfeDbAXra9VOKZNTEXmZwxZhzabnB/deyVS+v+x1uTmeF82Ml5g7iuYgbA5EMrepNAH5
	+1xDbaxHX3W3wzRVfgF7Ukxg2KGntZqFfFuFTuin5wdb1KWcOua+GK+ewUEOsqXzVkQ==
X-Received: by 2002:a0c:9ac8:: with SMTP id k8mr5208581qvf.132.1554390176137;
        Thu, 04 Apr 2019 08:02:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXFaJAsFzcPG7bfKp8gewwH3iZDmQls07QuA3UvS0NqaOOFK6EWrCg2p5rP2oO+boCIgP9
X-Received: by 2002:a0c:9ac8:: with SMTP id k8mr5208421qvf.132.1554390174588;
        Thu, 04 Apr 2019 08:02:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554390174; cv=none;
        d=google.com; s=arc-20160816;
        b=k3tp6awUMZMqL/nYhyZN4RLA7AsfeaXEpYLDV5v7xFVk7UIJIkhurnqXUx02uJLYZ4
         66hzAPSoll5DYoYKN1HNhRHcbNzRZoAo7zccMO4WURToJ34SeOlSwz5eXou7ft8fhHVV
         X0fgHl3NuRmdmUg6s/9Rihgpyn7XRWQJ8c+sXMcBiAJAsRMtSsVMK2vgrM3tBfBBHm6Q
         uVAarfCzH9g9W2DQOa8GV14KkRBNq8GORDtTyVAt+kodDbHsth3kwkOso/nv3eLXt3w2
         zrhGik5l3bxr1qe1yLfA4ueDkWpAmHgKK3tNaxJI2zCbk9k12xGFaJWGz3/k2VYGgESe
         HdCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=xd9j3KbiXyBuVy6weuJDj+cb1JpDyVExOQHwGpFJ+D4=;
        b=BkWH0iX61M+CMaWjBZpWX0aVWv2ZPzGdvy2LPhQTmLVEayEoYrT5ps4/by5mP7AStf
         gH01+OJUEBAIPVSPLzk4iRWXhHyWUm9pl80ic38Wi0SCXRvOUF0/hRkvO7YF83Lr6yy6
         IOnsJhEltkz7fwJ9sxU+WpzqigOeQvyEHOf8K2Grin+Ahd1KjYCq8705wIaQzaN0j1Na
         ke+bMMvN6efITqTgyWZ5qK5Vvtob64RpeFfsln8oiWkeVyUhxSISqcKVE8jrkbdSk6HR
         tPP1A0tdCozhmBS8hjrADT9PTm0N/A0lgi15YXwZO01SZOd66ouozfGuBahgj0CZU0Z1
         4y+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d144si7233770qke.192.2019.04.04.08.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 08:02:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A1C713167E75;
	Thu,  4 Apr 2019 15:02:48 +0000 (UTC)
Received: from [10.36.117.116] (ovpn-117-116.ams2.redhat.com [10.36.117.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 209238681A;
	Thu,  4 Apr 2019 15:02:45 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
From: David Hildenbrand <david@redhat.com>
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <74d697b8-34e9-38da-b3c4-245bd7989f52@redhat.com>
Date: Thu, 4 Apr 2019 17:02:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 04 Apr 2019 15:02:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 16:57, David Hildenbrand wrote:
> On 04.04.19 14:59, Oscar Salvador wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> arch_add_memory, __add_pages take a want_memblock which controls whether
>> the newly added memory should get the sysfs memblock user API (e.g.
>> ZONE_DEVICE users do not want/need this interface). Some callers even
>> want to control where do we allocate the memmap from by configuring
>> altmap.
>>
>> Add a more generic hotplug context for arch_add_memory and __add_pages.
>> struct mhp_restrictions contains flags which contains additional
>> features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
>> currently) and altmap for alternative memmap allocator.
>>
>> This patch shouldn't introduce any functional change.
>>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
>> ---
>>  arch/arm64/mm/mmu.c            |  6 +++---
>>  arch/ia64/mm/init.c            |  6 +++---
>>  arch/powerpc/mm/mem.c          |  6 +++---
>>  arch/s390/mm/init.c            |  6 +++---
>>  arch/sh/mm/init.c              |  6 +++---
>>  arch/x86/mm/init_32.c          |  6 +++---
>>  arch/x86/mm/init_64.c          | 10 +++++-----
>>  include/linux/memory_hotplug.h | 29 +++++++++++++++++++++++------
>>  kernel/memremap.c              | 10 +++++++---
>>  mm/memory_hotplug.c            | 10 ++++++----
>>  10 files changed, 59 insertions(+), 36 deletions(-)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index e6acfa7be4c7..db509550329d 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -1046,8 +1046,8 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		    bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
> 
> Should the restrictions be marked const?
> 
>>  {
>>  	int flags = 0;
>>  
>> @@ -1058,6 +1058,6 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>>  			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
>>  
>>  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>> -			   altmap, want_memblock);
>> +							restrictions);
> 
> Again, some strange alignment thingies going on here :)
> 
>>  }
>>  #endif
>> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
>> index e49200e31750..379eb1f9adc9 100644
>> --- a/arch/ia64/mm/init.c
>> +++ b/arch/ia64/mm/init.c
>> @@ -666,14 +666,14 @@ mem_init (void)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  	int ret;
>>  
>> -	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  	if (ret)
>>  		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
>>  		       __func__,  ret);
>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>> index 1aa27aac73c5..76deaa8525db 100644
>> --- a/arch/powerpc/mm/mem.c
>> +++ b/arch/powerpc/mm/mem.c
>> @@ -109,8 +109,8 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
>>  	return -ENODEV;
>>  }
>>  
>> -int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int __meminit arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>> @@ -127,7 +127,7 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
>>  	}
>>  	flush_inval_dcache_range(start, start + size);
>>  
>> -	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	return __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTREMOVE
>> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>> index 25e3113091ea..f5db961ad792 100644
>> --- a/arch/s390/mm/init.c
>> +++ b/arch/s390/mm/init.c
>> @@ -216,8 +216,8 @@ device_initcall(s390_cma_mem_init);
>>  
>>  #endif /* CONFIG_CMA */
>>  
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +		struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = PFN_DOWN(start);
>>  	unsigned long size_pages = PFN_DOWN(size);
>> @@ -227,7 +227,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>>  	if (rc)
>>  		return rc;
>>  
>> -	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
>> +	rc = __add_pages(nid, start_pfn, size_pages, restrictions);
>>  	if (rc)
>>  		vmem_remove_mapping(start, size);
>>  	return rc;
>> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
>> index 8e004b2f1a6a..168d3a6b9358 100644
>> --- a/arch/sh/mm/init.c
>> +++ b/arch/sh/mm/init.c
>> @@ -404,15 +404,15 @@ void __init mem_init(void)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = PFN_DOWN(start);
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  	int ret;
>>  
>>  	/* We only have ZONE_NORMAL, so this is easy.. */
>> -	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  	if (unlikely(ret))
>>  		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
>>  
>> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
>> index 85c94f9a87f8..755dbed85531 100644
>> --- a/arch/x86/mm/init_32.c
>> +++ b/arch/x86/mm/init_32.c
>> @@ -850,13 +850,13 @@ void __init mem_init(void)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  
>> -	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	return __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTREMOVE
>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> index bccff68e3267..db42c11b48fb 100644
>> --- a/arch/x86/mm/init_64.c
>> +++ b/arch/x86/mm/init_64.c
>> @@ -777,11 +777,11 @@ static void update_end_of_memory_vars(u64 start, u64 size)
>>  }
>>  
>>  int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>> -		struct vmem_altmap *altmap, bool want_memblock)
>> +				struct mhp_restrictions *restrictions)
>>  {
>>  	int ret;
>>  
>> -	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  	WARN_ON_ONCE(ret);
>>  
>>  	/* update max_pfn, max_low_pfn and high_memory */
>> @@ -791,15 +791,15 @@ int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>>  	return ret;
>>  }
>>  
>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +int arch_add_memory(int nid, u64 start, u64 size,
>> +			struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  
>>  	init_memory_mapping(start, start + size);
>>  
>> -	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	return add_pages(nid, start_pfn, nr_pages, restrictions);
>>  }
>>  
>>  #define PAGE_INUSE 0xFD
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index 3c8cf347804c..5bd4b56f639c 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -118,20 +118,37 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>>  	unsigned long nr_pages, struct vmem_altmap *altmap);
>>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>>  
>> +/*
>> + * Do we want sysfs memblock files created. This will allow userspace to online
>> + * and offline memory explicitly. Lack of this bit means that the caller has to
>> + * call move_pfn_range_to_zone to finish the initialization.
>> + */
> 
> I think you can be more precise here.
> 
> "Create memory block devices for added pages. This is usually the case
> for all system ram (and only system ram), as only this way memory can be
> onlined/offlined by user space and kdump to correctly detect the new
> memory using udev events."
> 
> Maybe we should even go a step further and call this
> 
> MHP_SYSTEM_RAM
> 
> Because that is what it is right now.
> 
>> +
>> +#define MHP_MEMBLOCK_API               (1<<0)
>> +
>> +/*
>> + * Restrictions for the memory hotplug:
>> + * flags:  MHP_ flags
>> + * altmap: alternative allocator for memmap array
>> + */
>> +struct mhp_restrictions {
>> +	unsigned long flags;
>> +	struct vmem_altmap *altmap;
>> +};
>> +
>>  /* reasonably generic interface to expand the physical pages */
>>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>> -		struct vmem_altmap *altmap, bool want_memblock);
>> +					struct mhp_restrictions *restrictions);
>>  
>>  #ifndef CONFIG_ARCH_HAS_ADD_PAGES
>>  static inline int add_pages(int nid, unsigned long start_pfn,
>> -		unsigned long nr_pages, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +		unsigned long nr_pages, struct mhp_restrictions *restrictions)
>>  {
>> -	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
>> +	return __add_pages(nid, start_pfn, nr_pages, restrictions);
>>  }
>>  #else /* ARCH_HAS_ADD_PAGES */
>>  int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>> -		struct vmem_altmap *altmap, bool want_memblock);
>> +				struct mhp_restrictions *restrictions);
> 
> dito alignment. You have tabs configured to 8 characters, right?
> 
>>  #endif /* ARCH_HAS_ADD_PAGES */
>>  
>>  #ifdef CONFIG_NUMA
>> @@ -333,7 +350,7 @@ extern int __add_memory(int nid, u64 start, u64 size);
>>  extern int add_memory(int nid, u64 start, u64 size);
>>  extern int add_memory_resource(int nid, struct resource *resource);
>>  extern int arch_add_memory(int nid, u64 start, u64 size,
>> -		struct vmem_altmap *altmap, bool want_memblock);
>> +			struct mhp_restrictions *restrictions);
>>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>>  extern bool is_memblock_offlined(struct memory_block *mem);
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index a856cb5ff192..cc5e3e34417d 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -149,6 +149,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  	struct resource *res = &pgmap->res;
>>  	struct dev_pagemap *conflict_pgmap;
>>  	pgprot_t pgprot = PAGE_KERNEL;
>> +	struct mhp_restrictions restrictions = {};
>>  	int error, nid, is_ram;
>>  
>>  	if (!pgmap->ref || !pgmap->kill)
>> @@ -199,6 +200,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  	if (error)
>>  		goto err_pfn_remap;
>>  
>> +	/* We do not want any optional features only our own memmap */
>> +	restrictions.altmap = altmap;
>> +>  	mem_hotplug_begin();
>>  
>>  	/*
>> @@ -214,7 +218,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  	 */
>>  	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
>>  		error = add_pages(nid, align_start >> PAGE_SHIFT,
>> -				align_size >> PAGE_SHIFT, NULL, false);
>> +				align_size >> PAGE_SHIFT, &restrictions);
>>  	} else {
>>  		error = kasan_add_zero_shadow(__va(align_start), align_size);
>>  		if (error) {
>> @@ -222,8 +226,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  			goto err_kasan;
>>  		}
>>  
>> -		error = arch_add_memory(nid, align_start, align_size, altmap,
>> -				false);
>> +		error = arch_add_memory(nid, align_start, align_size,
>> +							&restrictions);
> 
> dito alignment
> 
>>  	}
>>  
>>  	if (!error) {
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index d8a3e9554aec..50f77e059457 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -274,12 +274,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>>   * add the new pages.
>>   */
>>  int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>> -		unsigned long nr_pages, struct vmem_altmap *altmap,
>> -		bool want_memblock)
>> +		unsigned long nr_pages, struct mhp_restrictions *restrictions)
>>  {
>>  	unsigned long i;
>>  	int err = 0;
>>  	int start_sec, end_sec;
>> +	struct vmem_altmap *altmap = restrictions->altmap;
>>  
>>  	/* during initialize mem_map, align hot-added range to section */
>>  	start_sec = pfn_to_section_nr(phys_start_pfn);
>> @@ -300,7 +300,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>  
>>  	for (i = start_sec; i <= end_sec; i++) {
>>  		err = __add_section(nid, section_nr_to_pfn(i), altmap,
>> -				want_memblock);
>> +				restrictions->flags & MHP_MEMBLOCK_API);
>>  
>>  		/*
>>  		 * EEXIST is finally dealt with by ioresource collision
>> @@ -1102,6 +1102,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>  	u64 start, size;
>>  	bool new_node = false;
>>  	int ret;
>> +	struct mhp_restrictions restrictions = {};
> 
> I'd make this the very first variable.
> 
> Also eventually
> 
> struct mhp_restrictions restrictions = {
> 	.restrictions = MHP_MEMBLOCK_API
> };
> 
>>  
>>  	start = res->start;
>>  	size = resource_size(res);
>> @@ -1126,7 +1127,8 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>  	new_node = ret;
>>  
>>  	/* call arch's memory hotadd */
>> -	ret = arch_add_memory(nid, start, size, NULL, true);
>> +	restrictions.flags = MHP_MEMBLOCK_API;
>> +	ret = arch_add_memory(nid, start, size, &restrictions);
>>  	if (ret < 0)
>>  		goto error;
>>  
>>
> 
> 

s/alignment/indentation/

I think I should take a nap :)

-- 

Thanks,

David / dhildenb

