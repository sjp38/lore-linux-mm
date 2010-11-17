Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE888D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 03:16:51 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oAH8GjIM020230
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:45 -0800
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by hpaq11.eem.corp.google.com with ESMTP id oAH8GfSC030470
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:43 -0800
Received: by gwj17 with SMTP id 17so946245gwj.19
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:40 -0800 (PST)
Date: Wed, 17 Nov 2010 00:16:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [1/8,v3] NUMA Hotplug Emulator: add function to hide memory
 region via e820 table.
In-Reply-To: <20101117021000.479272928@intel.com>
Message-ID: <alpine.DEB.2.00.1011162354390.16875@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.479272928@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, shaohui.zheng@intel.com wrote:

> Index: linux-hpe4/arch/x86/kernel/e820.c
> ===================================================================
> --- linux-hpe4.orig/arch/x86/kernel/e820.c	2010-11-15 17:13:02.483461667 +0800
> +++ linux-hpe4/arch/x86/kernel/e820.c	2010-11-15 17:13:07.083461581 +0800
> @@ -971,6 +971,7 @@
>  }
>  
>  static int userdef __initdata;
> +static u64 max_mem_size __initdata = ULLONG_MAX;
>  
>  /* "mem=nopentium" disables the 4MB page tables. */
>  static int __init parse_memopt(char *p)
> @@ -989,12 +990,28 @@
>  
>  	userdef = 1;
>  	mem_size = memparse(p, &p);
> -	e820_remove_range(mem_size, ULLONG_MAX - mem_size, E820_RAM, 1);
> +	e820_remove_range(mem_size, max_mem_size - mem_size, E820_RAM, 1);
> +	max_mem_size = mem_size;
>  
>  	return 0;
>  }

This needs memmap= support as well, right?

>  early_param("mem", parse_memopt);
>  
> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> +u64 __init e820_hide_mem(u64 mem_size)
> +{
> +	u64 start, end_pfn;
> +
> +	userdef = 1;
> +	end_pfn = e820_end_of_ram_pfn();
> +	start = (end_pfn << PAGE_SHIFT) - mem_size;
> +	e820_remove_range(start, max_mem_size - start, E820_RAM, 1);
> +	max_mem_size = start;
> +
> +	return start;
> +}
> +#endif

This doesn't have any sanity checking for whether e820_remove_range() will 
leave any significant amount of memory behind so the kernel will even boot 
(probably should have a guaranteed FAKE_NODE_MIN_SIZE left behind?).

> +
>  static int __init parse_memmap_opt(char *p)
>  {
>  	char *oldp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
