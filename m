Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 5B12F6B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:34:47 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 18:34:46 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 765E73E40039
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:34:38 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G1Yi4M300684
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:34:44 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G1YhxW028801
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:34:44 -0700
Message-ID: <50F603AC.90005@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:34:36 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/17] mm/page_alloc: add informative debugging message
 in page_outside_zone_boundaries()
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-16-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-16-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> Add a debug message which prints when a page is found outside of the
> boundaries of the zone it should belong to. Format is:
> 	"page $pfn outside zone [ $start_pfn - $end_pfn ]"

I'd make sure to say 'pfn' here, just to make sure that it's explicitly
stated to be a pfn and not a 'struct page'

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8ed277..f1783cf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -239,13 +239,20 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  	int ret = 0;
>  	unsigned seq;
>  	unsigned long pfn = page_to_pfn(page);
> +	unsigned long sp, start_pfn;

I think calling this zone_spanned is probably just fine.  Shouldn't take
up too much room.

>  	do {
>  		seq = zone_span_seqbegin(zone);
> +		start_pfn = zone->zone_start_pfn;
> +		sp = zone->spanned_pages;
>  		if (!zone_spans_pfn(zone, pfn))
>  			ret = 1;
>  	} while (zone_span_seqretry(zone, seq));
> 
> +	if (ret)
> +		pr_debug("page %lu outside zone [ %lu - %lu ]\n",
> +			pfn, start_pfn, start_pfn + sp);
> +
>  	return ret;
>  }

Is there a way we could also fit in something to disambiguate the zones?
 I can imagine a scenario where two zones might have identical
start/spanned_pages, so they might be impossible to tell apart in a
message like this.  Maybe we could add the NUMA node or the
DMA/Normal/Highmem text?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
