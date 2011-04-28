Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A23766B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:04:22 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2E2253EE0C1
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:04:17 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1335F45DE50
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:04:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E862945DE4F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:04:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC0E61DB8037
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:04:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 997911DB802F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:04:16 +0900 (JST)
Date: Thu, 28 Apr 2011 12:57:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-Id: <20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 27 Apr 2011 20:43:58 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 27, 2011 at 8:16 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > sorry, I had wrong TO:...
> >
> > Begin forwarded message:
> >
> > Date: Thu, 28 Apr 2011 12:02:34 +0900
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > To: linux-mm@vger.kernel.org
> > Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
> > Subject: [PATCH] memcg: add reclaim statistics accounting
> >
> >
> >
> > Now, memory cgroup provides poor reclaim statistics per memcg. This
> > patch adds statistics for direct/soft reclaim as the number of
> > pages scans, the number of page freed by reclaim, the nanoseconds of
> > latency at reclaim.
> >
> > It's good to add statistics before we modify memcg/global reclaim, largely.
> > This patch refactors current soft limit status and add an unified update logic.
> >
> > For example, After #cat 195Mfile > /dev/null under 100M limit.
> > A  A  A  A # cat /cgroup/memory/A/memory.stat
> > A  A  A  A ....
> > A  A  A  A limit_freed 24592
> 
> why not "limit_steal" ?
> 

It's not "stealed". Freed by itself.
pages reclaimed by soft-limit is stealed because of global memory pressure.
I don't like the name "steal" but I can't change it because of API breakage.


> > A  A  A  A soft_steal 0
> > A  A  A  A limit_scan 43974
> > A  A  A  A soft_scan 0
> > A  A  A  A limit_latency 133837417
> >
> > nearly 96M caches are freed. scanned twice. used 133ms.
> 
> Does it make sense to split up the soft_steal/scan for bg reclaim and
> direct reclaim? 

Please clarify what you're talking about before asking. Maybe you want to say
"I'm now working for supporting softlimit in direct reclaim path. So, does
 it make sense to account direct/kswapd works in statistics ?"

I think bg/direct reclaim is not required to be splitted.

> The same for the limit_steal/scan. 

limit has only direct reclaim, now. And this is independent from any
soft limit works.

> I am now testing
> the patch to add the soft_limit reclaim on global ttfp, and i already
> have the patch to add the following:
> 
> kswapd_soft_steal 0
> kswapd_soft_scan 0

please don't change the name of _used_ statisitcs.


> direct_soft_steal 0
> direct_soft_scan 0

Maybe these are new ones added by your work. But should be merged to
soft_steal/soft_scan.

> kswapd_steal 0
> pg_pgsteal 0
> kswapd_pgscan 0
> pg_scan 0
> 

Maybe this indicates reclaimed-by-other-tasks-than-this-memcg. Right ?
Maybe good for checking isolation of memcg, hmm, can these be accounted
in scalable way ?

BTW, my office will be closed for a week because of holidays. So, I'll not make
responce tomorrow. please CC kamezawa.hiroyuki@gmail.com if you need.
I may read e-mails.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
