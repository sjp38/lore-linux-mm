Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3IHdcEl001602
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 13:39:38 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3IHfwTd214950
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 11:41:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3IHfvsB001335
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 11:41:58 -0600
Subject: Re: [PATCH]Fix usemap for DISCONTIG/FLATMEM with not-aligned zone
	initilaization.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080418161522.GB9147@csn.ul.ie>
References: <48080706.50305@cn.fujitsu.com>
	 <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com>
	 <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080418161522.GB9147@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 18 Apr 2008 10:41:56 -0700
Message-Id: <1208540516.25363.44.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shi Weihua <shiwh@cn.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-04-18 at 17:15 +0100, Mel Gorman wrote:
> -void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> +void __meminit memmap_init_zone(unsigned long size, int nid, struct zone *zone,
>                 unsigned long start_pfn, enum memmap_context context)
>  {
>         struct page *page;
>         unsigned long end_pfn = start_pfn + size;
>         unsigned long pfn;
> +       int zoneidx = zone_idx(zone);
> +
> +       /*
> +        * Sanity check the values passed in. It is possible an architecture
> +        * calling this function directly will use values outside of the memory
> +        * they registered
> +        */
> +       if (start_pfn < zone->zone_start_pfn) {
> +               WARN_ON_ONCE(1);
> +               start_pfn = zone->zone_start_pfn;
> +       }
> +
> +       if (size > zone->spanned_pages) {
> +               WARN_ON_ONCE(1);
> +               size = zone->spanned_pages;
> +       }

I was thinking about whether size needs to be modified in there like
this:

	if (start_pfn < zone->zone_start_pfn) {
		WARN_ON_ONCE(1);
+		size -= zone->zone_start_pfn - start_pfn;
		start_pfn = zone->zone_start_pfn;
	}

and I realized that your modification of size actually happens after its
only use in the function (to calculate end_pfn).  Seems like we either
be error-checking end_pfn or delaying its calculation until after 'size'
is fixed.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
