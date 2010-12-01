Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7DAD6B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 01:40:55 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB166oGv010703
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 11:36:50 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB16enc92674870
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 12:10:49 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB16emt7021740
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 17:40:48 +1100
Date: Wed, 1 Dec 2010 12:10:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-ID: <20101201064043.GO2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
 <20101130101602.17475.32611.stgit@localhost6.localdomain6>
 <20101201103254.b823eae0.kamezawa.hiroyu@jp.fujitsu.com>
 <20101201051816.GI2746@balbir.in.ibm.com>
 <20101201052259.GN2746@balbir.in.ibm.com>
 <20101201143550.0b652916.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101201143550.0b652916.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-01 14:35:50]:

> On Wed, 1 Dec 2010 10:52:59 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:48:16]:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-01 10:32:54]:
> > > 
> > > > On Tue, 30 Nov 2010 15:46:31 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > Provide control using zone_reclaim() and a boot parameter. The
> > > > > code reuses functionality from zone_reclaim() to isolate unmapped
> > > > > pages and reclaim them as a priority, ahead of other mapped pages.
> > > > > 
> > > > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > ---
> > > > >  include/linux/swap.h |    5 ++-
> > > > >  mm/page_alloc.c      |    7 +++--
> > > > >  mm/vmscan.c          |   72 +++++++++++++++++++++++++++++++++++++++++++++++++-
> > > > >  3 files changed, 79 insertions(+), 5 deletions(-)
> > > > > 
> > > > > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > > > > index eba53e7..78b0830 100644
> > > > > --- a/include/linux/swap.h
> > > > > +++ b/include/linux/swap.h
> > > > > @@ -252,11 +252,12 @@ extern int vm_swappiness;
> > > > >  extern int remove_mapping(struct address_space *mapping, struct page *page);
> > > > >  extern long vm_total_pages;
> > > > >  
> > > > > -#ifdef CONFIG_NUMA
> > > > > -extern int zone_reclaim_mode;
> > > > >  extern int sysctl_min_unmapped_ratio;
> > > > >  extern int sysctl_min_slab_ratio;
> > > > >  extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> > > > > +extern bool should_balance_unmapped_pages(struct zone *zone);
> > > > > +#ifdef CONFIG_NUMA
> > > > > +extern int zone_reclaim_mode;
> > > > >  #else
> > > > >  #define zone_reclaim_mode 0
> > > > >  static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
> > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > index 62b7280..4228da3 100644
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -1662,6 +1662,9 @@ zonelist_scan:
> > > > >  			unsigned long mark;
> > > > >  			int ret;
> > > > >  
> > > > > +			if (should_balance_unmapped_pages(zone))
> > > > > +				wakeup_kswapd(zone, order);
> > > > > +
> > > > 
> > > > Hm, I'm not sure the final vision of this feature. Does this reclaiming feature
> > > > can't be called directly via balloon driver just before alloc_page() ?
> > > >
> > > 
> > > That is a separate patch, this is a boot paramter based control
> > > approach.
> > >  
> > > > Do you need to keep page caches small even when there are free memory on host ?
> > > >
> > > 
> > > The goal is to avoid duplication, as you know page cache fills itself
> > > to consume as much memory as possible. The host generally does not
> > > have a lot of free memory in a consolidated environment. 
> > >
> 
> That's a point. Then, why the guest has to do _extra_ work for host even when
> the host says nothing ? I think trigger this by guests themselves is not very good.

I've mentioned it before, the guest keeping free memory without a
large performance hit, helps, the balloon driver is able to quickly
retrieve this memory if required or the guest can use this memory for
some other application/task. The cached data is mostly already present
in the host page cache.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
