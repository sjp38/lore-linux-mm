Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B6FA6B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 20:04:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I14HH5007758
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 10:04:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ADDE45DE70
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:04:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E519245DD70
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:04:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C8D1C1DB8037
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:04:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 751BD1DB803F
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:04:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <28c262361001150923l138f6805t22546887bf81b283@mail.gmail.com>
References: <20100114141735.672B.A69D9226@jp.fujitsu.com> <28c262361001150923l138f6805t22546887bf81b283@mail.gmail.com>
Message-Id: <20100118100359.AE22.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Jan 2010 10:04:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Hi, KOSAKI.
> 
> On Thu, Jan 14, 2010 at 2:18 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > Well. zone->lock and zone->lru_lock should be not taked at the same time.
> >>
> >> I looked over the code since I am out of office.
> >> I can't find any locking problem zone->lock and zone->lru_lock.
> >> Do you know any locking order problem?
> >> Could you explain it with call graph if you don't mind?
> >>
> >> I am out of office by tomorrow so I can't reply quickly.
> >> Sorry for late reponse.
> >
> > This is not lock order issue. both zone->lock and zone->lru_lock are
> > hotpath lock. then, same tame grabbing might cause performance impact.
> 
> Sorry for late response.
> 
> Your patch makes get_anon_scan_ratio of zoneinfo stale.
> What you said about performance impact is effective when VM pressure high.
> I think stale data is all right normally.
> But when VM pressure is high and we want to see the information in zoneinfo(
> this case is what you said), stale data is not a good, I think.
> 
> If it's not a strong argue, I want to use old get_scan_ratio
> in get_anon_scan_ratio.

please looks such function again.

usally we use recent_rotated/recent_scanned ratio. then following
decreasing doesn't change any scan-ratio meaning. it only prevent
stat overflow.

        if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
                spin_lock_irq(&zone->lru_lock);
                reclaim_stat->recent_scanned[0] /= 2;
                reclaim_stat->recent_rotated[0] /= 2;
                spin_unlock_irq(&zone->lru_lock);
        }


So, I don't think current implementation can show stale data.

Thanks.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
