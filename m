Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6C98D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 05:45:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 85B323EE0BC
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:44:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C77A45DE68
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:44:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EB3F45DE55
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:44:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F83EE08002
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:44:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E45E61DB8038
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:44:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <alpine.DEB.2.00.1104010945190.17929@router.home>
References: <20110401221921.A890.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104010945190.17929@router.home>
Message-Id: <20110403184514.AE4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  3 Apr 2011 18:44:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

> On Fri, 1 Apr 2011, KOSAKI Motohiro wrote:
> 
> > > On Thu, 31 Mar 2011, KOSAKI Motohiro wrote:
> > >
> > > > 1) zone reclaim doesn't work if the system has multiple node and the
> > > >    workload is file cache oriented (eg file server, web server, mail server, et al).
> > > >    because zone recliam make some much free pages than zone->pages_min and
> > > >    then new page cache request consume nearest node memory and then it
> > > >    bring next zone reclaim. Then, memory utilization is reduced and
> > > >    unnecessary LRU discard is increased dramatically.
> > >
> > > That is only true if the webserver only allocates from a single node. If
> > > the allocation load is balanced then it will be fine. It is useful to
> > > reclaim pages from the node where we allocate memory since that keeps the
> > > dataset node local.
> >
> > Why?
> > Scheduler load balancing only consider cpu load. Then, usually memory
> > pressure is no complete symmetric. That's the reason why we got the
> > bug report periodically.
> 
> The scheduler load balancing also considers caching effects. It does not
> consider NUMA effects aside from heuritics though. If processes are
> randomly moving around then zone reclaim is not effective. Processes need
> to stay mainly on a certain node and memory needs to be allocatable from
> that node in order to improve performance. zone_reclaim is useless if you
> toss processes around the box.

Agreed. zone_reclaim has both good and bad work situation.


> > btw, when we are talking about memory distance aware reclaim, we have to
> > recognize traditional numa (ie external node interconnect) and on-chip
> > numa have different performance characteristics. on-chip remote node access
> > is not so slow, then elaborated nearest node allocation effort doesn't have
> > so much worth. especially, a workload use a lot of short lived object.
> > Current zone-reclaim don't have so much issue when using traditiona numa
> > because it's fit your original design and assumption and administrators of
> > such systems have good skill and don't hesitate to learn esoteric knobs.
> > But recent on-chip and cheap numa are used for much different people against
> > past. therefore new issues and claims were raised.
> 
> You can switch NUMA off completely at the bios level. Then the distances
> are not considered by the OS. If they are not relevant then lets just
> switch NUMA off. Managing NUMA distances can cause significant overhead.

1) Some bios don't have such knob. btw, OK, yes, *I* can switch NUMA off completely
because I don't have such bios. 2) bios level turning off makes some side effects,
example, scheduler load balancing don't care numa anymore.

So, your workaround is good for workaround. but it's no solution.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
