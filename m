Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3966B0292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:33:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18so8306292wra.11
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:33:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y12si1118875wrd.240.2017.06.16.10.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:33:53 -0700 (PDT)
Date: Fri, 16 Jun 2017 10:33:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/memory_hotplug: remove duplicate call for
 set_page_links
Message-Id: <20170616103350.e065a9838bb50c2dc70a41d8@linux-foundation.org>
In-Reply-To: <20170616092335.5177-2-richard.weiyang@gmail.com>
References: <20170616092335.5177-1-richard.weiyang@gmail.com>
	<20170616092335.5177-2-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@kernel.org, linux-mm@kvack.org

On Fri, 16 Jun 2017 17:23:35 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> In function move_pfn_range_to_zone(), memmap_init_zone() will call
> set_page_links for each page.

Well, no.  There are several types of pfn's for which
memmap_init_zone() will not call
__init_single_page()->set_page_links().  Probably the code is OK, as
those are pretty screwy pfn types.  But I'd like to see some
confirmation that this patch is OK for all such pfns, now and in the
future?

> This means we don't need to call it on each
> page explicitly.
> 
> This patch just removes the loop.
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -914,10 +914,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
>  	 * are reserved so nobody should be touching them so we should be safe
>  	 */
>  	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLUG);
> -	for (i = 0; i < nr_pages; i++) {
> -		unsigned long pfn = start_pfn + i;
> -		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
> -	}
>  
>  	set_zone_contiguous(zone);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
