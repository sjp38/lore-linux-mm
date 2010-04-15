Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F2C836B01F0
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 23:31:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F3Vrmx012542
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 12:31:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8990C45DE62
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:31:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FB9045DE55
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:31:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C1FE1DB803C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:31:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7EAA1DB8038
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:31:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
In-Reply-To: <20100407070842.GA18215@localhost>
References: <20100407070050.GA10527@localhost> <20100407070842.GA18215@localhost>
Message-Id: <20100415122928.D168.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 12:31:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > Many applications (this one and below) are stuck in
> > wait_on_page_writeback(). I guess this is why "heavy write to
> > irrelevant partition stalls the whole system".  They are stuck on page
> > allocation. Your 512MB system memory is a bit tight, so reclaim
> > pressure is a bit high, which triggers the wait-on-writeback logic.
> 
> I wonder if this hacking patch may help.
> 
> When creating 300MB dirty file with dd, it is creating continuous
> region of hard-to-reclaim pages in the LRU list. priority can easily
> go low when irrelevant applications' direct reclaim run into these
> regions..

Sorry I'm confused not. can you please tell us more detail explanation?
Why did lumpy reclaim cause OOM? lumpy reclaim might cause
direct reclaim slow down. but IIUC it's not cause OOM because OOM is
only occur when priority-0 reclaim failure. IO get stcking also prevent
priority reach to 0.



> 
> Thanks,
> Fengguang
> ---
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0e5f15..f7179cf 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1149,7 +1149,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  	 */
>  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
>  		lumpy_reclaim = 1;
> -	else if (sc->order && priority < DEF_PRIORITY - 2)
> +	else if (sc->order && priority < DEF_PRIORITY / 2)
>  		lumpy_reclaim = 1;
>  
>  	pagevec_init(&pvec, 1);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
