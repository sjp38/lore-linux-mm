Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E60746B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:46:54 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so5791504wgg.0
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:46:54 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ds3si16205831wib.51.2014.07.15.08.46.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 08:46:53 -0700 (PDT)
Date: Tue, 15 Jul 2014 11:46:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715154643.GT29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715142350.GD9366@dhcp22.suse.cz>
 <20140715150937.GS29639@cmpxchg.org>
 <20140715151818.GE9366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715151818.GE9366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 05:18:18PM +0200, Michal Hocko wrote:
> On Tue 15-07-14 11:09:37, Johannes Weiner wrote:
> > On Tue, Jul 15, 2014 at 04:23:50PM +0200, Michal Hocko wrote:
> > > On Tue 15-07-14 10:25:45, Michal Hocko wrote:
> [...]
> > > > @@ -2760,15 +2752,15 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
> > > >  		spin_unlock_irq(&zone->lru_lock);
> > > >  	}
> > > >  
> > > > -	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
> > > > -	unlock_page_cgroup(pc);
> > > > -
> > > > +	local_irq_disable();
> > > > +	mem_cgroup_charge_statistics(memcg, page, nr_pages);
> > > >  	/*
> > > >  	 * "charge_statistics" updated event counter. Then, check it.
> > > >  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> > > >  	 * if they exceeds softlimit.
> > > >  	 */
> > > >  	memcg_check_events(memcg, page);
> > > > +	local_irq_enable();
> > > 
> > > preempt_{enable,disbale} should be sufficient for
> > > mem_cgroup_charge_statistics and memcg_check_events no?
> > > The first one is about per-cpu accounting (and that should be atomic
> > > wrt. IRQ on the same CPU) and the later one uses IRQ safe locks down in
> > > mem_cgroup_update_tree.
> > 
> > How could it be atomic wrt. IRQ on the local CPU when IRQs that modify
> > the counters can fire on the local CPU?
> 
> I meant that __this_atomic_add and __this_cpu_inc should be atomic wrt. IRQ.
> We do not care that an IRQ might jump in between two per-cpu operations.
> This is racy from other CPUs anyway.

It's really about a single RMW (+=) being interrupted by an IRQ.
this_cpu_ guarantees IRQ-atomicity, but __this_cpu_ does not.

We could probably migrate this code over to this_cpu and get rid of
the IRQ disabling later, because, as you said, we don't care about
being interrupted between separate counter updates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
