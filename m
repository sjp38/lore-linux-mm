Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1EC6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 21:26:39 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so4545169yha.28
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 18:26:39 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id j69si14286677yhb.121.2013.12.16.18.26.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 18:26:37 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id g10so6157134pdj.29
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 18:26:36 -0800 (PST)
Date: Mon, 16 Dec 2013 18:26:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
In-Reply-To: <20131216162042.GC26797@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1312161742540.2037@eggly.anvils>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils> <20131216162042.GC26797@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 16 Dec 2013, Michal Hocko wrote:
> On Mon 16-12-13 00:36:05, Hugh Dickins wrote:
> [...]
> 
> OK, I went through the patch and it looks good except for suspicious
> ctrl->lock handling in swap_cgroup_reassign (see below). I am just
> suggesting to split it into 4 parts

Thanks a lot for studying it, and responding so quickly.
As I remark in reply to Tejun, I'm not nearly so keen on this
approach as you are, and would prefer something short and sweet
from the cgroup end, at least for now; but let's go through your
comments, to keep both options open until we're surer.

> 
> * swap_cgroup_mutex -> swap_cgroup_lock
> * swapon cleanup
> * drop irqsave when taking ctrl->lock
> * mem_cgroup_reparent_swap
> 
> but I will leave the split up to you. Just make sure that the fix is a
> separate patch, please.

Yes indeed, some split like that, maybe even more pieces.  The difficult
part is the ordering: for going into 3.13, we'd prefer a small fix first
and cleanup to follow after in 3.14, but it will be hard to force myself
not to do the cleanup ones first, and until getting down to it I won't
recall how much of the cleanup was essential e.g. to avoid lock ordering
problems or long lock hold times, perhaps.

> 
> [...]
> > --- 3.13-rc4/mm/page_cgroup.c	2013-02-18 15:58:34.000000000 -0800
> > +++ linux/mm/page_cgroup.c	2013-12-15 14:34:36.312485960 -0800
> > @@ -322,7 +322,8 @@ void __meminit pgdat_page_cgroup_init(st
> >  
> >  #ifdef CONFIG_MEMCG_SWAP
> >  
> > -static DEFINE_MUTEX(swap_cgroup_mutex);
> > +static DEFINE_SPINLOCK(swap_cgroup_lock);
> > +
> 
> This one is worth a separate patch IMO.

Agreed.

> 
> >  struct swap_cgroup_ctrl {
> >  	struct page **map;
> >  	unsigned long length;
> > @@ -353,14 +354,11 @@ struct swap_cgroup {
> >  /*
> >   * allocate buffer for swap_cgroup.
> >   */
> > -static int swap_cgroup_prepare(int type)
> > +static int swap_cgroup_prepare(struct swap_cgroup_ctrl *ctrl)
> >  {
> >  	struct page *page;
> > -	struct swap_cgroup_ctrl *ctrl;
> >  	unsigned long idx, max;
> >  
> > -	ctrl = &swap_cgroup_ctrl[type];
> > -
> >  	for (idx = 0; idx < ctrl->length; idx++) {
> >  		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> >  		if (!page)
> 
> This with swap_cgroup_swapon should be in a separate patch as a cleanup.

Agreed.

> 
> > @@ -407,18 +405,17 @@ unsigned short swap_cgroup_cmpxchg(swp_e
> >  {
> >  	struct swap_cgroup_ctrl *ctrl;
> >  	struct swap_cgroup *sc;
> > -	unsigned long flags;
> >  	unsigned short retval;
> >  
> >  	sc = lookup_swap_cgroup(ent, &ctrl);
> >  
> > -	spin_lock_irqsave(&ctrl->lock, flags);
> > +	spin_lock(&ctrl->lock);
> >  	retval = sc->id;
> >  	if (retval == old)
> >  		sc->id = new;
> >  	else
> >  		retval = 0;
> > -	spin_unlock_irqrestore(&ctrl->lock, flags);
> > +	spin_unlock(&ctrl->lock);
> >  	return retval;
> >  }
> >  
> > @@ -435,14 +432,13 @@ unsigned short swap_cgroup_record(swp_en
> >  	struct swap_cgroup_ctrl *ctrl;
> >  	struct swap_cgroup *sc;
> >  	unsigned short old;
> > -	unsigned long flags;
> >  
> >  	sc = lookup_swap_cgroup(ent, &ctrl);
> >  
> > -	spin_lock_irqsave(&ctrl->lock, flags);
> > +	spin_lock(&ctrl->lock);
> >  	old = sc->id;
> >  	sc->id = id;
> > -	spin_unlock_irqrestore(&ctrl->lock, flags);
> > +	spin_unlock(&ctrl->lock);
> >  
> >  	return old;
> >  }
> 
> I would prefer these two in a separate patch as well. I have no idea why
> these were IRQ aware as this was never needed AFAICS.
> e9e58a4ec3b10 is not very specific...

Agreed.  Yes, I couldn't work out any justification for the _irqsave
variants, and preferred to avoid that clutter rather than add to it.

> 
> > @@ -451,19 +447,60 @@ unsigned short swap_cgroup_record(swp_en
> >   * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
> >   * @ent: swap entry to be looked up.
> >   *
> > - * Returns CSS ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
> > + * Returns ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
> >   */
> >  unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
> >  {
> >  	return lookup_swap_cgroup(ent, NULL)->id;
> >  }
> >  
> > +/**
> > + * swap_cgroup_reassign - assign all old entries to new (before old is freed).
> > + * @old: id of emptied memcg whose entries are now to be reassigned
> > + * @new: id of parent memcg to which those entries are to be assigned
> > + *
> > + * Returns number of entries reassigned, for debugging or for statistics.
> > + */
> > +long swap_cgroup_reassign(unsigned short old, unsigned short new)
> > +{
> > +	long reassigned = 0;
> > +	int type;
> > +
> > +	for (type = 0; type < MAX_SWAPFILES; type++) {
> > +		struct swap_cgroup_ctrl *ctrl = &swap_cgroup_ctrl[type];
> > +		unsigned long idx;
> > +
> > +		for (idx = 0; idx < ACCESS_ONCE(ctrl->length); idx++) {
> > +			struct swap_cgroup *sc, *scend;
> > +
> > +			spin_lock(&swap_cgroup_lock);
> > +			if (idx >= ACCESS_ONCE(ctrl->length))
> > +				goto unlock;
> > +			sc = page_address(ctrl->map[idx]);
> > +			for (scend = sc + SC_PER_PAGE; sc < scend; sc++) {
> > +				if (sc->id != old)
> > +					continue;
> 
> Is this safe? What prevents from race when id is set to old?

I am assuming that when this is called, we shall not be making any
new charges to old (if you see what I mean :) - this is called after
mem_cgroup_reparent_charges() (the main call - I've not yet wrapped
my head around Hannes's later safety-net call; perhaps these patches
would even make that one redundant - dunno).

Quite a lot is made simpler by the fact that we do not need to call
this from mem_cgroup_force_empty(), with all the races that would
entail: there was never any attempt to move these swap charges before,
so it's a pleasure not to have to deal with that possibility now.

> 
> > +				spin_lock(&ctrl->lock);
> > +				if (sc->id == old) {
> 
> Also it seems that compiler is free to optimize this test away, no?
> You need ACCESS_ONCE here as well, I guess.

Oh dear, you're asking me to read again through memory-barriers.txt
(Xmas 2013 edition), and come to a conclusion.  I think this pattern
of test outside spinlock, spinlock, test again inside spinlock is
used in very many places, without any ACCESS_ONCE.  I'll have to
go and search through the precedents.

I've probably brought this upon myself with the ACCESS_ONCE(ctrl->length)
a few lines above, which I added at a late stage to match the one above
it; but now I'm arguing that's unnecessary.

One of the problems with ACCESS_ONCE is that one easily falls into
a mistaken state in which it seems to be necessary everywhere;
but that illusion must be resisted.

The spinlock should make it unnecessary, but I'll have to muse on
semi-permeable membranes, osmosis, stuff like that.

> 
> > +					sc->id = new;
> > +					reassigned++;
> > +				}
> > +				spin_unlock(&ctrl->lock);
> > +			}
> > +unlock:
> > +			spin_unlock(&swap_cgroup_lock);
> > +			cond_resched();
> > +		}
> > +	}
> > +	return reassigned;
> > +}
> > +
> >  int swap_cgroup_swapon(int type, unsigned long max_pages)
> >  {
> >  	void *array;
> >  	unsigned long array_size;
> >  	unsigned long length;
> > -	struct swap_cgroup_ctrl *ctrl;
> > +	struct swap_cgroup_ctrl ctrl;
> >  
> >  	if (!do_swap_account)
> >  		return 0;
> [...]
> -- 
> Michal Hocko
> SUSE Labs

Thanks: let's see if Tejun and Zefan can come up with something
simpler than this at their end.  If we do all decide that this
swap_cgroup_reassign() kind of change is desirable, it would still
be better to make it later on as a cleanup than rush it in now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
