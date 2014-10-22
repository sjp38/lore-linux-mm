Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEAF6B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:37:38 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so3880840pad.5
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:37:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id us5si10679450pab.50.2014.10.22.08.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 08:37:37 -0700 (PDT)
Date: Wed, 22 Oct 2014 19:37:25 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
Message-ID: <20141022153725.GY16496@esperanza>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
 <20141021125252.GN16496@esperanza>
 <20141021210328.GB29116@phnom.home.cmpxchg.org>
 <20141022083353.GU16496@esperanza>
 <20141022132038.GB17161@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141022132038.GB17161@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 22, 2014 at 09:20:38AM -0400, Johannes Weiner wrote:
> On Wed, Oct 22, 2014 at 12:33:53PM +0400, Vladimir Davydov wrote:
> > On Tue, Oct 21, 2014 at 05:03:28PM -0400, Johannes Weiner wrote:
> > > On Tue, Oct 21, 2014 at 04:52:52PM +0400, Vladimir Davydov wrote:
> > > > On Mon, Oct 20, 2014 at 11:22:09AM -0400, Johannes Weiner wrote:
> > > > > mem_cgroup_swapout() is called with exclusive access to the page at
> > > > > the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> > > > > flag and deferring the uncharge, just do it right away.  This allows
> > > > > follow-up patches to simplify the uncharge code.
> > > > > 
> > > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > > ---
> > > > >  mm/memcontrol.c | 17 +++++++++++++----
> > > > >  1 file changed, 13 insertions(+), 4 deletions(-)
> > > > > 
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index bea3fddb3372..7709f17347f3 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -5799,6 +5799,7 @@ static void __init enable_swap_cgroup(void)
> > > > >   */
> > > > >  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> > > > >  {
> > > > > +	struct mem_cgroup *memcg;
> > > > >  	struct page_cgroup *pc;
> > > > >  	unsigned short oldid;
> > > > >  
> > > > > @@ -5815,13 +5816,21 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> > > > >  		return;
> > > > >  
> > > > >  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
> > > > > +	memcg = pc->mem_cgroup;
> > > > >  
> > > > > -	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
> > > > > +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> > > > >  	VM_BUG_ON_PAGE(oldid, page);
> > > > > +	mem_cgroup_swap_statistics(memcg, true);
> > > > >  
> > > > > -	pc->flags &= ~PCG_MEMSW;
> > > > > -	css_get(&pc->mem_cgroup->css);
> > > > > -	mem_cgroup_swap_statistics(pc->mem_cgroup, true);
> > > > > +	pc->flags = 0;
> > > > > +
> > > > > +	if (!mem_cgroup_is_root(memcg))
> > > > > +		page_counter_uncharge(&memcg->memory, 1);
> > > > 
> > > > AFAIU it removes batched uncharge of swapped out pages, doesn't it? Will
> > > > it affect performance?
> > > 
> > > During swapout and with lockless page counters?  I don't think so.
> > 
> > How is this different from page cache out? I mean, we can have a lot of
> > pages in the swap cache that have already been swapped out, and are
> > waiting to be unmapped, uncharged, and freed, just like usual page
> > cache. Why do we use batching for file cache pages then?
> 
> The batching is mostly for munmap().  We do it for reclaim because
> it's convenient, but I don't think an extra word per struct page to
> batch one, sometimes a few, locked subtractions per swapped out page
> is a reasonable trade-off.
> 
> > > > Besides, it looks asymmetric with respect to the page cache uncharge
> > > > path, where we still defer uncharge to mem_cgroup_uncharge_list(), and I
> > > > personally rather dislike this asymmetry.
> > > 
> > > The asymmetry is inherent in the fact that we mave memory and
> > > memory+swap accounting, and here a memory charge is transferred out to
> > > swap.  Before, the asymmetry was in mem_cgroup_uncharge_list() where
> > > we separate out memory and memsw pages (which the next patch fixes).
> > 
> > I agree that memsw is inherently asymmetric, but IMO it isn't the case
> > for swap *cache* vs page *cache*. We handle them similarly - removing
> > from a mapping, uncharging, freeing. If one wants batching, why
> > shouldn't the other?
> 
> It has to be worth it in practical terms.  You can argue symmetry
> between swap cache and page cache, but swapping simply is a much
> colder path than reclaiming page cache.  Our reclaim algorithm avoids
> it like the plague.
> 
> > > So nothing changed, the ugliness was just moved around.  I actually
> > > like it better now that it's part of the swap controller, because
> > > that's where the nastiness actually comes from.  This will all go away
> > > when we account swap separately.  Then, swapped pages can keep their
> > > memory charge until mem_cgroup_uncharge() again and the swap charge
> > > will be completely independent from it.  This reshuffling is just
> > > necessary because it allows us to get rid of the per-page flag.
> > 
> > Do you mean that swap cache uncharge batching will be back soon?
> 
> Well, yes, once we switch from memsw to a separate swap couter, it
> comes automatically.  Pages no longer carry two charges, and so the
> uncharging of pages doesn't have to distinguish between swapped out
> pages and other pages anymore.

With this in mind,

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
