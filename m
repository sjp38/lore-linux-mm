Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EADAE6B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:06:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2EEB83EE0C1
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:06:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC95445DE6E
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:06:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF4F045DE61
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:06:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB5921DB803F
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:06:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88D551DB803A
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:06:08 +0900 (JST)
Message-ID: <4DD31B6E.8040502@jp.fujitsu.com>
Date: Wed, 18 May 2011 10:05:50 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>	<1305295404-12129-5-git-send-email-mgorman@suse.de>	<4DCFAA80.7040109@jp.fujitsu.com>	<1305519711.4806.7.camel@mulgrave.site>	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>	<20110516084558.GE5279@suse.de>	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>	<20110516102753.GF5279@suse.de> <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
In-Reply-To: <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: mgorman@suse.de, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

> It would be better to put cond_resched after balance_pgdat?
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 292582c..61c45d0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2753,6 +2753,7 @@ static int kswapd(void *p)
>                  if (!ret) {
>                          trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
>                          order = balance_pgdat(pgdat, order,&classzone_idx);
> +                       cond_resched();
>                  }
>          }
>          return 0;
>
>>>> While it appears unlikely, there are bad conditions which can result
>> in cond_resched() being avoided.

Every reclaim priority decreasing or every shrink_zone() calling makes more
fine grained preemption. I think.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
