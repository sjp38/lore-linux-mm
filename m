Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B60B96B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:54:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n64-v6so23034606qkd.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 02:54:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t22-v6si7386435qtj.158.2018.10.16.02.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 02:54:52 -0700 (PDT)
Subject: Re: [PATCH 3/5] mm/memory_hotplug: Check for IORESOURCE_SYSRAM in
 release_mem_region_adjustable
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-4-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a7421c75-e26d-f830-8d7a-8afad269f5de@redhat.com>
Date: Tue, 16 Oct 2018 11:54:45 +0200
MIME-Version: 1.0
In-Reply-To: <20181015153034.32203-4-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

On 15/10/2018 17:30, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> This is a preparation for the next patch.
> 
> Currently, we only call release_mem_region_adjustable() in __remove_pages
> if the zone is not ZONE_DEVICE, because resources that belong to
> HMM/devm are being released by themselves with devm_release_mem_region.
> 
> Since we do not want to touch any zone/page stuff during the removing
> of the memory (but during the offlining), we do not want to check for
> the zone here.
> So we need another way to tell release_mem_region_adjustable() to not
> realease the resource in case it belongs to HMM/devm.
> 
> HMM/devm acquires/releases a resource through
> devm_request_mem_region/devm_release_mem_region.
> 
> These resources have the flag IORESOURCE_MEM, while resources acquired by
> hot-add memory path (register_memory_resource()) contain
> IORESOURCE_SYSTEM_RAM.
> 
> So, we can check for this flag in release_mem_region_adjustable, and if
> the resource does not contain such flag, we know that we are dealing with
> a HMM/devm resource, so we can back off.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  kernel/resource.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 81937830a42f..c45decd7d6af 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1272,6 +1272,22 @@ int release_mem_region_adjustable(struct resource *parent,
>  			continue;
>  		}
>  
> +		/*
> +		 * All memory regions added from memory-hotplug path
> +		 * have the flag IORESOURCE_SYSTEM_RAM.
> +		 * If the resource does not have this flag, we know that
> +		 * we are dealing with a resource coming from HMM/devm.
> +		 * HMM/devm use another mechanism to add/release a resource.
> +		 * This goes via devm_request_mem_region and
> +		 * devm_release_mem_region.
> +		 * HMM/devm take care to release their resources when they want,
> +		 * so if we are dealing with them, let us just back off here.
> +		 */
> +		if (!(res->flags & IORESOURCE_SYSRAM)) {
> +			ret = 0;
> +			break;
> +		}
> +
>  		if (!(res->flags & IORESOURCE_MEM))
>  			break;
>  
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
