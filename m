Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3A73B6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 02:54:14 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D6sBGk006590
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 15:54:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7821A45DE50
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:54:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 56E6E45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:54:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30B661DB803A
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:54:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0AC1DB803C
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:54:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090313050740.GF16897@balbir.in.ibm.com>
References: <20090313134548.AF50.A69D9226@jp.fujitsu.com> <20090313050740.GF16897@balbir.in.ibm.com>
Message-Id: <20090313145032.AF4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 15:54:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > > My point is, contention case kswapd wakeup. and kswapd reclaim by
> > > global lru order before soft limit shrinking.
> > > Therefore, In typical usage, mem_cgroup_soft_limit_reclaim() almost
> > > don't call properly.
> > > 
> > > soft limit shrinking should run before processing global reclaim.
> > 
> > Do you have the reason of disliking call from kswapd ?
> >
> 
> Yes, I sent that reason out as comments to Kame's patches. kswapd or
> balance_pgdat controls the zones, priority and in effect how many
> pages we scan while doing reclaim. I did lots of experiments and found
> that if soft limit reclaim occurred from kswapd, soft_limit_reclaim
> would almost always fail and shrink_zone() would succeed, since it
> looks at the whole zone and is always able to find some pages at all
> priority levels. It also does not allow for targetted reclaim based on
> how much we exceed the soft limit by. 

hm
I read past discussion. so, I think we discuss many aspect at once.
So, my current thinking is below, 

(1) if the group don't have any soft limit shrinking page, 
    mem_cgroup_soft_limit_reclaim() spent time unnecessary.
    -> right.
      actually, past global reclaim had similar problem.
      then zone_is_all_unreclaimable() was introduced.
      maybe we can use similar technique to memcg.

(2) mem_cgroup_soft_limit_reclaim() should be called from?
    -> under discussion.
       we should solve (1) at first for proper constructive
       discussion.

(3) What's "fairness" of soft limit?
    -> perfectly another aspect.

So, I'd like to discuss (1) at first.
Although we don't kswapd shrinking, (1) is problem.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
