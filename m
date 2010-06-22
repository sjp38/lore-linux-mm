Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C510B6B01AF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 23:24:04 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5M3O1GG019134
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 22 Jun 2010 12:24:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F294F45DE80
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:24:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D259045DE7E
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:24:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB391DB803B
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:24:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 761A91DB803A
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:24:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] Call cond_resched() at bottom of main look in  balance_pgdat()
In-Reply-To: <AANLkTilN3EcYq400ajA2-rf3Xs4MhD-sKCg44fjzKlX1@mail.gmail.com>
References: <20100622112416.B554.A69D9226@jp.fujitsu.com> <AANLkTilN3EcYq400ajA2-rf3Xs4MhD-sKCg44fjzKlX1@mail.gmail.com>
Message-Id: <20100622114739.B563.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 22 Jun 2010 12:23:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> Kosaki's patch's goal is that kswap doesn't yield cpu if the zone doesn't meet its
> >> min watermark to avoid failing atomic allocation.
> >> But this patch could yield kswapd's time slice at any time.
> >> Doesn't the patch break your goal in bb3ab59683?
> >
> > No. it don't break.
> >
> > Typically, kswapd periodically call shrink_page_list() and it call
> > cond_resched() even if bb3ab59683 case.
> 
> Hmm. If it is, bb3ab59683 is effective really?
> 
> The bb3ab59683's goal is prevent CPU yield in case of free < min_watermark.
> But shrink_page_list can yield cpu from kswapd at any time.
> So I am not sure what is bb3ab59683's benefit.
> Did you have any number about bb3ab59683's effectiveness?
> (Of course, I know it's very hard. Just out of curiosity)
> 
> As a matter of fact, when I saw this Larry's patch, I thought it would
> be better to revert bb3ab59683. Then congestion_wait could yield CPU
> to other process.
> 
> What do you think about?

No. The goal is not prevent CPU yield. The goal is avoid unnecessary
_long_ sleep (i.e. congestion_wait(BLK_RW_ASYNC, HZ/10)).
Anyway we can't refuse CPU yield on UP. it lead to hangup ;)

What do you mean the number? If it mean how much reduce congestion_wait(),
it was posted a lot of time. If it mean how much reduce page allocation 
failure bug report, I think it has been observable reduced since half 
years ago. 

If you have specific worried concern, can you please share it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
