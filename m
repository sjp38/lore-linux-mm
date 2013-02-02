Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 691866B0008
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 19:28:50 -0500 (EST)
Date: Fri, 1 Feb 2013 16:28:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] mm/page_alloc: add informative debugging message in
 page_outside_zone_boundaries()
Message-Id: <20130201162848.74bdb2a7.akpm@linux-foundation.org>
In-Reply-To: <1358463181-17956-7-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
	<1358463181-17956-7-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On Thu, 17 Jan 2013 14:52:58 -0800
Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> Add a debug message which prints when a page is found outside of the
> boundaries of the zone it should belong to. Format is:
> 	"page $pfn outside zone [ $start_pfn - $end_pfn ]"
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8ed277..f1783cf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -239,13 +239,20 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  	int ret = 0;
>  	unsigned seq;
>  	unsigned long pfn = page_to_pfn(page);
> +	unsigned long sp, start_pfn;
>  
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

As this condition leads to a VM_BUG_ON(), "pr_debug" seems rather wimpy
and I doubt if we need to be concerned about flooding the console.

I'll switch it to pr_err.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
