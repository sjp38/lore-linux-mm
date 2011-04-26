Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BECF69000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:53:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2FA953EE0B5
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 08:53:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1436745DE54
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 08:53:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E57A245DE4E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 08:53:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3CC9E78002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 08:53:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E1EE1DB8037
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 08:53:03 +0900 (JST)
Date: Wed, 27 Apr 2011 08:46:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix get_scan_count for working well with small targets
Message-Id: <20110427084622.02305c53.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110426135934.c1992c3e.akpm@linux-foundation.org>
References: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
	<20110426135934.c1992c3e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, Ying Han <yinghan@google.com>

On Tue, 26 Apr 2011 13:59:34 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 26 Apr 2011 18:17:24 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > At memory reclaim, we determine the number of pages to be scanned
> > per zone as
> > 	(anon + file) >> priority.
> > Assume 
> > 	scan = (anon + file) >> priority.
> > 
> > If scan < SWAP_CLUSTER_MAX, shlink_list will be skipped for this
> > priority and results no-sacn.  This has some problems.
> > 
> >   1. This increases priority as 1 without any scan.
> >      To do scan in DEF_PRIORITY always, amount of pages should be larger than
> >      512M. If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan will be
> >      batched, later. (But we lose 1 priority.)
> >      But if the amount of pages is smaller than 16M, no scan at priority==0
> >      forever.
> > 
> >   2. If zone->all_unreclaimabe==true, it's scanned only when priority==0.
> >      So, x86's ZONE_DMA will never be recoverred until the user of pages
> >      frees memory by itself.
> > 
> >   3. With memcg, the limit of memory can be small. When using small memcg,
> >      it gets priority < DEF_PRIORITY-2 very easily and need to call
> >      wait_iff_congested().
> >      For doing scan before priorty=9, 64MB of memory should be used.
> > 
> > This patch tries to scan SWAP_CLUSTER_MAX of pages in force...when
> > 
> >   1. the target is enough small.
> >   2. it's kswapd or memcg reclaim.
> > 
> > Then we can avoid rapid priority drop and may be able to recover
> > all_unreclaimable in a small zones.
> 
> What about simply removing the nr_saved_scan logic and permitting small
> scans?  That simplifies the code and I bet it makes no measurable
> performance difference.
> 

When I considered memcg, I thought of that. But I noticed ZONE_DMA will not
be scanned even if we do so (and zone->all_unreclaimable will not be recovered
until someone free its page by himself.)

> (A good thing to do here would be to instrument the code and determine
> the frequency with which we perform short scans, as well as their
> shortness.  ie: a histogram).
> 

With memcg, I hope we can scan SWAP_CLUSTER_MAX always, at leaset. Considering
a bad case as
  - memory cgroup is small and the system is swapless, file cache is small.
doing SWAP_CLUSETE_MAX file cache scan always seems to make sense to me.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
