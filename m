Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DC5416B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 01:17:07 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7K5BU9R028770
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 10:41:30 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7K5Gx7R1847540
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 10:47:01 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7K5GwJt012030
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 15:16:58 +1000
Date: Thu, 20 Aug 2009 10:46:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -v2] mm: do batched scans for mem_cgroup
Message-ID: <20090820051656.GB26265@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090820024929.GA19793@localhost> <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com> <20090820040533.GA27540@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090820040533.GA27540@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

* Wu Fengguang <fengguang.wu@intel.com> [2009-08-20 12:05:33]:

> On Thu, Aug 20, 2009 at 11:13:47AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Thu, 20 Aug 2009 10:49:29 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> > > in which case shrink_list() _still_ calls isolate_pages() with the much
> > > larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
> > > scan rate by up to 32 times.
> > > 
> > > For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> > > So when shrink_zone() expects to scan 4 pages in the active/inactive
> > > list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> > > 
> > > The accesses to nr_saved_scan are not lock protected and so not 100%
> > > accurate, however we can tolerate small errors and the resulted small
> > > imbalanced scan rates between zones.
> > > 
> > > This batching won't blur up the cgroup limits, since it is driven by
> > > "pages reclaimed" rather than "pages scanned". When shrink_zone()
> > > decides to cancel (and save) one smallish scan, it may well be called
> > > again to accumulate up nr_saved_scan.
> > > 
> > > It could possibly be a problem for some tiny mem_cgroup (which may be
> > > _full_ scanned too much times in order to accumulate up nr_saved_scan).
> > > 
> > > CC: Rik van Riel <riel@redhat.com>
> > > CC: Minchan Kim <minchan.kim@gmail.com>
> > > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > 
> > Hmm, how about this ? 
> > ==
> > Now, nr_saved_scan is tied to zone's LRU.
> > But, considering how vmscan works, it should be tied to reclaim_stat.
> > 
> > By this, memcg can make use of nr_saved_scan information seamlessly.
> 
> Good idea, full patch updated with your signed-off-by :)
> 
> Thanks,
> Fengguang
> ---
> mm: do batched scans for mem_cgroup
> 
> For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=1,
> in which case shrink_list() _still_ calls isolate_pages() with the much
> larger SWAP_CLUSTER_MAX.  It effectively scales up the inactive list
> scan rate by up to 32 times.
> 
> For example, with 16k inactive pages and DEF_PRIORITY=12, (16k >> 12)=4.
> So when shrink_zone() expects to scan 4 pages in the active/inactive
> list, it will be scanned SWAP_CLUSTER_MAX=32 pages in effect.
> 
> The accesses to nr_saved_scan are not lock protected and so not 100%
> accurate, however we can tolerate small errors and the resulted small
> imbalanced scan rates between zones.
> 
> This batching won't blur up the cgroup limits, since it is driven by
> "pages reclaimed" rather than "pages scanned". When shrink_zone()
> decides to cancel (and save) one smallish scan, it may well be called
> again to accumulate up nr_saved_scan.
> 
> It could possibly be a problem for some tiny mem_cgroup (which may be
> _full_ scanned too much times in order to accumulate up nr_saved_scan).
>

Looks good to me, how did you test it?

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
