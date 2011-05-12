Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB916B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 21:41:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8F79C3EE0BB
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:41:44 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7681F45DE94
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:41:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CFE845DE52
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:41:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C89B1DB8041
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:41:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D3AB1DB803F
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:41:44 +0900 (JST)
Date: Thu, 12 May 2011 10:35:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110511182844.d128c995.akpm@linux-foundation.org>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 11 May 2011 18:28:44 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 10 May 2011 19:02:16 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Hi, thank you for all comments on previous patches for watermarks for memcg.
> > 
> > This is a new series as 'async reclaim', no watermark.
> > This version is a RFC again and I don't ask anyone to test this...but
> > comments/review are appreciated. 
> > 
> > Major changes are
> >   - no configurable watermark
> >   - hierarchy support
> >   - more fix for static scan rate round robin scanning of memcg.
> > 
> > (assume x86-64 in following.)
> > 
> > 'async reclaim' works when
> >    - usage > limit - 4MB.
> > until
> >    - usage < limit - 8MB.
> > 
> > when the limit is larger than 128MB. This value of margin to limit
> > has some purpose for helping to reduce page fault latency at using
> > Transparent hugepage.
> > 
> > Considering THP, we need to reclaim HPAGE_SIZE(2MB) of pages when we hit
> > limit and consume HPAGE_SIZE(2MB) immediately. Then, the application need to
> > scan 2MB per each page fault and get big latency. So, some margin > HPAGE_SIZE
> > is required. I set it as 2*HPAGE_SIZE/4*HPAGE_SIZE, here. The kernel
> > will do async reclaim and reduce usage to limit - 8MB in background.
> > 
> > BTW, when an application gets a page, it tend to do some action to fill the
> > gotton page. For example, reading data from file/network and fill buffer.
> > This implies the application will have a wait or consumes cpu other than
> > reclaiming memory. So, if the kernel can help memory freeing in background
> > while application does another jobs, application latency can be reduced.
> > Then, this kind of asyncronous reclaim of memory will be a help for reduce
> > memory reclaim latency by memcg. But the total amount of cpu time consumed
> > will not have any difference.
> > 
> > This patch series implements
> >   - a logic for trigger async reclaim
> >   - help functions for async reclaim
> >   - core logic for async reclaim, considering memcg's hierarchy.
> >   - static scan rate memcg reclaim.
> >   - workqueue for async reclaim.
> > 
> > Some concern is that I didn't implement a code for handle the case
> > most of pages are mlocked or anon memory in swapless system. I need some
> > detection logic to avoid hopless async reclaim.
> > 
> 
> What (user-visible) problem is this patchset solving?
> 
> IOW, what is the current behaviour, what is wrong with that behaviour
> and what effects does the patchset have upon that behaviour?
> 
> The sole answer from the above is "latency spikes".  Anything else?
> 

I think this set has possibility to fix latency spike. 

For example, in previous set, (which has tuning knobs), do a file copy
of 400M file under 400M limit.
==
1) == hard limit = 400M ==
[root@rhel6-test hilow]# time cp ./tmpfile xxx                
real    0m7.353s
user    0m0.009s
sys     0m3.280s

2) == hard limit 500M/ hi_watermark = 400M ==
[root@rhel6-test hilow]# time cp ./tmpfile xxx

real    0m6.421s
user    0m0.059s
sys     0m2.707s
==
and in both case, memory usage after test was 400M.

IIUC, this speed up is because memory reclaim runs in background file 'cp'
read/write files. But above test uses 100MB of margin. I gues we don't need
100MB of margin as above but will not get full speed with 8MB margin. There 
will be trade-off because users may want to use memory up to the limit. 

So, this set tries to set some 'default' margin, which is not too big and has
idea that implements async reclaim without tuning knobs. I'll measure
some more and report it in the next post.


> Have these spikes been observed and measured?  We should have a
> testcase/worload with quantitative results to demonstrate and measure
> the problem(s), so the effectiveness of the proposed solution can be
> understood.
> 
> 

Yes, you're right, of course.
This set just shows the design changes caused by removing tuning knobs as
a result of long discussion. 

As an output of it, we do
 1. impleimenting async reclaim without tuning knobs.
 2. add some on-demand background reclaim as 'active softlimit', which means
    a mode of softlimit, shrinking memory always even if the system has plenty of
    free memory. And current softlimit, which works only when memory are in short,
    will be called as 'passive softlimit'.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
