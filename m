Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1492F6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 09:17:17 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id t60so4978294wes.19
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 06:17:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n12si9567860wjw.141.2014.03.07.06.17.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 06:17:15 -0800 (PST)
Date: Fri, 7 Mar 2014 15:17:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH -mm] memcg: reparent only LRUs during
 mem_cgroup_css_offline
Message-ID: <20140307141714.GD28816@dhcp22.suse.cz>
References: <1392821509-976-1-git-send-email-mhocko@suse.cz>
 <alpine.LSU.2.11.1402261755230.975@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402261755230.975@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Filipe Brandenburger <filbranden@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 26-02-14 18:49:10, Hugh Dickins wrote:
> On Wed, 19 Feb 2014, Michal Hocko wrote:
> 
> > css_offline callback exported by the cgroup core is not intended to get
> > rid of all the charges but rather to get rid of cached charges for the
> > soon destruction. For the memory controller we have 2 different types of
> > "cached" charges which prevent from the memcg destruction (because they
> > pin memcg by css reference). Swapped out pages (when swap accounting is
> > enabled) and kmem charges. None of them are dealt with in the current
> > code.
> > 
> > What we do instead is that we are reducing res counter charges (reduced
> > by kmem charges) to 0. And this hard down-to-0 requirement has led to
> > several issues in the past when the css_offline loops without any way
> > out e.g. memcg: reparent charges of children before processing parent.
> > 
> > The important thing is that we actually do not have to drop all the
> > charges. Instead we want to reduce LRU pages (which do not pin memcg) as
> > much as possible because they are not reachable by memcg iterators after
> > css_offline code returns, thus they are not reclaimable anymore.
> 
> That worries me.
> 
> > 
> > This patch simply extracts LRU reparenting into mem_cgroup_reparent_lrus
> > which doesn't care about charges and it is called from css_offline
> > callback and the original mem_cgroup_reparent_charges stays in
> > css_offline callback. The original workaround for the endless loop is no
> > longer necessary because child vs. parent ordering is no longer and
> > issue. The only requirement is that the parent has be still online at
> > the time of css_offline.
> 
> But isn't that precisely what we just found is not guaranteed?

OK, this implicitly relies on cgroup_mutex and later when cgroup_mutex
is away we would need our own lock around reparenting.

> And in fact your patch has the necessary loop up to find the
> first ancestor it can successfully css_tryget.  Maybe you meant
> to say "still there" rather than "still online".

I meant online because we have to make sure that the reparented pages
have to to be reachable by iterators.

> (Tangential, I don't think you rely on this any more than we do
> at present, and I may be wrong to suggest any problem: but I would
> feel more comfortable if kernel/cgroup.c's css_free_work_fn() did
> parent = css->parent; css->ss->css_free(css); css_put(parent);
> instead of putting the parent before freeing the child.)

that makes sense to me.

> > mem_cgroup_reparent_charges also doesn't have to exclude kmem charges
> > because there shouldn't be any at the css_free stage. Let's add BUG_ON
> > to make sure we haven't screwed anything.
> > 
> > mem_cgroup_reparent_lrus is racy but this is tolerable as the inflight
> > pages which will eventually get back to the memcg's LRU shouldn't
> > constitute a lot of memory.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> > This is on top of memcg-reparent-charges-of-children-before-processing-parent.patch
> > and I am not suggesting to replace it (I think Filipe's patch is more
> > appropriate for the stable tree).
> > Nevertheless I find this approach slightly better because it makes
> > semantical difference between offline and free more obvious and we can
> > build on top of it later (when offlining is no longer synchronized by
> > cgroup_mutex). But if you think that it is not worth touching this area
> > until we find a good way to reparent swapped out and kmem pages then I
> > am OK with it and stay with Filipe's patch.
> 
> I'm ambivalent about it.  I like it, and I like very much that the loop
> waiting for RES_USAGE to go down to 0 is without cgroup_mutex held; but
> I dislike that any pages temporarily off LRU at the time of css_offline's
> list_empty check, will then go AWOL (unreachable by reclaim), until
> css_free later gets around to reparenting them.

Yes it is not nice but my impression is that we are not talking about
too many pages. Maybe I am underestimating this.

> It's conceivable that some code could be added to mem_cgroup_page_lruvec()
> (near my "Surreptitiously" comment), to reparent when they're put back on
> LRU; but more probably not, that's already tricky, and probably bad to
> make it any trickier, even if it turned out to be possible.

That would work, but as you write, it would make this code even
trickier.

> So  I'm inclined to wait until the swap and kmem situation is sorted out

Vladimir Davydov has already posted kmem reparenting patchset but I
didn't get to read through it. Swap reparenting has already been posted
by you and Johannes.

I am not planning to push this patch, it was more an example what I was
referring to earlier in discussion.

> (when the delay between offline and free should become much briefer);
> but would be happy if you found a good way to make the missing pages
> reclaimable in the meantime.
> 
> A couple of un-comments below.
[...]
> > @@ -6613,13 +6614,20 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
> >  	kmem_cgroup_css_offline(memcg);
> >  
> >  	mem_cgroup_invalidate_reclaim_iterators(memcg);
> > -
> >  	/*
> >  	 * This requires that offlining is serialized.  Right now that is
> >  	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
> >  	 */
> 
> And that comment belongs to the code you're removing, doesn't it?
> So should be removed along with it.

We still rely on the serialization because we have to be sure that the
parent is not offlined in parallel because we could end up reparenting
into a parent which goes offline right after css_tryget and pages
wouldn't be reachable. This is guaranteed by the cgroup_mutex currently
but if that changes in the cgroup core we need our own synchronization
here.

> > -	css_for_each_descendant_post(iter, css)
> > -		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
> > +	do {
> > +		parent = parent_mem_cgroup(parent);
> > +		/*
> > +		 * If no parent, move charges to root cgroup.
> > +		 */
> > +		if (!parent)
> > +			parent = root_mem_cgroup;
> > +	} while (!css_tryget(&parent->css));
> > +	mem_cgroup_reparent_lrus(memcg, parent);
> > +	css_put(&parent->css);
> >  
> >  	mem_cgroup_destroy_all_caches(memcg);
> >  	vmpressure_cleanup(&memcg->vmpressure);
> > -- 
> > 1.9.0.rc3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
