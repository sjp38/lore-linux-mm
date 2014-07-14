Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB2E6B0036
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 13:13:37 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id w62so985927wes.22
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 10:13:36 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id f10si16632757wjb.84.2014.07.14.10.13.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 10:13:35 -0700 (PDT)
Date: Mon, 14 Jul 2014 13:13:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 12/13] mm: memcontrol: rewrite charge API
Message-ID: <20140714171324.GQ29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
 <20140714150446.GD30713@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140714150446.GD30713@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 14, 2014 at 05:04:46PM +0200, Michal Hocko wrote:
> Hi,
> I've finally manage to untagle myself from internal stuff...
> 
> On Wed 18-06-14 16:40:44, Johannes Weiner wrote:
> > The memcg charge API charges pages before they are rmapped - i.e. have
> > an actual "type" - and so every callsite needs its own set of charge
> > and uncharge functions to know what type is being operated on.  Worse,
> > uncharge has to happen from a context that is still type-specific,
> > rather than at the end of the page's lifetime with exclusive access,
> > and so requires a lot of synchronization.
> > 
> > Rewrite the charge API to provide a generic set of try_charge(),
> > commit_charge() and cancel_charge() transaction operations, much like
> > what's currently done for swap-in:
> > 
> >   mem_cgroup_try_charge() attempts to reserve a charge, reclaiming
> >   pages from the memcg if necessary.
> > 
> >   mem_cgroup_commit_charge() commits the page to the charge once it
> >   has a valid page->mapping and PageAnon() reliably tells the type.
> > 
> >   mem_cgroup_cancel_charge() aborts the transaction.
> > 
> > This reduces the charge API and enables subsequent patches to
> > drastically simplify uncharging.
> > 
> > As pages need to be committed after rmap is established but before
> > they are added to the LRU, page_add_new_anon_rmap() must stop doing
> > LRU additions again.  Revive lru_cache_add_active_or_unevictable().
> 
> I think it would make more sense to do
> lru_cache_add_active_or_unevictable in a separate patch for easier
> review. Too late, though...
> 
> Few comments bellow
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> The patch looks correct but the code is quite tricky so I hope I didn't
> miss anything.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> > @@ -54,28 +54,11 @@ struct mem_cgroup_reclaim_cookie {
> >  };
> >  
> >  #ifdef CONFIG_MEMCG
> > -/*
> > - * All "charge" functions with gfp_mask should use GFP_KERNEL or
> > - * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> > - * alloc memory but reclaims memory from all available zones. So, "where I want
> > - * memory from" bits of gfp_mask has no meaning. So any bits of that field is
> > - * available but adding a rule is better. charge functions' gfp_mask should
> > - * be set to GFP_KERNEL or gfp_mask & GFP_RECLAIM_MASK for avoiding ambiguous
> > - * codes.
> > - * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
> > - */
> 
> I think we should slightly modify the comment but the primary idea
> should stay there. What about the following?
> /*
>  * Although memcg charge functions do not allocate any memory they are
>  * still getting GFP mask to control the reclaim process (therefore
>  * gfp_mask & GFP_RECLAIM_MASK is expected).
>  * GFP_KERNEL should be used for the general charge path without any
>  * constraints for the reclaim
>  * __GFP_WAIT should be cleared for atomic contexts
>  * __GFP_NORETRY should be set for charges which might fail rather than
>  * spend too much time reclaiming
>  * __GFP_NOFAIL should be set for charges which cannot fail.
>  */

What *is* the primary idea here?

Taking any kind of gfp mask and interpreting the bits that pertain to
you is done in a lot of places already, and there really is no need to
duplicate the documentation and risk it getting stale and misleading.

> > @@ -948,6 +951,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
> >  					struct page *page,
> >  					unsigned long haddr)
> >  {
> > +	struct mem_cgroup *memcg;
> >  	spinlock_t *ptl;
> >  	pgtable_t pgtable;
> >  	pmd_t _pmd;
> > @@ -968,20 +972,21 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
> >  					       __GFP_OTHER_NODE,
> >  					       vma, address, page_to_nid(page));
> >  		if (unlikely(!pages[i] ||
> > -			     mem_cgroup_charge_anon(pages[i], mm,
> > -						       GFP_KERNEL))) {
> > +			     mem_cgroup_try_charge(pages[i], mm, GFP_KERNEL,
> > +						   &memcg))) {
> >  			if (pages[i])
> >  				put_page(pages[i]);
> > -			mem_cgroup_uncharge_start();
> >  			while (--i >= 0) {
> > -				mem_cgroup_uncharge_page(pages[i]);
> > +				memcg = (void *)page_private(pages[i]);
> 
> Hmm, OK the memcg couldn't go away even if mm owner has left it because
> the charge is already there and the page is not on LRU so the
> mem_cgroup_css_free will wait until we uncharge it or put to LRU.

Yep, res_counter charges have always pinned the memcg.  We already
used this exact protocol and relied on the same lifetime rules for
swapin charging.

> > +/**
> > + * mem_cgroup_commit_charge - commit a page charge
> > + * @page: page to charge
> > + * @memcg: memcg to charge the page to
> > + * @lrucare: page might be on LRU already
> > + *
> > + * Finalize a charge transaction started by mem_cgroup_try_charge(),
> > + * after page->mapping has been set up.  This must happen atomically
> > + * as part of the page instantiation, i.e. under the page table lock
> > + * for anonymous pages, under the page lock for page and swap cache.
> > + *
> > + * In addition, the page must not be on the LRU during the commit, to
> > + * prevent racing with task migration.  If it might be, use @lrucare.
> > + *
> > + * Use mem_cgroup_cancel_charge() to cancel the transaction instead.
> > + */
> > +void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
> > +			      bool lrucare)
> 
> I think we should be explicit that this is only required for LRU pages.
> kmem doesn't have to finalize the transaction.

The function itself only applies to user/LRU pages.  kmem has its own
separate API for charge/commit/cancel/uncharge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
