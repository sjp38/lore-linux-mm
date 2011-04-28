Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DAF386B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 05:08:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8DBC43EE081
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:08:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70BAC45DE4E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:08:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D63D45DD74
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:08:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ECC21DB802C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:08:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0B3F1DB803A
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:08:13 +0900 (JST)
Date: Thu, 28 Apr 2011 18:01:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-Id: <20110428180139.6ec67196.kamezawa.hiroyu@jp.fujitsu.com>
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
> > A  A  A  A soft_steal 0
> > A  A  A  A limit_scan 43974
> > A  A  A  A soft_scan 0
> > A  A  A  A limit_latency 133837417
> >
> > nearly 96M caches are freed. scanned twice. used 133ms.
> 
> Does it make sense to split up the soft_steal/scan for bg reclaim and
> direct reclaim? The same for the limit_steal/scan. I am now testing
> the patch to add the soft_limit reclaim on global ttfp, and i already
> have the patch to add the following:
> 
> kswapd_soft_steal 0
> kswapd_soft_scan 0
> direct_soft_steal 0
> direct_soft_scan 0
> kswapd_steal 0
> pg_pgsteal 0
> kswapd_pgscan 0
> pg_scan 0
> 

I'll not post updated version until the end of holidays but my latest plan is
adding


limit_direct_free   - # of pages freed by limit in foreground (not stealed, you freed by yourself's limit)
soft_kswapd_steal   - # of pages stealed by kswapd based on soft limit
limit_direct_scan   - # of pages scanned by limit in foreground
soft_kswapd_scan    - # of pages scanned by kswapd based on soft limit

And then, you can add

soft_direct_steal     - # of pages stealed by foreground reclaim based on soft limit
soft_direct_scan        - # of pages scanned by foreground reclaim based on soft limit

And

kern_direct_steal  - # of pages stealed by foreground reclaim at memory shortage.
kern_direct_scan   - # of pages scanned by foreground reclaim at memory shortage.
kern_direct_steal  - # of pages stealed by kswapd at memory shortage
kern_direct_scan   - # of pages scanned by kswapd at memory shortage

(Above kern_xxx number includes soft_xxx in it. ) These will show influence by
other cgroups.

And

wmark_bg_free      - # of pages freed by watermark in background(not kswapd)
wmark_bg_scan      - # of pages scanned by watermark in background(not kswapd)

Hmm ? too many stats ;) 

And making current soft_steal/soft_scan planned to be obsolete...
 
Thanks,
-Kame




















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
