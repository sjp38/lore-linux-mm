Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 550146B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:08:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L98Piv005138
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:08:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B818C45DD77
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:08:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 954D545DD74
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:08:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EF02E08003
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:08:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 366731DB8017
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:08:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 12/25] Remove a branch by assuming __GFP_HIGH == ALLOC_HIGH
In-Reply-To: <1240266011-11140-13-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-13-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421180757.F145.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:08:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Allocations that specify __GFP_HIGH get the ALLOC_HIGH flag. If these
> flags are equal to each other, we can eliminate a branch.
> 
> [akpm@linux-foundation.org: Suggested the hack]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 51e1ded..b13fc29 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1639,8 +1639,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
>  	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
>  	 */
> -	if (gfp_mask & __GFP_HIGH)
> -		alloc_flags |= ALLOC_HIGH;
> +	VM_BUG_ON(__GFP_HIGH != ALLOC_HIGH);
> +	alloc_flags |= (gfp_mask & __GFP_HIGH);
>  
>  	if (!wait) {
>  		alloc_flags |= ALLOC_HARDER;

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
