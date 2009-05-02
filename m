Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9D5ED6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 22:55:59 -0400 (EDT)
Date: Sat, 2 May 2009 11:56:49 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090502115649.027e4a88.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090501183256.GD4686@balbir.in.ibm.com>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430094252.GG4430@balbir.in.ibm.com>
	<20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430181246.GM4430@balbir.in.ibm.com>
	<20090501133317.9c372d38.d-nishimura@mtf.biglobe.ne.jp>
	<20090501183256.GD4686@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, d-nishimura@mtf.biglobe.ne.jp, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

> > > Daisuke in the race conditions mentioned is (2) significant? Since the
> > > accounting is already fixed during mem_cgroup_uncharge_page()?
> > > 
> > Do you mean type-2 stale swap caches I described before ?
> > 
> > They doesn't pressure mem.usage nor memsw.usage as you say,
> > but consumes swp_entry(of cource, type-1 has this problem too).
> > As a result, all the swap space can be used up and causes OOM.
> > 
> 
> Good point..
> 
> > I've verified it long ago by:
> > 
> > - make swap space small(50MB).
> > - set mem.limit(32MB).
> > - run some programs(allocate, touch sometimes, exit) enough to
> >   exceed mem.limit repeatedly(I used page01 included in ltp and run
> >   5 instances 8MB per each in cpuset with 4cpus.).
> > - wait for a very long time :) (2,30 hours IIRC)
> >   You can see the usage of swap cache(grep SwapCached /proc/meminfo)
> >   increasing gradually.
> > 
> > 
> > BTW, I'm now testing a attached patch to fix type-2 with setting page-cluster
> > to 0 to aboid type-1, and seeing what happens in the usage of swap cache.
> > (I can't test it in large box though, because my office is closed till May 06.)
> > 
In my small box(i386/2CPU/2GB mem), a similar test shows after 12H
about 600MB leak of swap cache before applying this patch,
while no outstanding leak can be seen after it.

(snip)

> Looking through the patch, I have my doubts
> 
>  shrink_page_list() will catch the page - how? It is not on memcg's
> LRU, so if we have a small cgroup with lots of memory, when the cgroup
> is running out of memory, will this page show up in
> shrink_page_list()?
> 
It's just because the page has not been uncharged yet when shrink_page_list()
is called(,more precicely, when shrink_inactive_list() isolates the page),
so it can be handled in memcg's LRU scanning.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
