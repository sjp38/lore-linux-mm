Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 500596B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 13:38:22 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id y6so243955017ywe.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:38:22 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id y65si12673755qkc.228.2016.05.13.10.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 10:38:21 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id n62so2819969qkc.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:38:21 -0700 (PDT)
Message-ID: <5736110c.02a7370a.878ef.53d0@mx.google.com>
Date: Fri, 13 May 2016 10:38:20 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 3/3] memory-hotplug: use zone_can_shift() for sysfs
 valid_zones attribute
In-Reply-To: <1462816419-4479-4-git-send-email-arbab@linux.vnet.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
	<1462816419-4479-4-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Mon,  9 May 2016 12:53:39 -0500
Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> Since zone_can_shift() is being used to validate the target zone during
> onlining, it should also be used to determine the content of valid_zones.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---

Looks good to me.

Reviewd-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  drivers/base/memory.c | 28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 31e9c61..8e385ea 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -389,6 +389,7 @@ static ssize_t show_valid_zones(struct device *dev,
>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>  	struct page *first_page;
>  	struct zone *zone;
> +	int zone_shift = 0;
>  
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	end_pfn = start_pfn + nr_pages;
> @@ -400,21 +401,26 @@ static ssize_t show_valid_zones(struct device *dev,
>  
>  	zone = page_zone(first_page);
>  
> -	if (zone_idx(zone) == ZONE_MOVABLE - 1) {
> -		/*The mem block is the last memoryblock of this zone.*/
> -		if (end_pfn == zone_end_pfn(zone))
> -			return sprintf(buf, "%s %s\n",
> -					zone->name, (zone + 1)->name);
> +	/* MMOP_ONLINE_KEEP */
> +	sprintf(buf, "%s", zone->name);
> +
> +	/* MMOP_ONLINE_KERNEL */
> +	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_NORMAL);
> +	if (zone_shift) {
> +		strcat(buf, " ");
> +		strcat(buf, (zone + zone_shift)->name);
>  	}
>  
> -	if (zone_idx(zone) == ZONE_MOVABLE) {
> -		/*The mem block is the first memoryblock of ZONE_MOVABLE.*/
> -		if (start_pfn == zone->zone_start_pfn)
> -			return sprintf(buf, "%s %s\n",
> -					zone->name, (zone - 1)->name);
> +	/* MMOP_ONLINE_MOVABLE */
> +	zone_shift = zone_can_shift(start_pfn, nr_pages, ZONE_MOVABLE);
> +	if (zone_shift) {
> +		strcat(buf, " ");
> +		strcat(buf, (zone + zone_shift)->name);
>  	}
>  
> -	return sprintf(buf, "%s\n", zone->name);
> +	strcat(buf, "\n");
> +
> +	return strlen(buf);
>  }
>  static DEVICE_ATTR(valid_zones, 0444, show_valid_zones, NULL);
>  #endif
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
