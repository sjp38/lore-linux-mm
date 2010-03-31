Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E28096B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 01:53:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V5rUgg003270
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 31 Mar 2010 14:53:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5939B45DE60
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:53:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D48845DE6E
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:53:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 00BA51DB803F
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:53:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FAECE1800A
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:53:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100331142708.039E.A69D9226@jp.fujitsu.com>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com> <20100331142708.039E.A69D9226@jp.fujitsu.com>
Message-Id: <20100331145030.03A1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 31 Mar 2010 14:53:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > completely skip anon pages and cause oops.
> > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > to 1. See below patch.
> > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > It's required to fix this too.
> > > 
> > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > 
> > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > had similar logic, but 1% swap-out made lots bug reports. 
> > if 1% is still big, how about below patch?
> 
> This patch makes a lot of sense than previous. however I think <1% anon ratio
> shouldn't happen anyway because file lru doesn't have reclaimable pages.
> <1% seems no good reclaim rate.

Oops, the above mention is wrong. sorry. only 1 page is still too big.
because under streaming io workload, the number of scanning anon pages should
be zero. this is very strong requirement. if not, backup operation will makes
a lot of swapping out.

Anyway, I'm digging this issue.


> 
> perhaps I'll take your patch for stable tree. but we need to attack the root
> cause. iow, I guess we need to fix scan ratio equation itself.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
