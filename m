Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4AC6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:42:48 -0400 (EDT)
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only
 once
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1240266011-11140-12-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
	 <1240266011-11140-12-git-send-email-mel@csn.ul.ie>
Date: Tue, 21 Apr 2009 10:43:25 +0300
Message-Id: <1240299805.771.46.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-20 at 23:19 +0100, Mel Gorman wrote:
> GFP mask is checked for __GFP_COLD has been specified when deciding which
> end of the PCP lists to use. However, it is happening multiple times per
> allocation, at least once per zone traversed. Calculate it once.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |   35 ++++++++++++++++++-----------------
>  1 files changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1506cd5..51e1ded 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1066,11 +1066,10 @@ void split_page(struct page *page, unsigned int order)
>   */
>  static struct page *buffered_rmqueue(struct zone *preferred_zone,
>  			struct zone *zone, int order, gfp_t gfp_flags,
> -			int migratetype)
> +			int migratetype, int cold)
>  {
>  	unsigned long flags;
>  	struct page *page;
> -	int cold = !!(gfp_flags & __GFP_COLD);
>  	int cpu;
>  
>  again:

Is this a measurable win? And does gcc inline all this nicely or does
this change actually increase kernel text size?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
