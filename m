Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E52426B000C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 14:27:42 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k66so26043591qkf.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 11:27:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m50sor18688417qtb.61.2018.11.12.11.27.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 11:27:42 -0800 (PST)
Date: Mon, 12 Nov 2018 19:27:38 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH 3/5] mm/memory_hotplug: Check for IORESOURCE_SYSRAM in
 release_mem_region_adjustable
Message-ID: <20181112192738.n3cbsgtbjokikvco@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-4-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015153034.32203-4-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

On 18-10-15 17:30:32, Oscar Salvador wrote:
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

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

A couple nits, re-format above comment block to fill 80-char limit:
      /*
       * All memory regions added from memory-hotplug path have the
       * flag IORESOURCE_SYSTEM_RAM.  If the resource does not have
       * this flag, we know that we are dealing with a resource coming
       * from HMM/devm.  HMM/devm use another mechanism to add/release
       * a resource.  This goes via devm_request_mem_region and
       * devm_release_mem_region.  HMM/devm take care to release their
       * resources when they want, so if we are dealing with them, let
       * us just back off here.
       */

I would set ret = 0, at the beginning instead of -EINVAL, and change
returns accordingly.


Thank you,
Pasha
