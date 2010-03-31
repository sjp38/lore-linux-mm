Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 252106B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 02:00:59 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V60uiZ026733
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 31 Mar 2010 15:00:56 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 600FB45DE52
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:00:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D1EB45DE4E
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:00:56 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 238BBE18001
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:00:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CA423E1800A
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:00:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100331055108.GA21963@localhost>
References: <20100331142708.039E.A69D9226@jp.fujitsu.com> <20100331055108.GA21963@localhost>
Message-Id: <20100331145602.03A7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 31 Mar 2010 15:00:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> KOSAKI-san,
> 
> On Wed, Mar 31, 2010 at 01:38:12PM +0800, KOSAKI Motohiro wrote:
> > > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > > Hi
> > > > 
> > > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > > completely skip anon pages and cause oops.
> > > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > > to 1. See below patch.
> > > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > > It's required to fix this too.
> > > > 
> > > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > > 
> > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > if 1% is still big, how about below patch?
> > 
> > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > <1% seems no good reclaim rate.
> > 
> > perhaps I'll take your patch for stable tree. but we need to attack the root
> > cause. iow, I guess we need to fix scan ratio equation itself.
> 
> I tend to regard this patch as a general improvement for both
> .33-stable and .34. 
> 
> I do agree with you that it's desirable to do more test&analyze and
> check further for possibly hidden problems.

Yeah, I don't want ignore .33-stable too. if I can't find the root cause
in 2-3 days, I'll revert guilty patch anyway.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
