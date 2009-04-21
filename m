Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B65D56B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:07:22 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L97Q8x004737
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:07:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF18B45DE57
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:07:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C266245DE50
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:07:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7621DB8045
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:07:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B3A41DB803F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:07:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 11/25] Calculate the cold parameter for allocation only once
In-Reply-To: <1240266011-11140-12-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-12-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421180551.F142.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:07:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

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

Honestly, I don't like this ;-)

It seems benefit is too small. It don't win against code ugliness, I think.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
