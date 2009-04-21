Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A321A6B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:47:00 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3LAlh8B005789
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 19:47:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DAC0E45DE59
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:47:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A95EC45DE55
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:47:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A54171DB8046
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:47:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC53A1DB8043
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:47:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 16/25] Save text by reducing call sites of __rmqueue()
In-Reply-To: <1240266011-11140-17-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-17-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421193511.F16E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 19:47:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>  	} else {
> -		spin_lock_irqsave(&zone->lock, flags);
> -		page = __rmqueue(zone, order, migratetype);
> -		spin_unlock(&zone->lock);
> -		if (!page)
> +		LIST_HEAD(list);
> +		local_irq_save(flags);
> +
> +		/* Calling __rmqueue would bloat text, hence this */
> +		if (!rmqueue_bulk(zone, order, 1, &list, migratetype))
>  			goto failed;
> +		page = list_entry(list.next, struct page, lru);
> +		list_del(&page->lru);
>  	}

looks good
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
