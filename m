Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 227756B00C4
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:22:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B2B473EE0B6
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:22:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 99A6845DE53
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:22:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8336545DD74
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:22:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 756121DB8040
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:22:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B3221DB803C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:22:27 +0900 (JST)
Message-ID: <4FD59C31.6000606@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 16:20:17 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not use page_count without a page pin
References: <1339373872-31969-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1339373872-31969-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

(2012/06/11 9:17), Minchan Kim wrote:
> d179e84ba fixed the problem[1] in vmscan.c but same problem is here.
> Let's fix it.
> 
> [1] http://comments.gmane.org/gmane.linux.kernel.mm/65844
> 
> I copy and paste d179e84ba's contents for description.
> 
> "It is unsafe to run page_count during the physical pfn scan because
> compound_head could trip on a dangling pointer when reading
> page->first_page if the compound page is being freed by another CPU."
> 
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim<minchan@kernel.org>
> ---
>   mm/page_alloc.c |    6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 266f267..019c4fe 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5496,7 +5496,11 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>   			continue;
> 
>   		page = pfn_to_page(check);
> -		if (!page_count(page)) {
> +		/*
> +		 * We can't use page_count withou pin a page
> +		 * because another CPU can free compound page.
> +		 */
> +		if (!atomic_read(&page->_count)) {
>   			if (PageBuddy(page))
>   				iter += (1<<  page_order(page)) - 1;
>   			continue;
Nice Catch.

Other than the comment fix already pointed out..
Hmm...BTW, it seems this __count_xxx doesn't have any code for THP/Hugepage..
so, we need more fixes for better code, I think.
Hmm, Don't we need !PageTail() check and 'skip thp' code ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
