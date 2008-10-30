Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9U0ASp6021043
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Oct 2008 09:10:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9532445DD7B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 09:10:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C88145DD76
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 09:10:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B2681DB8048
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 09:10:28 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C78951DB803E
	for <linux-mm@kvack.org>; Thu, 30 Oct 2008 09:10:27 +0900 (JST)
Date: Thu, 30 Oct 2008 09:09:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
 test_pages_isolated()
Message-Id: <20081030090958.f86d49db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225290330.10021.7.camel@t60p>
References: <1225290330.10021.7.camel@t60p>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 15:25:30 +0100
Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:

> From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> My last bugfix here (adding zone->lock) introduced a new problem: Using
> page_zone(pfn_to_page(pfn)) to get the zone after the for() loop is wrong.
> pfn will then be >= end_pfn, which may be in a different zone or not
> present at all. This may lead to an addressing exception in page_zone()
> or spin_lock_irqsave().
> 
> Now I use __first_valid_page() again after the loop to find a valid page
> for page_zone().
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
Thanks.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/page_isolation.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/page_isolation.c
> ===================================================================
> --- linux-2.6.orig/mm/page_isolation.c
> +++ linux-2.6/mm/page_isolation.c
> @@ -130,10 +130,11 @@ int test_pages_isolated(unsigned long st
>  		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>  			break;
>  	}
> -	if (pfn < end_pfn)
> +	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
> +	if ((pfn < end_pfn) || !page)
>  		return -EBUSY;
>  	/* Check all pages are free or Marked as ISOLATED */
> -	zone = page_zone(pfn_to_page(pfn));
> +	zone = page_zone(page);
>  	spin_lock_irqsave(&zone->lock, flags);
>  	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn);
>  	spin_unlock_irqrestore(&zone->lock, flags);
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
