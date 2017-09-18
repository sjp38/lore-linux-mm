Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09F606B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:35:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h16so8352144wrf.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:35:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si6130924edd.498.2017.09.17.23.35.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:35:45 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:35:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/memory_hotplug: Change
 pfn_to_section_nr/section_nr_to_pfn macro to inline function
Message-ID: <20170918063538.k3zddvfecp2yxon6@dhcp22.suse.cz>
References: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Fri 15-09-17 22:52:20, YASUAKI ISHIMATSU wrote:
> pfn_to_section_nr() and section_nr_to_pfn() are defined as macro.
> pfn_to_section_nr() has no issue even if it is defined as macro.
> But section_nr_to_pfn() has overflow issue if sec is defined as int.
> 
> section_nr_to_pfn() just shifts sec by PFN_SECTION_SHIFT. If sec
> is defined as unsigned long, section_nr_to_pfn() returns pfn as 64
> bit value. But if sec is defined as int, section_nr_to_pfn() returns
> pfn as 32 bit value.
> 
> __remove_section() calculates start_pfn using section_nr_to_pfn() and
> scn_nr defined as int. So if hot-removed memory address is over 16TB,
> overflow issue occurs and section_nr_to_pfn() does not calculate
> correct pfn.
> 
> To make callers use proper arg, the patch changes the macros to
> inline functions.
> 

I guess the following is due

Fixes: 815121d2b5cd ("memory_hotplug: clear zone when removing the memory")
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  include/linux/mmzone.h | 10 ++++++++--
>  mm/memory_hotplug.c    |  2 +-
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ef6a13b..6ae12b2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1073,8 +1073,14 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  #error Allocator MAX_ORDER exceeds SECTION_SIZE
>  #endif
> 
> -#define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
> -#define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
> +static inline unsigned long pfn_to_section_nr(unsigned long pfn)
> +{
> +	return pfn >> PFN_SECTION_SHIFT;
> +}
> +static inline unsigned long section_nr_to_pfn(unsigned long sec)
> +{
> +	return sec << PFN_SECTION_SHIFT;
> +}
> 
>  #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
>  #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b63d7d1..38c3c37 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -798,7 +798,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>  		return ret;
> 
>  	scn_nr = __section_nr(ms);
> -	start_pfn = section_nr_to_pfn(scn_nr);
> +	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>  	__remove_zone(zone, start_pfn);
> 
>  	sparse_remove_one_section(zone, ms, map_offset);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
