Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8819F6B0073
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:54:21 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so861452lbv.21
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:54:20 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ln4si2666637lac.118.2014.10.23.06.54.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 06:54:19 -0700 (PDT)
Date: Thu, 23 Oct 2014 09:54:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023135412.GA24269@phnom.home.cmpxchg.org>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
 <20141022133936.44f2d2931948ce13477b5e64@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022133936.44f2d2931948ce13477b5e64@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 22, 2014 at 01:39:36PM -0700, Andrew Morton wrote:
> On Wed, 22 Oct 2014 14:29:28 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") changed page
> > migration to uncharge the old page right away.  The page is locked,
> > unmapped, truncated, and off the LRU, but it could race with writeback
> > ending, which then doesn't unaccount the page properly:
> > 
> > test_clear_page_writeback()              migration
> >   acquire pc->mem_cgroup->move_lock
> >                                            wait_on_page_writeback()
> >   TestClearPageWriteback()
> >                                            mem_cgroup_migrate()
> >                                              clear PCG_USED
> >   if (PageCgroupUsed(pc))
> >     decrease memcg pages under writeback
> >   release pc->mem_cgroup->move_lock
> > 
> > The per-page statistics interface is heavily optimized to avoid a
> > function call and a lookup_page_cgroup() in the file unmap fast path,
> > which means it doesn't verify whether a page is still charged before
> > clearing PageWriteback() and it has to do it in the stat update later.
> > 
> > Rework it so that it looks up the page's memcg once at the beginning
> > of the transaction and then uses it throughout.  The charge will be
> > verified before clearing PageWriteback() and migration can't uncharge
> > the page as long as that is still set.  The RCU lock will protect the
> > memcg past uncharge.
> > 
> > As far as losing the optimization goes, the following test results are
> > from a microbenchmark that maps, faults, and unmaps a 4GB sparse file
> > three times in a nested fashion, so that there are two negative passes
> > that don't account but still go through the new transaction overhead.
> > There is no actual difference:
> > 
> > old:     33.195102545 seconds time elapsed       ( +-  0.01% )
> > new:     33.199231369 seconds time elapsed       ( +-  0.03% )
> > 
> > The time spent in page_remove_rmap()'s callees still adds up to the
> > same, but the time spent in the function itself seems reduced:
> > 
> >     # Children      Self  Command        Shared Object       Symbol
> > old:     0.12%     0.11%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap
> > new:     0.12%     0.08%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap
> > 
> > ...
> >
> > @@ -2132,26 +2126,32 @@ cleanup:
> >   * account and taking the move_lock in the slowpath.
> >   */
> >  
> > -void __mem_cgroup_begin_update_page_stat(struct page *page,
> > -				bool *locked, unsigned long *flags)
> > +struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
> > +					      bool *locked,
> > +					      unsigned long *flags)
> 
> It would be useful to document the args here (especially `locked'). 
> Also the new rcu_read_locking protocol is worth a mention: that it
> exists, what it does, why it persists as long as it does.

Okay, I added full kernel docs that explain the RCU fast path, the
memcg->move_lock slow path, and the lifetime guarantee of RCU in cases
where the page state that is about to change is the only thing pinning
the charge, like in end-writeback.

---
