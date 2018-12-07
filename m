Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABAE16B7ED4
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 01:06:26 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m13so1976935pls.15
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 22:06:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd12si2184984plb.193.2018.12.06.22.06.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 22:06:25 -0800 (PST)
Message-ID: <1544162765.3008.1.camel@suse.de>
Subject: Re: [PATCH] mm, kmemleak: Little optimization while scanning
From: Oscar Salvador <osalvador@suse.de>
Date: Fri, 07 Dec 2018 07:06:05 +0100
In-Reply-To: <20181206131918.25099-1-osalvador@suse.de>
References: <20181206131918.25099-1-osalvador@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

I just realized I forgot to add that this was suggested by Michal.
Sorry, I was a but rushy.

On Thu, 2018-12-06 at 14:19 +0100, Oscar Salvador wrote:
> kmemleak_scan() goes through all online nodes and tries
> to scan all used pages.
> We can do better and use pfn_to_online_page(), so in case we have
> CONFIG_MEMORY_HOTPLUG, offlined pages will be skiped automatically.
> For boxes where CONFIG_MEMORY_HOTPLUG is not present,
> pfn_to_online_page()
> will fallback to pfn_valid().
> 
> Another little optimization is to check if the page belongs to the
> node
> we are currently checking, so in case we have nodes interleaved we
> will
> not check the same pfn multiple times.
> 
> I ran some tests:
> 
> Add some memory to node1 and node2 making it interleaved:
> 
> (qemu) object_add memory-backend-ram,id=ram0,size=1G
> (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> (qemu) object_add memory-backend-ram,id=ram1,size=1G
> (qemu) device_add pc-dimm,id=dimm1,memdev=ram1,node=2
> (qemu) object_add memory-backend-ram,id=ram2,size=1G
> (qemu) device_add pc-dimm,id=dimm2,memdev=ram2,node=1
> 
> Then, we offline that memory:
>  # for i in {32..39} ; do echo "offline" >
> /sys/devices/system/node/node1/memory$i/state;done
>  # for i in {48..55} ; do echo "offline" >
> /sys/devices/system/node/node1/memory$i/state;don
>  # for i in {40..47} ; do echo "offline" >
> /sys/devices/system/node/node2/memory$i/state;done
> 
> And we run kmemleak_scan:
> 
>  # echo "scan" > /sys/kernel/debug/kmemleak
> 
> before the patch:
> 
> kmemleak: time spend: 41596 us
> 
> after the patch:
> 
> kmemleak: time spend: 34899 us
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
Suggested-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/kmemleak.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 877de4fa0720..5ce1e6a46d77 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -113,6 +113,7 @@
>  #include <linux/kmemleak.h>
>  #include <linux/memory_hotplug.h>
>  
> +
>  /*
>   * Kmemleak configuration and common defines.
>   */
> @@ -1547,11 +1548,14 @@ static void kmemleak_scan(void)
>  		unsigned long pfn;
>  
>  		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> -			struct page *page;
> +			struct page *page = pfn_to_online_page(pfn);
> +
> +			if (!page)
> +				continue;
>  
> -			if (!pfn_valid(pfn))
> +			/* only scan pages belonging to this node */
> +			if (page_to_nid(page) != i)
>  				continue;
> -			page = pfn_to_page(pfn);
>  			/* only scan if page is in use */
>  			if (page_count(page) == 0)
>  				continue;
-- 
Oscar Salvador
SUSE L3
