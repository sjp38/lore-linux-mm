Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EE7B46B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 21:22:43 -0400 (EDT)
Date: Fri, 1 May 2009 09:22:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch 20/22] vmscan: avoid multiplication overflow in
	shrink_zone()
Message-ID: <20090501012212.GA5848@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 06:08:55AM +0800, Andrew Morton wrote:
> 
> Local variable `scan' can overflow on zones which are larger than
> 
> 	(2G * 4k) / 100 = 80GB.
> 
> Making it 64-bit on 64-bit will fix that up.

A side note about the "one HUGE scan inside shrink_zone":

Isn't this low level scan granularity way tooooo large?

It makes things a lot worse on memory pressure:
- the over reclaim, somehow workarounded by Rik's early bail out patch
- the throttle_vm_writeout()/congestion_wait() guards could work in a
  very sparse manner and hence is useless: imagine to stop and wait
  after shooting away every 1GB memory.

The long term fix could be to move the granularity control up to the
shrink_zones() level: there it can bail out early without hurting the
balanced zone aging.

Thanks,
Fengguang

> --- a/mm/vmscan.c~vmscan-avoid-multiplication-overflow-in-shrink_zone
> +++ a/mm/vmscan.c
> @@ -1471,7 +1471,7 @@ static void shrink_zone(int priority, st
>  
>  	for_each_evictable_lru(l) {
>  		int file = is_file_lru(l);
> -		int scan;
> +		unsigned long scan;
>  
>  		scan = zone_nr_pages(zone, sc, l);
>  		if (priority) {
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
