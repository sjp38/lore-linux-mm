Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 87A466B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:27:00 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2D6wer7020981
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:28:40 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D7NfA13952712
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:53:41 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2D7Qrxd000958
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:26:54 +1100
Date: Fri, 13 Mar 2009 12:56:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313072649.GM16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090313145032.AF4D.A69D9226@jp.fujitsu.com> <20090313070340.GI16897@balbir.in.ibm.com> <20090313160632.683D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313160632.683D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 16:17:25]:

> > > hm
> > > I read past discussion. so, I think we discuss many aspect at once.
> > > So, my current thinking is below, 
> > > 
> > > (1) if the group don't have any soft limit shrinking page, 
> > >     mem_cgroup_soft_limit_reclaim() spent time unnecessary.
> > >     -> right.
> > 
> > If the soft limit RB tree is empty, we don't spend any time at all.
> > Are you referring to something else? Am I missing something? The tree
> > will be empty if no group is over the soft limit.
> 
> maybe, I am missing anything.
> May I ask your following paragraph meaning?
> 
> 
> > I experimented a *lot* with zone reclaim and found it to be not so
> > effective. Here is why
> > 
> > 1. We have no control over priority or how much to scan, that is
> > controlled by balance_pgdat(). If we find that we are unable to scan
> > anything, we continue scanning with the scan > 0 check, but we scan
> > the same pages and the same number, because shrink_zone does scan >>
> > priority.
> 
> I thought this sentense mean soft-limit-shrinking spent a lot of time.
> if not, could you please tell me what makes so slower?
> 

Let me summarize below


> and, you wrote:
> 
> > 
> > Yes, I sent that reason out as comments to Kame's patches. kswapd or
> > balance_pgdat controls the zones, priority and in effect how many
> > pages we scan while doing reclaim. I did lots of experiments and found
> > that if soft limit reclaim occurred from kswapd, soft_limit_reclaim
> > would almost always fail and shrink_zone() would succeed, since it
> > looks at the whole zone and is always able to find some pages at all
> > priority levels. It also does not allow for targetted reclaim based on
> > how much we exceed the soft limit by. 
> 
> but, if "soft_limit_reclaim fail and shrink_zone() succeed" don't cause
> any performance degression, I don't find why kswapd is wrong.
> 
> I guess you and kamezawa-san know it detail. but my understanding don't reach it.
> Could you please tell me what so slowness.

Here is what I saw in my experiments

1. Kame's scan logic, selects shrink_zone for the mem cgroup, but the
   pages scanned and reclaimed from depend on priority and watermarks
   of the zone and *not* at all on the soft limit parameters.
2. Because soft limit reclaim fails to reclaim anythoing (due to 1),
   shrink_zone which is called, does reclaiming indepedent of any
   knowledge of soft limits, which does not work as expected.



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
