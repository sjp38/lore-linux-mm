Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A67CF6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:36:38 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D1aX6n029503
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 10:36:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FF6B45DE50
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:36:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F05F45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:36:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E14E1DB8042
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:36:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D35511DB8040
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:36:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <20090312175631.17890.30427.sendpatchset@localhost.localdomain>
Message-Id: <20090313094735.43D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 10:36:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 46bd24c..b49c90f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1583,7 +1583,14 @@ nofail_alloc:
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> +	/*
> +	 * Try to free up some pages from the memory controllers soft
> +	 * limit queue.
> +	 */
> +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> +	if (!order || !did_some_progress)
> +		did_some_progress += try_to_free_pages(zonelist, order,
> +							gfp_mask);

I have two objection to this.

- "if (!order || !did_some_progress)" mean no call try_to_free_pages()
  in order>0 and did_some_progress>0 case.
  but mem_cgroup_soft_limit_reclaim() don't have lumpy reclaim.
  then, it break high order reclaim.
- in global reclaim view, foreground reclaim and background reclaim's
  reclaim rate is about 1:9 typically.
  then, kswapd reclaim the pages by global lru order before proceccing
  this logic.
  IOW, this soft limit is not SOFT.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
