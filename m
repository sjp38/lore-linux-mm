Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D8596B005A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 20:20:26 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M0Khfc001288
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 22 Apr 2009 09:20:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B79E45DE50
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:20:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E966445DE53
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:20:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E495E08007
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:20:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 951F71DB8041
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:20:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 20/25] Do not check for compound pages during the page allocator sanity checks
In-Reply-To: <1240266011-11140-21-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-21-git-send-email-mel@csn.ul.ie>
Message-Id: <20090422091456.626E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 22 Apr 2009 09:20:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> A number of sanity checks are made on each page allocation and free
> including that the page count is zero. page_count() checks for
> compound pages and checks the count of the head page if true. However,
> in these paths, we do not care if the page is compound or not as the
> count of each tail page should also be zero.
> 
> This patch makes two changes to the use of page_count() in the free path. It
> converts one check of page_count() to a VM_BUG_ON() as the count should
> have been unconditionally checked earlier in the free path. It also avoids
> checking for compound pages.
> 
> [mel@csn.ul.ie: Wrote changelog]
> Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> ---
>  mm/page_alloc.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ec01d8f..376d848 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -425,7 +425,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>  		return 0;
>  
>  	if (PageBuddy(buddy) && page_order(buddy) == order) {
> -		BUG_ON(page_count(buddy) != 0);
> +		VM_BUG_ON(page_count(buddy) != 0);
>  		return 1;
>  	}
>  	return 0;
>

Looks good.


> @@ -501,7 +501,7 @@ static inline int free_pages_check(struct page *page)
>  {
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
> -		(page_count(page) != 0)  |
> +		(atomic_read(&page->_count) != 0) |
>  		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
>  		bad_page(page);
>  		return 1;
> @@ -646,7 +646,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
>  {
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
> -		(page_count(page) != 0)  |
> +		(atomic_read(&page->_count) != 0)  |
>  		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
>  		bad_page(page);
>  		return 1;


inserting VM_BUG_ON(PageTail(page)) is better?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
