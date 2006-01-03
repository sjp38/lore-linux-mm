Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k03LOq1C028787
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 16:24:52 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k03LNZZM176204
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:23:35 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k03LOqXB027000
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:24:52 -0700
Message-ID: <43BAEB98.8060906@austin.ibm.com>
Date: Tue, 03 Jan 2006 15:24:40 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 4. (change build_zonelists)[3/8]
References: <20051220172910.1B0C.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051220172910.1B0C.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> -	BUG_ON(zone_type > ZONE_HIGHMEM);
> +	BUG_ON(zone_type > ZONE_EASY_RECLAIM);

It might be nice to check ifndef CONFIG_HIGHMEM that the zone isn't 
particularly ZONE_HIGHMEM.

>  	int res = ZONE_NORMAL;
> -	if (zone_bits & (__force int)__GFP_HIGHMEM)
> -		res = ZONE_HIGHMEM;
> -	if (zone_bits & (__force int)__GFP_DMA32)
> -		res = ZONE_DMA32;
> -	if (zone_bits & (__force int)__GFP_DMA)
> +
> +	if (zone_bits == fls((__force int)__GFP_DMA))
>  		res = ZONE_DMA;
> +	if (zone_bits == fls((__force int)__GFP_DMA32) &&
> +	    (__force int)__GFP_DMA32 == 0x02)
> +		res = ZONE_DMA32;
> +	if (zone_bits == fls((__force int)__GFP_HIGHMEM))
> +		res = ZONE_HIGHMEM;
> +	if (zone_bits == fls((__force int)__GFP_EASY_RECLAIM))
> +		res = ZONE_EASY_RECLAIM;
> +
>  	return res;
>  }

It is incredibly silly to check a constant for a value.  When it is zero 
instead of 2 the first part of the statement will be false anyway.

Which reminds me.  Why are we using fls again?  I don't see why we 
aren't just (zone_bits & value) the types.  It seems much easier to 
understand that way.

>  
> Index: zone_reclaim/include/linux/gfp.h
> ===================================================================
> --- zone_reclaim.orig/include/linux/gfp.h	2005-12-19 20:19:37.000000000 +0900
> +++ zone_reclaim/include/linux/gfp.h	2005-12-19 20:19:56.000000000 +0900
> @@ -81,7 +81,7 @@ struct vm_area_struct;
>  
>  static inline int gfp_zone(gfp_t gfp)
>  {
> -	int zone = GFP_ZONEMASK & (__force int) gfp;
> +	int zone = fls(GFP_ZONEMASK & (__force int) gfp);
>  	BUG_ON(zone >= GFP_ZONETYPES);
>  	return zone;
>  }
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
