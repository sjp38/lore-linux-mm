Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 33D6B6B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:37:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J2b22i015610
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 11:37:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 391AC45DE4E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:37:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F16CA45DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:37:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BE1C4E78002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:37:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6C02E38003
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 11:37:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <20101019022451.GA8310@localhost>
References: <20101018154137.90f5325f.akpm@linux-foundation.org> <20101019022451.GA8310@localhost>
Message-Id: <20101019113558.A1D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 11:37:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> ---
> Subject: vmscan: comment too_many_isolated()
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Tue Oct 19 09:53:23 CST 2010
> 
> Comment "Why it's doing so" rather than "What it does"
> as proposed by Andrew Morton.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmscan.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> --- linux-next.orig/mm/vmscan.c	2010-10-19 09:29:44.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-10-19 10:21:41.000000000 +0800
> @@ -1142,7 +1142,11 @@ int isolate_lru_page(struct page *page)
>  }
>  
>  /*
> - * Are there way too many processes in the direct reclaim path already?
> + * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
> + * then get resheduled. When there are massive number of tasks doing page
> + * allocation, such sleeping direct reclaimers may keep piling up on each CPU,
> + * the LRU list will go small and be scanned faster than necessary, leading to
> + * unnecessary swapping, thrashing and OOM.
>   */
>  static int too_many_isolated(struct zone *zone, int file,
>  		struct scan_control *sc)

nice!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
