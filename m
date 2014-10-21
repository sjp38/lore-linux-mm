Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 538906B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 17:03:39 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so1766295lbv.10
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 14:03:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lc6si20694043lbb.129.2014.10.21.14.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 14:03:37 -0700 (PDT)
Date: Tue, 21 Oct 2014 17:03:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
Message-ID: <20141021210328.GB29116@phnom.home.cmpxchg.org>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
 <20141021125252.GN16496@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021125252.GN16496@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 21, 2014 at 04:52:52PM +0400, Vladimir Davydov wrote:
> On Mon, Oct 20, 2014 at 11:22:09AM -0400, Johannes Weiner wrote:
> > mem_cgroup_swapout() is called with exclusive access to the page at
> > the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> > flag and deferring the uncharge, just do it right away.  This allows
> > follow-up patches to simplify the uncharge code.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/memcontrol.c | 17 +++++++++++++----
> >  1 file changed, 13 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index bea3fddb3372..7709f17347f3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5799,6 +5799,7 @@ static void __init enable_swap_cgroup(void)
> >   */
> >  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> >  {
> > +	struct mem_cgroup *memcg;
> >  	struct page_cgroup *pc;
> >  	unsigned short oldid;
> >  
> > @@ -5815,13 +5816,21 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> >  		return;
> >  
> >  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
> > +	memcg = pc->mem_cgroup;
> >  
> > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
> > +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> >  	VM_BUG_ON_PAGE(oldid, page);
> > +	mem_cgroup_swap_statistics(memcg, true);
> >  
> > -	pc->flags &= ~PCG_MEMSW;
> > -	css_get(&pc->mem_cgroup->css);
> > -	mem_cgroup_swap_statistics(pc->mem_cgroup, true);
> > +	pc->flags = 0;
> > +
> > +	if (!mem_cgroup_is_root(memcg))
> > +		page_counter_uncharge(&memcg->memory, 1);
> 
> AFAIU it removes batched uncharge of swapped out pages, doesn't it? Will
> it affect performance?

During swapout and with lockless page counters?  I don't think so.

> Besides, it looks asymmetric with respect to the page cache uncharge
> path, where we still defer uncharge to mem_cgroup_uncharge_list(), and I
> personally rather dislike this asymmetry.

The asymmetry is inherent in the fact that we mave memory and
memory+swap accounting, and here a memory charge is transferred out to
swap.  Before, the asymmetry was in mem_cgroup_uncharge_list() where
we separate out memory and memsw pages (which the next patch fixes).

So nothing changed, the ugliness was just moved around.  I actually
like it better now that it's part of the swap controller, because
that's where the nastiness actually comes from.  This will all go away
when we account swap separately.  Then, swapped pages can keep their
memory charge until mem_cgroup_uncharge() again and the swap charge
will be completely independent from it.  This reshuffling is just
necessary because it allows us to get rid of the per-page flag.

> > +	local_irq_disable();
> > +	mem_cgroup_charge_statistics(memcg, page, -1);
> > +	memcg_check_events(memcg, page);
> > +	local_irq_enable();
> 
> AFAICT mem_cgroup_swapout() is called under mapping->tree_lock with irqs
> disabled, so we should use irq_save/restore here.

Good catch!  I don't think this function actually needs to be called
under the tree_lock, so I'd rather send a follow-up that moves it out.
For now, this should be sufficient:

---
