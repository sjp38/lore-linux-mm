Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 108C56B005D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 02:54:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4T6tGlb005966
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 May 2009 15:55:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 95C2F45DE4F
	for <linux-mm@kvack.org>; Fri, 29 May 2009 15:55:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D13245DD72
	for <linux-mm@kvack.org>; Fri, 29 May 2009 15:55:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EA551DB8037
	for <linux-mm@kvack.org>; Fri, 29 May 2009 15:55:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 06F3D1DB8045
	for <linux-mm@kvack.org>; Fri, 29 May 2009 15:55:16 +0900 (JST)
Date: Fri, 29 May 2009 15:53:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] add swap cache interface for swap reference v2
 (updated)
Message-Id: <20090529155342.7fcead51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090529150525.cbbb4be1.nishimura@mxp.nes.nec.co.jp>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528141049.cc45a116.kamezawa.hiroyu@jp.fujitsu.com>
	<20090529132153.3a72f2c3.nishimura@mxp.nes.nec.co.jp>
	<20090529140832.1f4b288b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090529143758.4c3db3eb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090529150525.cbbb4be1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 May 2009 15:05:25 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 29 May 2009 14:37:58 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 29 May 2009 14:08:32 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > IIUC, swap_free() at the end of shmem_writepage() should also be changed to swapcache_free().
> > > > 
> > > Hmm!. Oh, yes. shmem_writepage()'s error path. Thank you. It will be fixed.
> > > 
> > here. 
> > 
> Looks good to me.
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> 
> BTW, I'm now testing(with swap-in/out and swap-on/off) [2/4] of this patch set.
> I think this patch set would work well, but it's a big change to swap,
> so we should test them very carefully.
> 
Indeed. 

BTW, even we ignores memcg, they are necessary change for us. ([2/4] and [3/4])

IIUC, I remember a NEC man had a story like below.

1. create 2 cpusets. A and B.
2. At first, tons of swaps are created by "A".
3. After size of applications in A shrinks, pages swapped out by "A" is now on-memory.
4. When running program in B, B can't use enough swaps because "A" uses tons of
   cache-only swaps.

Why swap_entries are not reclaimed in "4" is because cpuset divides the LRU.

I think patch [3/4] can be a sliver bullet to this problem.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
