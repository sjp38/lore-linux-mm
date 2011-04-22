Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC7518D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 03:53:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 357553EE0C3
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 16:53:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DCF945DE56
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 16:53:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE63645DE5B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 16:53:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9C7D1DB8043
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 16:53:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A6761DB8046
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 16:53:04 +0900 (JST)
Date: Fri, 22 Apr 2011 16:46:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
Message-Id: <20110422164622.a8350bc5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
	<20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim91aHXjqfukn6rJxK0SDSSG2wrrg@mail.gmail.com>
	<20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 23:10:58 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, Apr 21, 2011 at 10:59 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 21 Apr 2011 22:53:19 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > On Thu, Apr 21, 2011 at 10:00 PM, KAMEZAWA Hiroyuki <
> > > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >
> > > > On Thu, 21 Apr 2011 21:49:04 -0700
> > > > Ying Han <yinghan@google.com> wrote:
> > > >
> > > > > On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
> > > > > kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > add a counter for kswapd-scan and kswapd-reclaim, kswapd-pickup will show
> > you information, if necessary it's good to show some latecy stat. I think
> > we can add enough information by adding stats (or debug by perf tools.)
> > I'll consider this a a bit more.
> >
> 
> Something like "kswapd_pgscan" and "kswapd_steal" per memcg? If we are going
> to the thread-pool, we definitely need to add more stats to give us enough
> visibility of per-memcg background reclaim activity. Still, not sure about
> the cpu-cycles.
> 

BTW, Kosaki requeted me not to have private thread pool implementation and
use workqueue. I think he is right. So, I'd like to write a patch to enhance
workqueue for using it for memcg (Of couse, I'll make a private workqueue.)


==
2. regarding to the alternative workqueue, which is more complicated and we
need to be very careful of work items in the workqueue. We've experienced in
one workitem stucks and the rest of the work item won't proceed. For example
in dirty page writeback, one heavily writer cgroup could starve the other
cgroups from flushing dirty pages to the same disk. In the kswapd case, I can
imagine we might have similar senario. How to prioritize the workitems is
another problem. The order of adding the workitems in the queue reflects the
order of cgroups being reclaimed. We don't have that restriction currently but
relying on the cpu scheduler to put kswapd on the right cpu-core to run. We
"might" introduce priority later for reclaim and how are we gonna deal with
that.
==

>From this, I feel I need to use unbound workqueue. BTW, with patches for
current thread pool model, I think starvation problem by dirty pages
cannot be seen.
Anyway, I'll give a try.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
