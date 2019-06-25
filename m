Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0A1C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 791E3205ED
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:31:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 791E3205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E9D36B0003; Tue, 25 Jun 2019 04:31:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19B0D8E0003; Tue, 25 Jun 2019 04:31:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03C3F8E0002; Tue, 25 Jun 2019 04:31:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D74E26B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:31:21 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o16so20035445qtj.6
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:31:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=4Ctd7KD/iBnYNzY9KdzgQP7nZqWhPzjPMroZgv8LNMY=;
        b=ABAAGsM7n945MA3B4b9RdLE2vFVbaqWJgf/pOvs+eJVeS+0kPlC4V1VpFytgssYUfp
         3sFQ3qpaitY2e6HWJoLhiTEkwIIy67bIfVI/OwpMAhSXYlyMbFoejUA5eeIY8AbFXIVG
         rfN1LDWdGz3hLGTgpjLbNVl3+9S4j2hG7YF6xIe5SK9IV5R3hLEdfkqd87Exstz2SdRB
         BxCYkoZULYPK30oU1E523uRwUMXZY4SlB8Gil4g/DsqWpmQeNy0JeferO3sj/vyshxXn
         gR1OchsH+inw8k0C3amxTpjkkC2f49d9b3R0o8p4mMdEAF7+SFzOqpnn0QP1Z7PxdvCs
         qNfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHVqQ4Xu5MxV6+GNOWWACLBptXIk7IWG4vRMjw6T9rDAKW73b5
	pryBT+aiElgi8RcdGtUx6TWdB4IGWhX7+dl5K4n5Fi3+zqmZZ2JrcRS0dI42py6SlvMkI5cOPOS
	e2c7MwlAN0qs80ihowqnKoLCrcKAQA+XZU2NaXDT/eeiohBUQ/QqYY0yB0RSpfv5SkQ==
X-Received: by 2002:a37:357:: with SMTP id 84mr20367840qkd.483.1561451481610;
        Tue, 25 Jun 2019 01:31:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9S3CWRZOc+hLLRt7wnc5AoDCE8kzSF0R7GjAYdYdmOCC5vos+9CYyowlx4p2Ugc+eqW4u
X-Received: by 2002:a37:357:: with SMTP id 84mr20367797qkd.483.1561451480642;
        Tue, 25 Jun 2019 01:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561451480; cv=none;
        d=google.com; s=arc-20160816;
        b=DpvpL0owxrPUE/P1UQhya/hekCMA2YZ+1zjYUq4zfm1bQ+gak5/25xqRG7+Buge+Ca
         A7+4LQ4uTk4N3vYilRk4uy6qyP/fCT0Sqvl9qk8jtIb+awF4jqG0q210Zi2xx2jmTdve
         0fzDimzzPQIsQRVQdXlTWR5Tp5v2haTBP156FFxRtwJmMlCRADu/A7m4HO66fBM1q+Ro
         DCKHAl/KzyYD7hsJcMxsvcyZ8Uy2+NynvFX9xIbYElVrUhEHrE8kp9cSIM5tKmhhRxSO
         zMR1zQ1OzJPPL4bYJlvNyYCzCqBRqSxljnuuVIVeksbodhkSv2p7IxzPzkCckLGwVpKd
         +ccw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=4Ctd7KD/iBnYNzY9KdzgQP7nZqWhPzjPMroZgv8LNMY=;
        b=T9OmshIN7ScH2hSmtVfT34x5uqbRA7m7oR+42z4zo9wcXa4dnSeYUtVZCsxOweS8ar
         VBuSCrvNsP8R2EBjZWyR7qDV2MupYCiGoKvfWS2PdAbSZv6aX2dkLaagXGZMuKDwfR0v
         3zG1Bebr/mohSkJwXAwSXP38cGKS3YLfWsS8sUrKTAbKoNy3BQ8zhIo6F1vX0sX0VF44
         fDKRITk7rlDqzHXsn1DCErT9FIVhChnsjS9p9C4i2Hr0pAOAGoo7d6z28K3siKvneClr
         Bt0Ytj2TaBLvt38zQnd5fULSQouyZ/AHjiXrZEyFTJXr9KGBQEkJjpRpfgvKIAM+4pzC
         Crxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si10359612qvk.167.2019.06.25.01.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:31:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B3A7D36899;
	Tue, 25 Jun 2019 08:31:19 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 78B1C5C232;
	Tue, 25 Jun 2019 08:31:17 +0000 (UTC)
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a1e459fe-c48c-b888-7cf3-973fb0684509@redhat.com>
Date: Tue, 25 Jun 2019 10:31:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-3-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 25 Jun 2019 08:31:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 09:52, Oscar Salvador wrote:
> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
> and prepares the callers that add memory to take a "flags" parameter.
> This "flags" parameter will be evaluated later on in Patch#3
> to init mhp_restrictions struct.
> 
> The callers are:
> 
> add_memory
> __add_memory
> add_memory_resource
> 
> Unfortunately, we do not have a single entry point to add memory, as depending
> on the requisites of the caller, they want to hook up in different places,
> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
> in the three callers.
> 
> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
> in the way they allocate vmemmap pages within the memory blocks.
> 
> MHP_MEMMAP_MEMBLOCK:
> 	- With this flag, we will allocate vmemmap pages in each memory block.
> 	  This means that if we hot-add a range that spans multiple memory blocks,
> 	  we will use the beginning of each memory block for the vmemmap pages.
> 	  This strategy is good for cases where the caller wants the flexiblity
> 	  to hot-remove memory in a different granularity than when it was added.
> 
> 	  E.g:
> 		We allocate a range (x,y], that spans 3 memory blocks, and given
> 		memory block size = 128MB.
> 		[memblock#0  ]
> 		[0 - 511 pfns      ] - vmemmaps for section#0
> 		[512 - 32767 pfns  ] - normal memory
> 
> 		[memblock#1 ]
> 		[32768 - 33279 pfns] - vmemmaps for section#1
> 		[33280 - 65535 pfns] - normal memory
> 
> 		[memblock#2 ]
> 		[65536 - 66047 pfns] - vmemmap for section#2
> 		[66048 - 98304 pfns] - normal memory
> 
> MHP_MEMMAP_DEVICE:
> 	- With this flag, we will store all vmemmap pages at the beginning of
> 	  hot-added memory.
> 
> 	  E.g:
> 		We allocate a range (x,y], that spans 3 memory blocks, and given
> 		memory block size = 128MB.
> 		[memblock #0 ]
> 		[0 - 1533 pfns    ] - vmemmap for section#{0-2}
> 		[1534 - 98304 pfns] - normal memory
> 
> When using larger memory blocks (1GB or 2GB), the principle is the same.
> 
> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
> memory.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/acpi/acpi_memhotplug.c |  2 +-
>  drivers/base/memory.c          |  2 +-
>  drivers/dax/kmem.c             |  2 +-
>  drivers/hv/hv_balloon.c        |  2 +-
>  drivers/s390/char/sclp_cmd.c   |  2 +-
>  drivers/xen/balloon.c          |  2 +-
>  include/linux/memory_hotplug.h | 22 +++++++++++++++++++---
>  mm/memory_hotplug.c            | 10 +++++-----
>  8 files changed, 30 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index db013dc21c02..860f84e82dd0 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -218,7 +218,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>  		if (node < 0)
>  			node = memory_add_physaddr_to_nid(info->start_addr);
>  
> -		result = __add_memory(node, info->start_addr, info->length);
> +		result = __add_memory(node, info->start_addr, info->length, 0);
>  
>  		/*
>  		 * If the memory block has been used by the kernel, add_memory()
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 07ba731beb42..ad9834b8b7f7 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -516,7 +516,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = __add_memory(nid, phys_addr,
> -			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> +			   MIN_MEMORY_BLOCK_SIZE * sections_per_block, 0);
>  
>  	if (ret)
>  		goto out;
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 3d0a7e702c94..e159184e0ba0 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -65,7 +65,7 @@ int dev_dax_kmem_probe(struct device *dev)
>  	new_res->flags = IORESOURCE_SYSTEM_RAM;
>  	new_res->name = dev_name(dev);
>  
> -	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
> +	rc = add_memory(numa_node, new_res->start, resource_size(new_res), 0);
>  	if (rc) {
>  		release_resource(new_res);
>  		kfree(new_res);
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 6fb4ea5f0304..beb92bc56186 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -731,7 +731,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  
>  		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
>  		ret = add_memory(nid, PFN_PHYS((start_pfn)),
> -				(HA_CHUNK << PAGE_SHIFT));
> +				(HA_CHUNK << PAGE_SHIFT), 0);
>  
>  		if (ret) {
>  			pr_err("hot_add memory failed error is %d\n", ret);
> diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
> index 37d42de06079..f61026c7db7e 100644
> --- a/drivers/s390/char/sclp_cmd.c
> +++ b/drivers/s390/char/sclp_cmd.c
> @@ -406,7 +406,7 @@ static void __init add_memory_merged(u16 rn)
>  	if (!size)
>  		goto skip_add;
>  	for (addr = start; addr < start + size; addr += block_size)
> -		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
> +		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size, 0);
>  skip_add:
>  	first_rn = rn;
>  	num = 1;
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 37a36c6b9f93..33814b3513ca 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -349,7 +349,7 @@ static enum bp_state reserve_additional_memory(void)
>  	mutex_unlock(&balloon_mutex);
>  	/* add_memory_resource() requires the device_hotplug lock */
>  	lock_device_hotplug();
> -	rc = add_memory_resource(nid, resource);
> +	rc = add_memory_resource(nid, resource, 0);
>  	unlock_device_hotplug();
>  	mutex_lock(&balloon_mutex);
>  
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 0b8a5e5ef2da..6fdbce9d04f9 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -54,6 +54,22 @@ enum {
>  };
>  
>  /*
> + * We want memmap (struct page array) to be allocated from the hotadded range.
> + * To do so, there are two possible ways depending on what the caller wants.
> + * 1) Allocate memmap pages per device (whole hot-added range)
> + * 2) Allocate memmap pages per memblock
> + * The former implies that we wil use the beginning of the hot-added range

s/wil/will/

> + * to store the memmap pages of the whole range, while the latter implies
> + * that we will use the beginning of each memblock to store its own memmap
> + * pages.
> + * Please note that only SPARSE_VMEMMAP implements this feature and some
> + * architectures might not support it even for that memory model (e.g. s390)

Probably rephrase to "This is only a hint, not a guarantee. Only
selected architectures support it with SPARSE_VMEMMAP."

> + */
> +#define MHP_MEMMAP_DEVICE	(1UL<<0)
> +#define MHP_MEMMAP_MEMBLOCK	(1UL<<1)
> +#define MHP_VMEMMAP_FLAGS	(MHP_MEMMAP_DEVICE|MHP_MEMMAP_MEMBLOCK)
> +
> +/*
>   * Restrictions for the memory hotplug:
>   * flags:  MHP_ flags
>   * altmap: alternative allocator for memmap array
> @@ -342,9 +358,9 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
>  extern void __ref free_area_init_core_hotplug(int nid);
>  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>  		void *arg, int (*func)(struct memory_block *, void *));
> -extern int __add_memory(int nid, u64 start, u64 size);
> -extern int add_memory(int nid, u64 start, u64 size);
> -extern int add_memory_resource(int nid, struct resource *resource);
> +extern int __add_memory(int nid, u64 start, u64 size, unsigned long flags);
> +extern int add_memory(int nid, u64 start, u64 size, unsigned long flags);
> +extern int add_memory_resource(int nid, struct resource *resource, unsigned long flags);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4e8e65954f31..e4e3baa6eaa7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1057,7 +1057,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>   *
>   * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
>   */
> -int __ref add_memory_resource(int nid, struct resource *res)
> +int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags)
>  {
>  	struct mhp_restrictions restrictions = {};
>  	u64 start, size;
> @@ -1135,7 +1135,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  }
>  
>  /* requires device_hotplug_lock, see add_memory_resource() */
> -int __ref __add_memory(int nid, u64 start, u64 size)
> +int __ref __add_memory(int nid, u64 start, u64 size, unsigned long flags)
>  {
>  	struct resource *res;
>  	int ret;
> @@ -1144,18 +1144,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
>  	if (IS_ERR(res))
>  		return PTR_ERR(res);
>  
> -	ret = add_memory_resource(nid, res);
> +	ret = add_memory_resource(nid, res, flags);
>  	if (ret < 0)
>  		release_memory_resource(res);
>  	return ret;
>  }
>  
> -int add_memory(int nid, u64 start, u64 size)
> +int add_memory(int nid, u64 start, u64 size, unsigned long flags)
>  {
>  	int rc;
>  
>  	lock_device_hotplug();
> -	rc = __add_memory(nid, start, size);
> +	rc = __add_memory(nid, start, size, flags);
>  	unlock_device_hotplug();
>  
>  	return rc;
> 

Apart from that, looks good to me.

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

