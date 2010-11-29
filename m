Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B49136B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 20:13:27 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT1DPvN026221
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 10:13:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EA9E2E68C1
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:13:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27F561EF09D
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:13:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B8C31DB8048
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:13:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE2D21DB8047
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:13:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <1290992638.12777.27.camel@sli10-conroe>
References: <20101126181604.B6E4.A69D9226@jp.fujitsu.com> <1290992638.12777.27.camel@sli10-conroe>
Message-Id: <20101129100707.82A2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 29 Nov 2010 10:13:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> ok let me clarify, in the for-loop of balance_pgdat() we reclaim 32
> pages one time. but we have
> if (!all_zones_ok) {
> ...
> 		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> 			order = sc.order = 0;
> 
> 		goto loop_again;
> 	}
> only when sc.nr_reclaimed < SWAP_CLUSTER_MAX or priority < 0, we set
> order to 0. before this, we still use high order for zone_watermark_ok()
> and it will fail and we keep doing page reclaim. So in the proposed
> patch by you or Mel, checking the freed pages or order in kswapd() is
> later. so I suggest we check if there is enough free pages in
> balance_pgdat() and break high order allocation if yes.

Ok, got it. Thanks. But I think Mel's approach is more conservative. I don't
think a lot of order-0 pages are good sign to ignore high order shortage.

I think we should prevent overkill reclaim, but number of order-0 pages
are not related high order overkill.

My point is, many cheap device require high order GFP_ATOMIC allocation
and high order ignorerance may makes system unstabilization on laptop world.

At least, your patch need more conservative guard.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
