Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E36C66B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 20:30:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U0V9m1019475
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Jun 2009 09:31:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCE5D45DE70
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:31:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A06BE45DE6F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:31:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A001DB803B
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:31:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E540A1DB8040
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:31:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
In-Reply-To: <20090629084114.GA28597@csn.ul.ie>
References: <20090623200846.223C.A69D9226@jp.fujitsu.com> <20090629084114.GA28597@csn.ul.ie>
Message-Id: <20090630092847.A730.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Jun 2009 09:31:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

Thank you new version.

> ==== CUT HERE ====
> mm: Warn once when a page is freed with PG_mlocked set
>     
> When a page is freed with the PG_mlocked set, it is considered an unexpected
> but recoverable situation. A counter records how often this event happens
> but it is easy to miss that this event has occured at all. This patch warns
> once when PG_mlocked is set to prompt debuggers to check the counter to
> see how often it is happening.
>     
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  mm/page_alloc.c |   16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d714f8..519ea6e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -495,8 +495,16 @@ static inline void free_page_mlock(struct page *page)
>  static void free_page_mlock(struct page *page) { }
>  #endif
>  
> -static inline int free_pages_check(struct page *page)
> -{
> +static inline int free_pages_check(struct page *page, int wasMlocked)
> +{
> +	if (unlikely(wasMlocked)) {
> +		WARN_ONCE(1, KERN_WARNING
> +			"Page flag mlocked set for process %s at pfn:%05lx\n"
> +			"page:%p flags:0x%lX\n",

0x%lX is a bit redundunt.
%lX insert "0x" string by itself, I think.


> +			current->comm, page_to_pfn(page),
> +			page, page->flags|__PG_MLOCKED);
> +	}
> +
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
>  		(atomic_read(&page->_count) != 0) |
> @@ -562,7 +570,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	kmemcheck_free_shadow(page, order);
>  
>  	for (i = 0 ; i < (1 << order) ; ++i)
> -		bad += free_pages_check(page + i);
> +		bad += free_pages_check(page + i, wasMlocked);
>  	if (bad)
>  		return;
>  
> @@ -1027,7 +1035,7 @@ static void free_hot_cold_page(struct page *page, int cold)
>  
>  	if (PageAnon(page))
>  		page->mapping = NULL;
> -	if (free_pages_check(page))
> +	if (free_pages_check(page, wasMlocked))
>  		return;
>  
>  	if (!PageHighMem(page)) {

Other part looks fine. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
