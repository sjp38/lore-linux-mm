Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBFLwZCQ002771
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 16:58:35 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBFM0GHW095532
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 15:00:16 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBFLwZ72003989
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 14:58:35 -0700
Message-ID: <43A1E704.6040106@austin.ibm.com>
Date: Thu, 15 Dec 2005 15:58:28 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 3. (define ZONE_EASY_RECLAIM)[2/5]
References: <20051210193849.4828.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051210193849.4828.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Sorry for the slow reply.  Hope feedback isn't too late.

> Index: zone_reclaim/include/linux/mmzone.h
> ===================================================================
> --- zone_reclaim.orig/include/linux/mmzone.h	2005-12-10 17:12:58.000000000 +0900
> +++ zone_reclaim/include/linux/mmzone.h	2005-12-10 17:13:16.000000000 +0900
> @@ -73,9 +73,10 @@ struct per_cpu_pageset {
>  #define ZONE_DMA32		1
>  #define ZONE_NORMAL		2
>  #define ZONE_HIGHMEM		3
> +#define ZONE_EASY_RECLAIM	4
>  
> -#define MAX_NR_ZONES		4	/* Sync this with ZONES_SHIFT */
> -#define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
> +#define MAX_NR_ZONES		5	/* Sync this with ZONES_SHIFT */
> +#define ZONES_SHIFT		3	/* ceil(log2(MAX_NR_ZONES)) */
>  
>  
>  /*
> Index: zone_reclaim/mm/page_alloc.c
> ===================================================================
> --- zone_reclaim.orig/mm/page_alloc.c	2005-12-10 17:13:15.000000000 +0900
> +++ zone_reclaim/mm/page_alloc.c	2005-12-10 17:15:10.000000000 +0900
> @@ -66,7 +66,7 @@ static void fastcall free_hot_cold_page(
>   * TBD: should special case ZONE_DMA32 machines here - in those we normally
>   * don't need any ZONE_NORMAL reservation
>   */
> -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 32 };
> +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = { 256, 256, 256, 32 ,32};

This line looks wrong.  It looks you are initializing a 4 element array with 5 
elements.

>  
>  EXPORT_SYMBOL(totalram_pages);
>  
> @@ -77,7 +77,7 @@ EXPORT_SYMBOL(totalram_pages);
>  struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
>  EXPORT_SYMBOL(zone_table);
>  
> -static char *zone_names[MAX_NR_ZONES] = { "DMA", "DMA32", "Normal", "HighMem" };
> +static char *zone_names[MAX_NR_ZONES] = { "DMA", "DMA32", "Normal", "HighMem", "Easy Reclaim"};
>  int min_free_kbytes = 1024;
>  
>  unsigned long __initdata nr_kernel_pages;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
