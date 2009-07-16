Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 477C56B0082
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:02:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G12tcA020541
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 10:02:57 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F79D45DE56
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:02:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E050045DE55
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:02:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AECEC1DB803F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:02:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 673801DB805E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:02:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] page-allocator: Allow too high-order warning messages to be suppressed with __GFP_NOWARN
In-Reply-To: <1247656992-19846-2-git-send-email-mel@csn.ul.ie>
References: <1247656992-19846-1-git-send-email-mel@csn.ul.ie> <1247656992-19846-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20090716100217.9D13.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 10:02:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>, Arnaldo Carvalho de Melo <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

> The page allocator warns once when an order >= MAX_ORDER is specified.
> This is to catch callers of the allocator that are always falling back
> to their worst-case when it was not expected. However, there are cases
> where the caller is behaving correctly but cannot suppress the warning.
> This patch allows the warning to be suppressed by the callers by
> specifying __GFP_NOWARN.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index caa9268..b469a05 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1740,8 +1740,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * be using allocators in order of preference for an area that is
>  	 * too large.
>  	 */
> -	if (WARN_ON_ONCE(order >= MAX_ORDER))
> +	if (order >= MAX_ORDER) {
> +		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>  		return NULL;
> +	}

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
