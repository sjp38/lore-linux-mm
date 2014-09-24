Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCEF6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 13:17:02 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so6761599wgg.26
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:17:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b2si317938wix.67.2014.09.24.10.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 10:16:58 -0700 (PDT)
Date: Wed, 24 Sep 2014 13:16:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2] mm: memcontrol: convert reclaim iterator to simple
 css refcounting
Message-ID: <20140924171653.GA10082@cmpxchg.org>
References: <1411161059-16552-1-git-send-email-hannes@cmpxchg.org>
 <20140919212843.GA23861@cmpxchg.org>
 <20140924164739.GA15897@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924164739.GA15897@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 06:47:39PM +0200, Michal Hocko wrote:
> On Fri 19-09-14 17:28:43, Johannes Weiner wrote:
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Fri, 19 Sep 2014 12:39:18 -0400
> > Subject: [patch v2] mm: memcontrol: convert reclaim iterator to simple css
> >  refcounting
> > 
> > The memcg reclaim iterators use a complicated weak reference scheme to
> > prevent pinning cgroups indefinitely in the absence of memory pressure.
> > 
> > However, during the ongoing cgroup core rework, css lifetime has been
> > decoupled such that a pinned css no longer interferes with removal of
> > the user-visible cgroup, and all this complexity is now unnecessary.
> 
> I very much welcome simplification in this area but I would also very much
> appreciate more details why some checks are no longer needed. Why don't
> we need ->generation or (next_css->flags & CSS_ONLINE) check anymore?

Vladimir pointed out that the generation was still needed, I added it
back and will submit version 2 after the lockless counters have been
sorted out.

Argh, I thought CSS_ONLINE was an artifact obsoleted by the
css_tryget_online() conversion.  That's quite the handgrenade.

Tejun, should maybe the iterators not return css before they have
CSS_ONLINE set?  It seems odd to have memcg reach into cgroup like
that to check if published objects are actually fully initialized.
Background is this patch:

commit d8ad30559715ce97afb7d1a93a12fd90e8fff312
Author: Hugh Dickins <hughd@google.com>
Date:   Thu Jan 23 15:53:32 2014 -0800

    mm/memcg: iteration skip memcgs not yet fully initialized
    
    It is surprising that the mem_cgroup iterator can return memcgs which
    have not yet been fully initialized.  By accident (or trial and error?)
    this appears not to present an actual problem; but it may be better to
    prevent such surprises, by skipping memcgs not yet online.
    
    Signed-off-by: Hugh Dickins <hughd@google.com>
    Cc: Tejun Heo <tj@kernel.org>
    Acked-by: Michal Hocko <mhocko@suse.cz>
    Cc: Johannes Weiner <hannes@cmpxchg.org>
    Cc: <stable@vger.kernel.org>        [3.12+]
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

> >  	rcu_read_lock();
> > -	while (!memcg) {
> > -		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
> > -		int uninitialized_var(seq);
> >  
> > -		if (reclaim) {
> > -			struct mem_cgroup_per_zone *mz;
> > +	if (reclaim) {
> > +		mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
> > +		priority = reclaim->priority;
> >  
> > -			mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
> > -			iter = &mz->reclaim_iter[reclaim->priority];
> > -			if (prev && reclaim->generation != iter->generation) {
> > -				iter->last_visited = NULL;
> > -				goto out_unlock;
> > -			}
> > -
> > -			last_visited = mem_cgroup_iter_load(iter, root, &seq);
> > -		}
> > -
> > -		memcg = __mem_cgroup_iter_next(root, last_visited);
> > +		do {
> > +			pos = ACCESS_ONCE(mz->reclaim_iter[priority]);
> > +		} while (pos && !css_tryget(&pos->css));
> 
> This is a bit confusing. AFAIU css_tryget fails only when the current
> ref count is zero already. When do we keep cached memcg with zero count
> behind? We always do css_get after cmpxchg.
> 
> Hmm, there is a small window between cmpxchg and css_get when we store
> the current memcg into the reclaim_iter[priority]. If the current memcg
> is root then we do not take any css reference before cmpxchg and so it
> might drop down to zero in the mean time so other CPU might see zero I
> guess. But I do not see how css_get after cmpxchg on such css works.
> I guess I should go and check the css reference counting again.

It's not about root or the newly stored memcg, it's that you might
read the position right before it's replaced and css_put(), at which
point the css_tryget() may fail and you have to reload the position.

I'll add a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
