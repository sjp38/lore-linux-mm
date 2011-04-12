Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CDAE58D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 21:04:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 64DB83EE0C0
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:04:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F7D12E68E5
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:04:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0935D45DE52
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:04:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E9BBAE7800C
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:04:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98DE6E78005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:04:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
In-Reply-To: <20110411145324.ca790260.akpm@linux-foundation.org>
References: <20110411143128.0070.A69D9226@jp.fujitsu.com> <20110411145324.ca790260.akpm@linux-foundation.org>
Message-Id: <20110412100417.43F2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 10:04:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi

> > zone->all_unreclaimable and zone->pages_scanned are neigher atomic
> > variables nor protected by lock. Therefore zones can become a state
> > of zone->page_scanned=0 and zone->all_unreclaimable=1. In this case,
> > current all_unreclaimable() return false even though
> > zone->all_unreclaimabe=1.
> > 
> > Is this ignorable minor issue? No. Unfortunatelly, x86 has very
> > small dma zone and it become zone->all_unreclamble=1 easily. and
> > if it become all_unreclaimable=1, it never restore all_unreclaimable=0.
> > Why? if all_unreclaimable=1, vmscan only try DEF_PRIORITY reclaim and
> > a-few-lru-pages>>DEF_PRIORITY always makes 0. that mean no page scan
> > at all!
> > 
> > Eventually, oom-killer never works on such systems. That said, we
> > can't use zone->pages_scanned for this purpose. This patch restore
> > all_unreclaimable() use zone->all_unreclaimable as old. and in addition,
> > to add oom_killer_disabled check to avoid reintroduce the issue of
> > commit d1908362.
> 
> The above is a nice analysis of the bug and how it came to be
> introduced.  But we don't actually have a bug description!  What was
> the observeable problem which got fixed?

The above says "Eventually, oom-killer never works". Is this no enough?
The above says
  1) current logic have a race
  2) x86 increase a chance of the race by dma zone
  3) if race is happen, oom killer don't work

> 
> Such a description will help people understand the importance of the
> patch and will help people (eg, distros) who are looking at a user's
> bug report and wondering whether your patch will fix it.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
