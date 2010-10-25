Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2305D6B00B7
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 01:20:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P5Kn4Q004915
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 14:20:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DDE5245DD71
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:20:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AE94645DE4E
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:20:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 79680E38003
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:20:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 156BD1DB8019
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 14:20:45 +0900 (JST)
Date: Mon, 25 Oct 2010 14:15:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory-hotplug: only drain LRU when failed to offline
 pages
Message-Id: <20101025141519.7fd32b1c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101025051202.GA22412@localhost>
References: <20101025051202.GA22412@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 13:12:02 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> do_migrate_range() offlines 1MB pages at one time and hence might be
> called up to 16000 times when trying to offline 16GB memory. 

But size of memory section is not such big.

> It makes sense to avoid sending the costly IPIs to drain pages on all LRU for
> the 99% cases that do_migrate_range() succeeds offlining some pages.
> 

did you test ? I think this patch should be tested by IBM guys.

> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Sorry, this will HUNK. Could you wait until the end of merge window ?


> ---
>  mm/memory_hotplug.c |   24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> --- linux-next.orig/mm/memory_hotplug.c	2010-10-25 11:20:47.000000000 +0800
> +++ linux-next/mm/memory_hotplug.c	2010-10-25 13:07:10.000000000 +0800
> @@ -788,7 +788,7 @@ static int offline_pages(unsigned long s
>  {
>  	unsigned long pfn, nr_pages, expire;
>  	long offlined_pages;
> -	int ret, drain, retry_max, node;
> +	int ret, retry_max, node;
>  	struct zone *zone;
>  	struct memory_notify arg;
>  
> @@ -827,7 +827,6 @@ static int offline_pages(unsigned long s
>  
>  	pfn = start_pfn;
>  	expire = jiffies + timeout;
> -	drain = 0;
>  	retry_max = 5;
>  repeat:
>  	/* start memory hot removal */
> @@ -838,34 +837,31 @@ repeat:
>  	if (signal_pending(current))
>  		goto failed_removal;
>  	ret = 0;
> -	if (drain) {
> -		lru_add_drain_all();
> -		flush_scheduled_work();

this flush_scheduled_work() is removed in recent work of Tejun Heo.

> -		cond_resched();
> -		drain_all_pages();
> -	}
> -
>  	pfn = scan_lru_pages(start_pfn, end_pfn);
>  	if (pfn) { /* We have page on LRU */
>  		ret = do_migrate_range(pfn, end_pfn);
>  		if (!ret) {
> -			drain = 1;
>  			goto repeat;
>  		} else {
>  			if (ret < 0)
>  				if (--retry_max == 0)
>  					goto failed_removal;
>  			yield();
> -			drain = 1;
> +			lru_add_drain_all();
> +			flush_scheduled_work();
This flush is unnecessary.

> +			cond_resched();
> +			drain_all_pages();

I think followin is  better order.

drain_all_pages();      # SEND IPI and asynchronous.
lru_add_drain_pages();  # call schedule_work ony by one and it's synchronous.
cond_resched();	# may not be unnecessary (lru_add_drain_pages() will sleep.)

>  			goto repeat;
>  		}
>  	}
> -	/* drain all zone's lru pagevec, this is asyncronous... */
> +
> +	/* drain all zone's lru pagevec, this is asynchronous... */
>  	lru_add_drain_all();
>  	flush_scheduled_work();
This flush() is dropped by recent works of Tejun Heo's workqueue updates.

Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
