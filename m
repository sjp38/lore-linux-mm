Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 472046B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:15:00 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I2Evle031638
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 11:14:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFB5545DE4F
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:14:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B253245DE4D
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:14:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98FBCE38005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:14:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45DC8E78003
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:14:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
References: <20100118104910.AE2D.A69D9226@jp.fujitsu.com> <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
Message-Id: <20100118111337.AE33.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Jan 2010 11:14:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> >> It can make stale data when high memory pressure happens.
> >
> > ?? why? and when?
> > I think it depend on what's stale mean.
> >
> > Currently(i.e. before the patch), get_scan_ratio have following fomula.
> > in such region, recent_scanned is not protected by zone->lru_lock.
> >
> > A  A  A  A ap = (anon_prio + 1) * (reclaim_stat->recent_scanned[0] + 1);
> > A  A  A  A ap /= reclaim_stat->recent_rotated[0] + 1;
> > A  A  A  A fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
> > A  A  A  A fp /= reclaim_stat->recent_rotated[1] + 1;
> > A  A  A  A percent[0] = 100 * ap / (ap + fp + 1);
> > A  A  A  A percent[1] = 100 - percent[0];
> >
> > It mean, shrink_zone() doesn't use exactly recent_scanned value. then
> > zoneinfo can use the same unexactly value.
> 
> Absoultely right. I missed that. Thanks.
> get_scan_ratio used lru_lock to get reclaim_stat->recent_xxxx.
> But, it doesn't used lru_lock to get ap/fp.
> 
> Is it intentional? I think you or Rik know it. :)
> I think if we want to get exact value, we have to use lru_lock until
> getting ap/fp.
> If it isn't, we don't need lru_lock when we get the reclaim_stat->recent_xxxx.
> 
> What do you think about it?

I believe the current code is intentional.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
