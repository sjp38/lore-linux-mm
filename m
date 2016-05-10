Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21DAD6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 12:47:25 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so37714414ywa.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 09:47:25 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id n187si1993225qkd.285.2016.05.10.09.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 09:47:24 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id i7so1130116qkd.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 09:47:24 -0700 (PDT)
Message-ID: <5732109b.376b8c0a.19009.570e@mx.google.com>
Date: Tue, 10 May 2016 09:47:23 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 1/3] memory-hotplug: add move_pfn_range()
In-Reply-To: <1462816419-4479-2-git-send-email-arbab@linux.vnet.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
	<1462816419-4479-2-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Mon,  9 May 2016 12:53:37 -0500
Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> Add move_pfn_range(), a wrapper to call move_pfn_range_left() or
> move_pfn_range_right().
> 
> No functional change. This will be utilized by a later patch.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Looks good to me.
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> ---
>  mm/memory_hotplug.c | 38 ++++++++++++++++++++++++++++----------
>  1 file changed, 28 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index aa34431..6b4b005 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -434,6 +434,25 @@ out_fail:
>  	return -1;
>  }
>  
> +static struct zone * __meminit move_pfn_range(int zone_shift,
> +		unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	struct zone *zone = page_zone(pfn_to_page(start_pfn));
> +	int ret = 0;
> +
> +	if (zone_shift < 0)
> +		ret = move_pfn_range_left(zone + zone_shift, zone,
> +					  start_pfn, end_pfn);
> +	else if (zone_shift)
> +		ret = move_pfn_range_right(zone, zone + zone_shift,
> +					   start_pfn, end_pfn);
> +
> +	if (ret)
> +		return NULL;
> +
> +	return zone + zone_shift;
> +}
> +
>  static void __meminit grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
>  				      unsigned long end_pfn)
>  {
> @@ -1024,6 +1043,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	int nid;
>  	int ret;
>  	struct memory_notify arg;
> +	int zone_shift = 0;
>  
>  	/*
>  	 * This doesn't need a lock to do pfn_to_page().
> @@ -1038,18 +1058,16 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  		return -EINVAL;
>  
>  	if (online_type == MMOP_ONLINE_KERNEL &&
> -	    zone_idx(zone) == ZONE_MOVABLE) {
> -		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages))
> -			return -EINVAL;
> -	}
> +	    zone_idx(zone) == ZONE_MOVABLE)
> +		zone_shift = -1;
> +
>  	if (online_type == MMOP_ONLINE_MOVABLE &&
> -	    zone_idx(zone) == ZONE_MOVABLE - 1) {
> -		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages))
> -			return -EINVAL;
> -	}
> +	    zone_idx(zone) == ZONE_MOVABLE - 1)
> +		zone_shift = 1;
>  
> -	/* Previous code may changed the zone of the pfn range */
> -	zone = page_zone(pfn_to_page(pfn));
> +	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
> +	if (!zone)
> +		return -EINVAL;
>  
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
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
