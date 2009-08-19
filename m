Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7497A6B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 10:31:27 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7JEVCAm008407
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 00:31:12 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7JEVI1v319646
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 00:31:21 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7JEVHYV010048
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 00:31:18 +1000
Date: Wed, 19 Aug 2009 19:57:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] memcg: move definitions to .h and inline some functions
Message-ID: <20090819142705.GN22626@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost> <20090818224230.A648.A69D9226@jp.fujitsu.com> <20090819134036.GA7267@localhost> <f4131456fc4b1dd4f5b8d060e0cbef80.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <f4131456fc4b1dd4f5b8d060e0cbef80.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-19 23:18:01]:

> Wu Fengguang ?$B$5$s$O=q$-$^$7$?!'
> > On Tue, Aug 18, 2009 at 11:57:52PM +0800, KOSAKI Motohiro wrote:
> >>
> >> > > This one of the reasons why we unconditionally deactivate
> >> > > the active anon pages, and do background scanning of the
> >> > > active anon list when reclaiming page cache pages.
> >> > >
> >> > > We want to always move some pages to the inactive anon
> >> > > list, so it does not get too small.
> >> >
> >> > Right, the current code tries to pull inactive list out of
> >> > smallish-size state as long as there are vmscan activities.
> >> >
> >> > However there is a possible (and tricky) hole: mem cgroups
> >> > don't do batched vmscan. shrink_zone() may call shrink_list()
> >> > with nr_to_scan=1, in which case shrink_list() _still_ calls
> >> > isolate_pages() with the much larger SWAP_CLUSTER_MAX.
> >> >
> >> > It effectively scales up the inactive list scan rate by 10 times when
> >> > it is still small, and may thus prevent it from growing up for ever.
> >> >
> >> > In that case, LRU becomes FIFO.
> >> >
> >> > Jeff, can you confirm if the mem cgroup's inactive list is small?
> >> > If so, this patch should help.
> >>
> >> This patch does right thing.
> >> However, I would explain why I and memcg folks didn't do that in past
> >> days.
> >>
> >> Strangely, some memcg struct declaration is hide in *.c. Thus we can't
> >> make inline function and we hesitated to introduce many function calling
> >> overhead.
> >>
> >> So, Can we move some memcg structure declaration to *.h and make
> >> mem_cgroup_get_saved_scan() inlined function?
> >
> > OK here it is. I have to move big chunks to make it compile, and it
> > does reduced a dozen lines of code :)
> >
> > Is this big copy&paste acceptable? (memcg developers CCed).
> >
> > Thanks,
> > Fengguang
> 
> I don't like this. plz add hooks to necessary places, at this stage.
> This will be too big for inlined function, anyway.
> plz move this after you find overhead is too big.

Me too.. I want to abstract the implementation within memcontrol.c to
be honest (I am concerned that someone might include memcontrol.h and
access its structure members, which scares me). Hiding it within
memcontrol.c provides the right level of abstraction.

Could you please explain your motivation for this change? I got cc'ed
on to a few emails, is this for the patch that export nr_save_scanned
approach?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
