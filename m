Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABB976B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 08:56:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5GCvtM4017422
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Jun 2009 21:57:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5983C45DE57
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:57:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22B2145DE4D
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:57:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E3A7E1DB8043
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:57:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CE261DB805D
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:57:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring behaviour more in line with expectations V3
In-Reply-To: <20090615105651.GD23198@csn.ul.ie>
References: <20090615163018.B43A.A69D9226@jp.fujitsu.com> <20090615105651.GD23198@csn.ul.ie>
Message-Id: <20090616202157.99AF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Jun 2009 21:57:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, cl@linux-foundation.org, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi


> > > > vmscan-zone_reclaim-use-may_swap.patch
> > > > 
> > > 
> > > This is a tricky one. Kosaki, I think this patch is a little dangerous. With
> > > this applied, pages get unmapped whether RECLAIM_SWAP is set or not. This
> > > means that zone_reclaim() now has more work to do when it's enabled and it
> > > incurs a number of minor faults for no reason as a result of trying to avoid
> > > going off-node. I don't believe that is desirable because it would manifest
> > > as high minor fault counts on NUMA and would be difficult to pin down why
> > > that was happening.
> > 
> > (cc to hanns)
> > 
> > First, if this patch should be dropped, commit bd2f6199 
> > (vmscan: respect higher order in zone_reclaim()) should be too. I think.
> > the combination of lumply reclaim and !may_unmap is really ineffective.
> 
> Whether it's ineffective or not, it's what the user has asked for. They
> want a high-order page found if possible within the limits of
> zone_reclaim_mode. If it fails, they will enter full direct reclaim
> later in the path and try again.
> 
> How effective lumpy reclaim is in this case really depends on what the
> system has been used for in the past. It's impossible to know in advance
> how effective lumpy reclaim will be in every case.

In general, performance discussion need to concern typical use-case.
Almost zone-reclaim enabled machine is not file server. Thus unmapped file
page are not so high ratio.

I have pessimistic suspection of successful rate of lumpy reclaim in those server.
Of cource, it don't make allocation failure, it only make full direct reclaim.

but I don't hope strange and unnecessary lru shuffling. Also I don't think
it makes performance improvement.


> > it might cause isolate neighbor pages and give up unmapping and pages put
> > back tail of lru.
> > it mean to shuffle lru list.
> > 
> > I don't think it is desirable.
> > 
> 
> With Kamezawa Hiroyuki's patch that avoids unnecessary shuffles of the LRU
> list due to lumpy reclaim, the situation might be better?

I still my_unmap is better choice, but if we use it, I agree with adding
may_unmap and page_mapped() condition to isolate_pages_global() is better and
good choice.

nice idea.

> > Second, we did learned that "mapped or not mapped" is not appropriate
> > reclaim boosting between split-lru discussion.
> > So, I think to make consistent is better. if no considerness of may_unmap
> > makes serious performance issue, we need to fix try_to_free_pages() path too.
> > 
> 
> I don't understand this paragraph.
> 
> If zone_reclaim_mode is set to 1, I don't believe the expected behaviour is
> for pages to be unmapped from page tables. I think it will lead to mysterious
> bug reports of higher numbers of minor faults when running applications on
> NUMA machines in some situations.

AFAIK, 99.9% user read documentation, not actual code. and documentatin
didn't describe so.
I don't think this is expected behavior.

That's my point.


> > Third, if we consider MPI program on NUMA, each process only access
> > a part of array data frequently and never touch rest part of array.
> > So, AFAIK "rarely, but access" is rarely, no freqent access is not major performance source.
> > 
> > I have one question. your "difficultness of pinning down" is major issue?
> > 
> 
> Yes. If an administrator notices that minor fault rates are higher than
> expected, it's going to be very difficult for them to understand why
> it is happening and why setting reclaim_mode to 0 apparently fixes the
> problem. oprofile for example might just show that a lot of time is being
> spent in the fault paths but not explain why.

I don't understand this paragraph a bit. I feel this is only theorical issue.
successing of try_to_unmap_one() mean the pte don't have accessed bit.
it's obvious sign to be able to unmap pte.

if we convice MPI program, long time untouched pages often mean never touched again.
Am I missing anything? or you don't talk about non-hpc workload?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
