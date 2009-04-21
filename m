Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B26C6B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 02:37:03 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L6bT0l000592
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 15:37:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 740F945DE5B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:37:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4004045DE56
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:37:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14D3EE08001
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:37:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C771DB803F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:37:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/25] Move check for disabled anti-fragmentation out of fastpath
In-Reply-To: <1240266011-11140-7-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-7-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421153702.F12D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 15:37:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> @@ -50,9 +50,6 @@ extern int page_group_by_mobility_disabled;
>  
>  static inline int get_pageblock_migratetype(struct page *page)
>  {
> -	if (unlikely(page_group_by_mobility_disabled))
> -		return MIGRATE_UNMOVABLE;
> -
>  	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
>  }
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 13b4d11..c8465d0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -172,6 +172,10 @@ int page_group_by_mobility_disabled __read_mostly;
>  
>  static void set_pageblock_migratetype(struct page *page, int migratetype)
>  {
> +
> +	if (unlikely(page_group_by_mobility_disabled))
> +		migratetype = MIGRATE_UNMOVABLE;
> +
>  	set_pageblock_flags_group(page, (unsigned long)migratetype,
>  					PB_migrate, PB_migrate_end);

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
