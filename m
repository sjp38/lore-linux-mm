Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1AA6B0130
	for <linux-mm@kvack.org>; Wed, 20 May 2015 12:15:26 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so58260823wgf.2
        for <linux-mm@kvack.org>; Wed, 20 May 2015 09:15:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15si2930050wiv.82.2015.05.20.09.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 09:15:24 -0700 (PDT)
Date: Wed, 20 May 2015 17:15:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm, memcg: Try charging a page before setting page
 up to date
Message-ID: <20150520161520.GR2462@suse.de>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-2-git-send-email-mgorman@suse.de>
 <20150520152923.GA2874@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150520152923.GA2874@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 20, 2015 at 11:29:23AM -0400, Johannes Weiner wrote:
> On Wed, May 20, 2015 at 01:50:44PM +0100, Mel Gorman wrote:
> > Historically memcg overhead was high even if memcg was unused. This has
> > improved a lot but it still showed up in a profile summary as being a
> > problem.
> > 
> > /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
> >   mem_cgroup_try_charge                                                        2.950%   175781
> >   __mem_cgroup_count_vm_event                                                  1.431%    85239
> >   mem_cgroup_page_lruvec                                                       0.456%    27156
> >   mem_cgroup_commit_charge                                                     0.392%    23342
> >   uncharge_list                                                                0.323%    19256
> >   mem_cgroup_update_lru_size                                                   0.278%    16538
> >   memcg_check_events                                                           0.216%    12858
> >   mem_cgroup_charge_statistics.isra.22                                         0.188%    11172
> >   try_charge                                                                   0.150%     8928
> >   commit_charge                                                                0.141%     8388
> >   get_mem_cgroup_from_mm                                                       0.121%     7184
> > 
> > That is showing that 6.64% of system CPU cycles were in memcontrol.c and
> > dominated by mem_cgroup_try_charge. The annotation shows that the bulk of
> > the cost was checking PageSwapCache which is expected to be cache hot but is
> > very expensive. The problem appears to be that __SetPageUptodate is called
> > just before the check which is a write barrier. It is required to make sure
> > struct page and page data is written before the PTE is updated and the data
> > visible to userspace. memcg charging does not require or need the barrier
> > but gets unfairly hit with the cost so this patch attempts the charging
> > before the barrier.  Aside from the accidental cost to memcg there is the
> > added benefit that the barrier is avoided if the page cannot be charged.
> > When applied the relevant profile summary is as follows.
> > 
> > /usr/src/linux-4.0-chargefirst-v2r1/mm/memcontrol.c                  3.7907   223277
> >   __mem_cgroup_count_vm_event                                                  1.143%    67312
> 
> Out of curiosity, I'm still consistently reading this function at
> around 0.7%.  Are you profiling this single-threadedly or for the
> entire run?  For profiling 80 single-threaded iterations, I get:
> 

Single-threaded. The mmtests benchmark in question supports gathering one
profile per thread count so it's just the 1 thread profile I included in
the changelog. The CPU in question is a i7-3770

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
