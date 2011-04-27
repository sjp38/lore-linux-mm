Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E28C9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:17:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B8F823EE0BC
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:17:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 982B145DE5E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:17:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72BE845DE54
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:17:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 642DEE08003
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:17:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05D6F1DB8047
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:17:06 +0900 (JST)
Date: Wed, 27 Apr 2011 09:10:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
Message-Id: <20110427091030.62a24064.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinnuPnG9+caKaSb5UN9tQ+Hp+Jh3g@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
	<20110426140815.8847062b.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinnuPnG9+caKaSb5UN9tQ+Hp+Jh3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Tue, 26 Apr 2011 16:15:04 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Apr 25, 2011 at 10:08 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > > I see the MEMCG_BGSCAN_LIMIT is a newly defined macro from previous
> > > post. So, now the number of pages to scan is capped on 2k for each
> > > memcg, and does it make difference on big vs small cgroup?
> > >
> >
> > Now, no difference. One reason is because low_watermark - high_watermark is
> > limited to 4MB, at most. It should be static 4MB in many cases and 2048
> > pages
> > is for scanning 8MB, twice of low_wmark - high_wmark. Another reason is
> > that I didn't have enough time for considering to tune this.
> > By MEMCG_BGSCAN_LIMIT, round-robin can be simply fair and I think it's a
> > good start point.
> >
> 
> I can see a problem here to be "fair" to each memcg. Each container has
> different sizes and running with
> different workloads. Some of them are more sensitive with latency than the
> other, so they are willing to pay
> more cpu cycles to do background reclaim.
> 

Hmm, I think care for it can be added easily. But...

> So, here we fix the amount of work per-memcg, and the performance for those
> jobs will be hurt. If i understand
> correctly, we only have one workitem on the workqueue per memcg. So which
> means we can only reclaim those amount of pages for each iteration. And if
> the queue is big, those jobs(heavy memory allocating, and willing to pay cpu
> to do bg reclaim) will hit direct reclaim more than necessary.
> 

But, from measurements, we cannot reclaim enough memory on time if the work
is busy. Can you think of 'make -j 8' doesn't hit the limit by bgreclaim ?

'Working hard' just adds more CPU consumption and results more latency.
>From my point of view, if direct reclaim has problematic costs, bgreclaim is
not easy and slow, too. Then, 'work harder' cannot be help. And spike of
memory consumption can be very rapid. If an application exec an application
which does malloc(2G), under 1G limit memcg, we cannot avoid direct reclaim.

I think the user can set limit higher and distance between limit <-> wmark large.
Then, he can gain more time and avoid hitting direct relcaim. How about enlarging
limit <-> wmark range for performance intensive jobs ?
Amount of work per memcg is limit <-> wmark range, I guess.

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
