Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 789B16B0102
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 01:44:35 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so11532919pdb.23
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 22:44:35 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id mi6si22135906pab.17.2014.11.11.22.44.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 22:44:34 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 752B93EE0CD
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 15:44:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id E478BAC07D2
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 15:44:14 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5561E1DB8051
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 15:44:14 +0900 (JST)
Message-ID: <546301A4.3090209@jp.fujitsu.com>
Date: Wed, 12 Nov 2014 15:43:48 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: memblock: Refactor functions to set/clear MEMBLOCK_HOTPLUG
References: <54610c79308447c79c@agluck-desk.sc.intel.com>
In-Reply-To: <54610c79308447c79c@agluck-desk.sc.intel.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tang Chen <tangchen@cn.fujitsu.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Yinghai Lu <yinghai@kernel.org>, Emil Medve <Emilian.Medve@freescale.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2014/11/11 4:05), tony.luck@intel.com wrote:
> There is a lot of duplication in the rubric around actually setting or
> clearing a mem region flag. Create a new helper function to do this and
> reduce each of memblock_mark_hotplug() and memblock_clear_hotplug() to
> a single line.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> ---

The refactoring looks good.

Thanks,
Yasuaki Ishimatsu

> 
> This will be useful if someone were to add a new mem region flag - which
> I hope to be doing some day soon. But it looks like a plausible cleanup
> even without that - so I'd like to get it out of the way now.
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 6ecb0d937fb5..252b77bdf65e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -715,16 +715,13 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
>   }
>   
>   /**
> - * memblock_mark_hotplug - Mark hotpluggable memory with flag MEMBLOCK_HOTPLUG.
> - * @base: the base phys addr of the region
> - * @size: the size of the region
>    *
> - * This function isolates region [@base, @base + @size), and mark it with flag
> - * MEMBLOCK_HOTPLUG.
> + * This function isolates region [@base, @base + @size), and sets/clears flag
>    *
>    * Return 0 on succees, -errno on failure.
>    */
> -int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
> +static int __init_memblock memblock_setclr_flag(phys_addr_t base,
> +				phys_addr_t size, int set, int flag)
>   {
>   	struct memblock_type *type = &memblock.memory;
>   	int i, ret, start_rgn, end_rgn;
> @@ -734,37 +731,37 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
>   		return ret;
>   
>   	for (i = start_rgn; i < end_rgn; i++)
> -		memblock_set_region_flags(&type->regions[i], MEMBLOCK_HOTPLUG);
> +		if (set)
> +			memblock_set_region_flags(&type->regions[i], flag);
> +		else
> +			memblock_clear_region_flags(&type->regions[i], flag);
>   
>   	memblock_merge_regions(type);
>   	return 0;
>   }
>   
>   /**
> - * memblock_clear_hotplug - Clear flag MEMBLOCK_HOTPLUG for a specified region.
> + * memblock_mark_hotplug - Mark hotpluggable memory with flag MEMBLOCK_HOTPLUG.
>    * @base: the base phys addr of the region
>    * @size: the size of the region
>    *
> - * This function isolates region [@base, @base + @size), and clear flag
> - * MEMBLOCK_HOTPLUG for the isolated regions.
> + * Return 0 on succees, -errno on failure.
> + */
> +int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
> +{
> +	return memblock_setclr_flag(base, size, 1, MEMBLOCK_HOTPLUG);
> +}
> +
> +/**
> + * memblock_clear_hotplug - Clear flag MEMBLOCK_HOTPLUG for a specified region.
> + * @base: the base phys addr of the region
> + * @size: the size of the region
>    *
>    * Return 0 on succees, -errno on failure.
>    */
>   int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
>   {
> -	struct memblock_type *type = &memblock.memory;
> -	int i, ret, start_rgn, end_rgn;
> -
> -	ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
> -	if (ret)
> -		return ret;
> -
> -	for (i = start_rgn; i < end_rgn; i++)
> -		memblock_clear_region_flags(&type->regions[i],
> -					    MEMBLOCK_HOTPLUG);
> -
> -	memblock_merge_regions(type);
> -	return 0;
> +	return memblock_setclr_flag(base, size, 0, MEMBLOCK_HOTPLUG);
>   }
>   
>   /**
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
