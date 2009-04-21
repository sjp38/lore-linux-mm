Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 77C4D6B0055
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 21:44:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L1jC1U013240
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 10:45:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E71F45DD84
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:45:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F19B45DD82
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:45:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CAEBC1DB8045
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:45:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A72AE08004
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:45:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/25] Do not sanity check order in the fast path
In-Reply-To: <1240266011-11140-3-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421104445.F11C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 10:45:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> @@ -182,9 +182,6 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> -	if (unlikely(order >= MAX_ORDER))
> -		return NULL;
> -
>  	/* Unknown node is current node */
>  	if (nid < 0)
>  		nid = numa_node_id();
> @@ -198,9 +195,6 @@ extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
>  static inline struct page *
>  alloc_pages(gfp_t gfp_mask, unsigned int order)
>  {
> -	if (unlikely(order >= MAX_ORDER))
> -		return NULL;
> -
>  	return alloc_pages_current(gfp_mask, order);
>  }
>  extern struct page *alloc_page_vma(gfp_t gfp_mask,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dcc4f05..5028f40 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1405,6 +1405,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
>  
>  	classzone_idx = zone_idx(preferred_zone);
>  
> +	VM_BUG_ON(order >= MAX_ORDER);
> +

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
