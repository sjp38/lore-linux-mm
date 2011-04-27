Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 098659000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:08:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C76373EE0C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:08:02 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ABC8145DE50
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:08:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 817A045DE4D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:08:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C83E78007
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:08:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41AC7E78002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:08:02 +0900 (JST)
Date: Wed, 27 Apr 2011 10:01:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] memcg bgreclaim core.
Message-Id: <20110427100127.903f6c26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110427091030.62a24064.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinn5Cs8F5beX6od41xhH4qQuRR5Rw@mail.gmail.com>
	<20110426140815.8847062b.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinnuPnG9+caKaSb5UN9tQ+Hp+Jh3g@mail.gmail.com>
	<20110427091030.62a24064.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Wed, 27 Apr 2011 09:10:30 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 26 Apr 2011 16:15:04 -0700
> Ying Han <yinghan@google.com> wrote:
> > So, here we fix the amount of work per-memcg, and the performance for those
> > jobs will be hurt. If i understand
> > correctly, we only have one workitem on the workqueue per memcg. So which
> > means we can only reclaim those amount of pages for each iteration. And if
> > the queue is big, those jobs(heavy memory allocating, and willing to pay cpu
> > to do bg reclaim) will hit direct reclaim more than necessary.
> > 
> 
> But, from measurements, we cannot reclaim enough memory on time if the work
> is busy. Can you think of 'make -j 8' doesn't hit the limit by bgreclaim ?
> 
> 'Working hard' just adds more CPU consumption and results more latency.
> From my point of view, if direct reclaim has problematic costs, bgreclaim is
> not easy and slow, too. Then, 'work harder' cannot be help. And spike of
> memory consumption can be very rapid. If an application exec an application
> which does malloc(2G), under 1G limit memcg, we cannot avoid direct reclaim.
> 
> I think the user can set limit higher and distance between limit <-> wmark large.
> Then, he can gain more time and avoid hitting direct relcaim. How about enlarging
> limit <-> wmark range for performance intensive jobs ?
> Amount of work per memcg is limit <-> wmark range, I guess.
> 

BTW, in another idea, I wonder I should limit work iterms by reducing max_active
because it may burn cpu. If we need, we can have 2 workqueues of high/low priority.
high workqueue has big max_active(0?) and low workqueue has small max_active.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
