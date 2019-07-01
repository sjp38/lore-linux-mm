Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75088C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:41:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DB45208C4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:41:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DB45208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C9AB6B0003; Mon,  1 Jul 2019 04:41:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6539B8E0003; Mon,  1 Jul 2019 04:41:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F41E8E0002; Mon,  1 Jul 2019 04:41:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id F025B6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:41:33 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id s5so16395722eda.10
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:41:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OiZUqWT15Au5ZioWEp/SCDBoSRFm+rralvsbzfTgHxw=;
        b=Kj4Zhk6cKWSOx9C+6P68DMlY3CGteXYp/PMVgCyq2mEoOkEJOf28Jse0BuIr9Km2xZ
         JlMw8zFIL0XWSlyUupWdd53W6/KkpPJTE5c7TA9/oKpBRoTPmHGZhjYuwPPysQTxSEWu
         ZuUDJt/2EZxE2IsS8/r9+uv/3VxnRd4F6h965mkiTNb1vJhtX5WHE4VEHJpXNRqYO6k/
         KVN9L9p4c10gcMmMxKcPLUkTBBlrraw3asXBsPgo3zJQxtMoZSnMNdYetvC21OeG84yL
         4paY66q4Qpmq2dYaD7pkIXoM5TWpwMh+r6o5GbyPn1ftkgCAbzcAvJg8cp67YFQX6iML
         6HBw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX35OYGaojmKdSP+4aPEau5vtAZ/Jc+UeMkkUcvLJjo+ZeObwnW
	IkmYl7ZqQGQiLRs2tsG/vP23h5GM2wIzRRJWjPLAeZpwD7lfCEakapkbwKYwW6x5+9Icvm4jWNi
	plfifTtkBNaLuVt78VIG+vi/cr9job2Rfq8mSOhCrC44OufzCjQqhTQ5Z70JM098=
X-Received: by 2002:a50:b803:: with SMTP id j3mr26995487ede.208.1561970493429;
        Mon, 01 Jul 2019 01:41:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx79kpup1axfNnHLIbehaDTiF1kOG2B4Z8hi54HV7QhowSZUiMb7Hhbjd7/DNHfCsha21/i
X-Received: by 2002:a50:b803:: with SMTP id j3mr26995442ede.208.1561970492665;
        Mon, 01 Jul 2019 01:41:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561970492; cv=none;
        d=google.com; s=arc-20160816;
        b=q5MTwNcc14XK2eq5Xu9MCx7NOP3tFv3x7FkKE+idGA8O+sLXAxq2Kpo5x0FKzsXXbq
         iTTB68ZkI4NTPtei97msDwRhzkn63Dzx8mL4aOrB82DYeL9GbM4cNNHxmfSeYVAvsHIF
         PoU3MvMFYMMYLnWfYKwkQDBgRwy7ch550ABULxdiVD/Yz92M4mfwjkFKixp+E0x9QKmD
         BQ8uCteTRM6RmRcTk60gl74tTS5qr2dn5++/m+nQNENasijM+hqF37t7DfFjTy69HE0o
         T6vG8Yr2mi481uv+lpRq58L3yULMnDtO46bmh1XUsdyegggcDLPkVMel7EuA4KFBy5Ev
         65EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OiZUqWT15Au5ZioWEp/SCDBoSRFm+rralvsbzfTgHxw=;
        b=xavZqNkC+oRtGa6c2ICmm+9an6w/lZobM6pCVOxC6tko9U8HTqTBDx0UV15rTRBKVz
         iMIEhD1dDRqxWBm3s2k7Y6NJChxX32LIAstEf4KMirbgltLtZ0iFY0X2ZSfY92ogT2Lm
         TI3CCSGNSN21W0YGE8euRupW2k8pF/tTEaTEOPtNq8hN0y2iPorYkUnT3QsJGCv01dff
         1GQoKj99dEV6as4T3X0BJktvtmIRmUrM8TMQT3I4/C5R1k6e3cPMRm6V5m9W/bzImxLl
         N7+1dr+taAiUlHX4auAiTHCo7yAp4mpF3Zj0d2FQxP9XNtJCaSXC0Er6DDTNb4nN3lxt
         nqiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si8861722edd.67.2019.07.01.01.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:41:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9A0E0AB7D;
	Mon,  1 Jul 2019 08:41:31 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:41:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
Message-ID: <20190701084129.GI6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-10-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:50, David Hildenbrand wrote:
> Let's factor out removing of memory block devices, which is only
> necessary for memory added via add_memory() and friends that created
> memory block devices. Remove the devices before calling
> arch_remove_memory().
> 
> This finishes factoring out memory block device handling from
> arch_add_memory() and arch_remove_memory().

OK, this makes sense again. Just a nit. Calling find_memory_block_by_id
for each memory block looks a bit suboptimal, especially when we are
removing consequent physical memblocks. I have to confess that I do not
know how expensive is the search and I also expect that there won't be
that many memblocks in the removed range anyway as large setups have
large memblocks.

> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Other than that looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/memory.c  | 37 ++++++++++++++++++-------------------
>  drivers/base/node.c    | 11 ++++++-----
>  include/linux/memory.h |  2 +-
>  include/linux/node.h   |  6 ++----
>  mm/memory_hotplug.c    |  5 +++--
>  5 files changed, 30 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 5a0370f0c506..f28efb0bf5c7 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -763,32 +763,31 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
>  	return ret;
>  }
>  
> -void unregister_memory_section(struct mem_section *section)
> +/*
> + * Remove memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * have to be offline.
> + */
> +void remove_memory_block_devices(unsigned long start, unsigned long size)
>  {
> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
> +	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>  	struct memory_block *mem;
> +	int block_id;
>  
> -	if (WARN_ON_ONCE(!present_section(section)))
> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>  		return;
>  
>  	mutex_lock(&mem_sysfs_mutex);
> -
> -	/*
> -	 * Some users of the memory hotplug do not want/need memblock to
> -	 * track all sections. Skip over those.
> -	 */
> -	mem = find_memory_block(section);
> -	if (!mem)
> -		goto out_unlock;
> -
> -	unregister_mem_sect_under_nodes(mem, __section_nr(section));
> -
> -	mem->section_count--;
> -	if (mem->section_count == 0)
> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
> +		mem = find_memory_block_by_id(block_id, NULL);
> +		if (WARN_ON_ONCE(!mem))
> +			continue;
> +		mem->section_count = 0;
> +		unregister_memory_block_under_nodes(mem);
>  		unregister_memory(mem);
> -	else
> -		put_device(&mem->dev);
> -
> -out_unlock:
> +	}
>  	mutex_unlock(&mem_sysfs_mutex);
>  }
>  
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 8598fcbd2a17..04fdfa99b8bc 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -801,9 +801,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  	return 0;
>  }
>  
> -/* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -				    unsigned long phys_index)
> +/*
> + * Unregister memory block device under all nodes that it spans.
> + */
> +int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -816,8 +817,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  		return -ENOMEM;
>  	nodes_clear(*unlinked_nodes);
>  
> -	sect_start_pfn = section_nr_to_pfn(phys_index);
> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
> +	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
>  		int nid;
>  
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index db3e8567f900..f26a5417ec5d 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -112,7 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  int create_memory_block_devices(unsigned long start, unsigned long size);
> -extern void unregister_memory_section(struct mem_section *);
> +void remove_memory_block_devices(unsigned long start, unsigned long size);
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
>  extern int memory_isolate_notify(unsigned long val, void *v);
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 1a557c589ecb..02a29e71b175 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						void *arg);
> -extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -					   unsigned long phys_index);
> +extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
>  
>  extern int register_memory_node_under_compute_node(unsigned int mem_nid,
>  						   unsigned int cpu_nid,
> @@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>  	return 0;
>  }
> -static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -						  unsigned long phys_index)
> +static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
>  	return 0;
>  }
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9a92549ef23b..82136c5b4c5f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -520,8 +520,6 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
>  	if (WARN_ON_ONCE(!valid_section(ms)))
>  		return;
>  
> -	unregister_memory_section(ms);
> -
>  	scn_nr = __section_nr(ms);
>  	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>  	__remove_zone(zone, start_pfn);
> @@ -1845,6 +1843,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> +	/* remove memory block devices before removing memory */
> +	remove_memory_block_devices(start, size);
> +
>  	arch_remove_memory(nid, start, size, NULL);
>  	__release_memory_resource(start, size);
>  
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

