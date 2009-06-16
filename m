Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DC2AD6B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 09:43:06 -0400 (EDT)
Date: Tue, 16 Jun 2009 14:44:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
	behaviour more in line with expectations V3
Message-ID: <20090616134423.GD14241@csn.ul.ie>
References: <20090615163018.B43A.A69D9226@jp.fujitsu.com> <20090615105651.GD23198@csn.ul.ie> <20090616202157.99AF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090616202157.99AF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, cl@linux-foundation.org, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 09:57:53PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> 
> > > > > vmscan-zone_reclaim-use-may_swap.patch
> > > > > 
> > > > 
> > > > This is a tricky one. Kosaki, I think this patch is a little dangerous. With
> > > > this applied, pages get unmapped whether RECLAIM_SWAP is set or not. This
> > > > means that zone_reclaim() now has more work to do when it's enabled and it
> > > > incurs a number of minor faults for no reason as a result of trying to avoid
> > > > going off-node. I don't believe that is desirable because it would manifest
> > > > as high minor fault counts on NUMA and would be difficult to pin down why
> > > > that was happening.
> > > 
> > > (cc to hanns)
> > > 
> > > First, if this patch should be dropped, commit bd2f6199 
> > > (vmscan: respect higher order in zone_reclaim()) should be too. I think.
> > > the combination of lumply reclaim and !may_unmap is really ineffective.
> > 
> > Whether it's ineffective or not, it's what the user has asked for. They
> > want a high-order page found if possible within the limits of
> > zone_reclaim_mode. If it fails, they will enter full direct reclaim
> > later in the path and try again.
> > 
> > How effective lumpy reclaim is in this case really depends on what the
> > system has been used for in the past. It's impossible to know in advance
> > how effective lumpy reclaim will be in every case.
> 
> In general, performance discussion need to concern typical use-case.

What typical use case? zone_reclaim logic is enabled by default on NUMA
machines that report a large latency for remote node access. I do not
believe we can draw conclusions on what a typical use case is just
because the machine happens to be a particular NUMA type.

And this isn't a performance discussion as such either. The patch isn't
going to improve performance. I believe it'll have the opposite effect.

> Almost zone-reclaim enabled machine is not file server. Thus unmapped file
> page are not so high ratio.
> 
> I have pessimistic suspection of successful rate of lumpy reclaim in those server.

While I agree on that particular case, I don't think it justifies the patch
to unmap pages so easily just because zone_reclaim() is enabled.

> Of cource, it don't make allocation failure, it only make full direct reclaim.
> 
> but I don't hope strange and unnecessary lru shuffling. Also I don't think
> it makes performance improvement.
> 

I'm all for avoiding unnecessary LRU shuffling

> > > it might cause isolate neighbor pages and give up unmapping and pages put
> > > back tail of lru.
> > > it mean to shuffle lru list.
> > > 
> > > I don't think it is desirable.
> > > 
> > 
> > With Kamezawa Hiroyuki's patch that avoids unnecessary shuffles of the LRU
> > list due to lumpy reclaim, the situation might be better?
> 
> I still my_unmap is better choice, but if we use it, I agree with adding
> may_unmap and page_mapped() condition to isolate_pages_global() is better and
> good choice.
> 
> nice idea.
> 

Ok, I agree that lumpy reclaim should be checking may_unmap and page_mapped()
but I still don't think that means that reclaim_mode of 1 allows zone_reclaim()
to unmap pages.

> > > Second, we did learned that "mapped or not mapped" is not appropriate
> > > reclaim boosting between split-lru discussion.
> > > So, I think to make consistent is better. if no considerness of may_unmap
> > > makes serious performance issue, we need to fix try_to_free_pages() path too.
> > > 
> > 
> > I don't understand this paragraph.
> > 
> > If zone_reclaim_mode is set to 1, I don't believe the expected behaviour is
> > for pages to be unmapped from page tables. I think it will lead to mysterious
> > bug reports of higher numbers of minor faults when running applications on
> > NUMA machines in some situations.
> 
> AFAIK, 99.9% user read documentation, not actual code. and documentatin
> didn't describe so.
> I don't think this is expected behavior.
> 
> That's my point.
> 

Which part of the documentation for zone_reclaim_mode == 1 implies that
pages will be unmapped from page tables? If the documentation is misleading,
I would prefer for it to be fixed up than pages be unmapped by default
causing performance regressions due to increased minor faults on NUMA.

> 
> > > Third, if we consider MPI program on NUMA, each process only access
> > > a part of array data frequently and never touch rest part of array.
> > > So, AFAIK "rarely, but access" is rarely, no freqent access is not major performance source.
> > > 
> > > I have one question. your "difficultness of pinning down" is major issue?
> > > 
> > 
> > Yes. If an administrator notices that minor fault rates are higher than
> > expected, it's going to be very difficult for them to understand why
> > it is happening and why setting reclaim_mode to 0 apparently fixes the
> > problem. oprofile for example might just show that a lot of time is being
> > spent in the fault paths but not explain why.
> 
> I don't understand this paragraph a bit. I feel this is only theorical issue.
> successing of try_to_unmap_one() mean the pte don't have accessed bit.
> it's obvious sign to be able to unmap pte.
> 

Ok, even if we are depending on the accessed bit, we are making assumptions
of the frequency of the bit being cleared and how often zone_reclaim()
is called as to whether it will cause more minor faults or not.

Yes, what I'm saying about minor faults being potentially increased is a
theoretical issue and I have no proof but it feels like a real
possibility. I would like to be convinced that setting may_unmap to 1 by
default when zone_reclaim == 1 is not going to result in this problem
occuring or at least to be convinced that it will not happen very often.

I would be much happier if setting may_unmap and may_swap only happened when
RECLAIM_SWAP was enabled.

> if we convice MPI program, long time untouched pages often mean never touched again.
> Am I missing anything? or you don't talk about non-hpc workload?
> 

I don't have a particular workload in mind to be perfectly honest. I'm just not
convinced of the wisdom of trying to unmap pages by default in zone_reclaim()
just because the NUMA distances happen to be large.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
