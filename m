Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 069E26B016C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 09:05:14 -0400 (EDT)
Message-ID: <4E958FBB.6000200@stericsson.com>
Date: Wed, 12 Oct 2011 15:01:47 +0200
From: Maxime Coquelin <maxime.coquelin-nonst@stericsson.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fixup: mm: alloc_contig_range: increase min_free_kbytes
 during allocation
References: <4E93F088.60006@stericsson.com> <1318417735-9199-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1318417735-9199-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-media@vger.kernel.org'" <linux-media@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, "benjamin.gaignard@linaro.org" <benjamin.gaignard@linaro.org>, Ludovic BARRE <ludovic.barre@stericsson.com>, "vincent.guittot@linaro.org" <vincent.guittot@linaro.org>

Hello Marek,

On 10/12/2011 01:08 PM, Marek Szyprowski wrote:
> Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
> ---
>   mm/page_alloc.c |   15 ++++++++++++---
>   1 files changed, 12 insertions(+), 3 deletions(-)
>
> Hello Maxime,
>
> Please check if this patch fixes your lockup issue. It is a bit cruel,
> but it looks that in case of real low-memory situation page allocation
> is very complex task which usually ends in waiting for the io/fs and
> free pages that really don't arrive at all.
Thanks for the reactivity.
We just tested it, we no more faced the lockup. Instead, the OOM Killer 
is triggered and contiguous allocation succeed.
I'm not familiar enough with page_alloc.c to detect any side effects 
this patch could bring.

> Best regards
> --
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 055aa4c..45473e9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5872,6 +5872,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>   		       gfp_t flags, unsigned migratetype)
>   {
>   	unsigned long outer_start, outer_end;
> +	unsigned int count = end - start;
>   	int ret;
>
>   	/*
> @@ -5900,7 +5901,10 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>   	ret = __start_isolate_page_range(pfn_to_maxpage(start),
>   					 pfn_to_maxpage_up(end), migratetype);
>   	if (ret)
> -		goto done;
> +		return ret;
> +
> +	min_free_kbytes += count * PAGE_SIZE / 1024;
> +	setup_per_zone_wmarks();
>
>   	ret = __alloc_contig_migrate_range(start, end);
>   	if (ret)
> @@ -5922,8 +5926,10 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>
>   	ret = 0;
>   	while (!PageBuddy(pfn_to_page(start&  (~0UL<<  ret))))
> -		if (WARN_ON(++ret>= MAX_ORDER))
> -			return -EINVAL;
> +		if (WARN_ON(++ret>= MAX_ORDER)) {
> +			ret = -EINVAL;
> +			goto done;
> +		}
>
>   	outer_start = start&  (~0UL<<  ret);
>   	outer_end   = alloc_contig_freed_pages(outer_start, end, flags);
> @@ -5936,6 +5942,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>
>   	ret = 0;
>   done:
> +	min_free_kbytes -= count * PAGE_SIZE / 1024;
> +	setup_per_zone_wmarks();
> +
>   	__undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end),
>   				  migratetype);
>   	return ret;

Best regards,
Maxime

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
