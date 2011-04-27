Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBC19000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:54:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1427A3EE0BB
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:54:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEC0D45DE50
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:54:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA8245DE4E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:54:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0B851DB803B
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:54:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A2DE1DB803E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:54:48 +0900 (JST)
Date: Wed, 27 Apr 2011 17:48:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv3] memcg: fix get_scan_count for small targets
Message-Id: <20110427174813.8b34df90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin+rDOWGYq9dg-XcCWs+yT8Yw-VMw@mail.gmail.com>
References: <20110427164708.1143395e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin+rDOWGYq9dg-XcCWs+yT8Yw-VMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 27 Apr 2011 17:48:18 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Apr 27, 2011 at 4:47 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > At memory reclaim, we determine the number of pages to be scanned
> > per zone as
> > A  A  A  A (anon + file) >> priority.
> > Assume
> > A  A  A  A scan = (anon + file) >> priority.
> >
> > If scan < SWAP_CLUSTER_MAX, the scan will be skipped for this time
> > and priority gets higher. This has some problems.
> >
> > A 1. This increases priority as 1 without any scan.
> > A  A  To do scan in this priority, amount of pages should be larger than 512M.
> > A  A  If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan will be
> > A  A  batched, later. (But we lose 1 priority.)
> > A  A  If memory size is below 16M, pages >> priority is 0 and no scan in
> > A  A  DEF_PRIORITY forever.
> >
> > A 2. If zone->all_unreclaimabe==true, it's scanned only when priority==0.
> > A  A  So, x86's ZONE_DMA will never be recoverred until the user of pages
> > A  A  frees memory by itself.
> >
> > A 3. With memcg, the limit of memory can be small. When using small memcg,
> > A  A  it gets priority < DEF_PRIORITY-2 very easily and need to call
> > A  A  wait_iff_congested().
> > A  A  For doing scan before priorty=9, 64MB of memory should be used.
> >
> > Then, this patch tries to scan SWAP_CLUSTER_MAX of pages in force...when
> >
> > A 1. the target is enough small.
> > A 2. it's kswapd or memcg reclaim.
> >
> > Then we can avoid rapid priority drop and may be able to recover
> > all_unreclaimable in a small zones. And this patch removes nr_saved_scan.
> > This will allow scanning in this priority even when pages >> priority
> > is very small.
> >
> > Changelog v2->v3
> > A - removed nr_saved_scan completely.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> The patch looks good to me but I have a nitpick about just coding style.
> How about this? I think below looks better but it's just my private
> opinion and I can't insist on my style. If you don't mind it, ignore.
> 

I did this at the 1st try and got bug.....a variable 'file' here is
reused and now broken. Renaming it with new variable will be ok, but it
seems there will be deep nesting of 'if' and long function names ;)
So, I did as posted. 

Thank you for review.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
