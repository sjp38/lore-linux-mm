Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBFMA3Ko015528
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 17:10:03 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBFMA2bF116014
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 17:10:02 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jBFMA2mk023265
	for <linux-mm@kvack.org>; Thu, 15 Dec 2005 17:10:02 -0500
Message-ID: <43A1E9B3.7050203@austin.ibm.com>
Date: Thu, 15 Dec 2005 16:09:55 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 3. (change build_zonelists)[3/5]
References: <20051210194021.482A.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051210194021.482A.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> @@ -1602,12 +1606,16 @@ static int __init build_zonelists_node(p
>  static inline int highest_zone(int zone_bits)
>  {
>  	int res = ZONE_NORMAL;
> -	if (zone_bits & (__force int)__GFP_HIGHMEM)
> -		res = ZONE_HIGHMEM;
> -	if (zone_bits & (__force int)__GFP_DMA32)
> -		res = ZONE_DMA32;
> +
>  	if (zone_bits & (__force int)__GFP_DMA)
>  		res = ZONE_DMA;
> +	if (zone_bits & (__force int)__GFP_DMA32)
> +		res = ZONE_DMA32;
> +	if (zone_bits & (__force int)__GFP_HIGHMEM)
> +		res = ZONE_HIGHMEM;
> +	if (zone_bits & (__force int)__GFP_EASY_RECLAIM)
> +		res = ZONE_EASY_RECLAIM;
> +
>  	return res;
>  }
>  

These look to come in the wrong order here.  You want ZONE_EASY_RECLAIM to be 
the highest zone, but this puts HIGHMEM, DMA32, and DMA ahead of it.  It in fact 
seems to get the order exactly backward.

> Index: zone_reclaim/include/linux/gfp.h
> ===================================================================
> --- zone_reclaim.orig/include/linux/gfp.h	2005-12-06 14:12:43.000000000 +0900
> +++ zone_reclaim/include/linux/gfp.h	2005-12-06 14:12:44.000000000 +0900
> @@ -80,7 +80,7 @@ struct vm_area_struct;
>  
>  static inline int gfp_zone(gfp_t gfp)
>  {
> -	int zone = GFP_ZONEMASK & (__force int) gfp;
> +	int zone = fls(GFP_ZONEMASK & (__force int) gfp);
>  	BUG_ON(zone >= GFP_ZONETYPES);
>  	return zone;
>  }
> 

Does this have endian issues?  I'm not too familiar with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
