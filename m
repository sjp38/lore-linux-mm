Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF576B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 03:34:57 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id g15so2999774eak.17
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 00:34:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si7738504eeo.214.2014.01.21.00.34.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 00:34:56 -0800 (PST)
Date: Tue, 21 Jan 2014 09:34:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140121083454.GA1894@dhcp22.suse.cz>
References: <20140114142610.GF32227@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz>
 <20140115121728.GJ8782@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401151241280.9004@eggly.anvils>
 <20140116081738.GA28157@dhcp22.suse.cz>
 <20140116152259.GG28157@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401161011110.1321@eggly.anvils>
 <20140117154143.GF5356@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401201958330.1155@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401201958330.1155@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 20-01-14 21:16:36, Hugh Dickins wrote:
> On Fri, 17 Jan 2014, Michal Hocko wrote:
> > On Thu 16-01-14 11:15:36, Hugh Dickins wrote:
> > 
> > > I don't believe 19f39402864e was responsible for a reference leak,
> > > that came later.  But I think it was responsible for the original
> > > endless iteration (shrink_zone going around and around getting root
> > > again and again from mem_cgroup_iter).
> > 
> > So your hang is not within mem_cgroup_iter but you are getting root all
> > the time without any way out?
> 
> In the 3.10 and 3.11 cases, yes.

OK, that makes sense.
 
> > [3.10 code base]
> > shrink_zone
> > 						[rmdir root]
> >   mem_cgroup_iter(root, NULL, reclaim)
> >     // prev = NULL
> >     rcu_read_lock()
> >     last_visited = iter->last_visited	// gets root || NULL
> >     css_tryget(last_visited) 		// failed
> >     last_visited = NULL			[1]
> >     memcg = root = __mem_cgroup_iter_next(root, NULL)
> >     iter->last_visited = root;
> >     reclaim->generation = iter->generation
> > 
> >  mem_cgroup_iter(root, root, reclaim)
> >    // prev = root
> >    rcu_read_lock
> >     last_visited = iter->last_visited	// gets root
> >     css_tryget(last_visited) 		// failed
> >     [1]
> > 
> > So we indeed can loop here without any progress. I just fail
> > to see how my patch could help. We even do not get down to
> > cgroup_next_descendant_pre.
> > 
> > Or am I missing something?
> 
> Your patch to 3.12 and 3.13 mem_cgroup_iter_next() doesn't help
> in 3.10 and 3.11, correct.  That's why I appended a different patch,
> to mem_cgroup_iter(), for the 3.10 and 3.11 versions of the hang.
> 
> > 
> > The following should fix this kind of endless loop:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 194721839cf5..168e5abcca92 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1221,7 +1221,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  				smp_rmb();
> >  				last_visited = iter->last_visited;
> >  				if (last_visited &&
> > -				    !css_tryget(&last_visited->css))
> > +				    last_visited != root &&
> > +				     !css_tryget(&last_visited->css))
> >  					last_visited = NULL;
> >  			}
> >  		}
> > @@ -1229,7 +1230,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  		memcg = __mem_cgroup_iter_next(root, last_visited);
> >  
> >  		if (reclaim) {
> > -			if (last_visited)
> > +			if (last_visited && last_visited != root)
> >  				css_put(&last_visited->css);
> >  
> >  			iter->last_visited = memcg;
> 
> Right, that appears to fix 3.10, and seems a better alternative to the
> patch I suggested.  I say "appears" because my success in reproducing
> the hang is variable, so when I see that it's "fixed" I cannot be
> quite sure. 

Understood.

> I say "seems" because I think yours respects the intention
> of the iterator better than mine, but I've never been convinced that
> the iterator is as sensible as it intends in the face of races.
> 
> At the bottom I've appended the version of yours that I've been trying
> on 3.11.  I did succeed in reproducing the hang twice on 3.11.10.3
> (which I don't think differs in any essential from 3.11.0 for this issue,
> but after my lack of success with 3.11.0 I tried harder with that.)

git log points only at 3 patches in mm/memcontrol.c and all of them seem
unrelated.

> More so than in the 3.10 case, I haven't really given it long enough
> with the patch to really assert that it's good; and Greg Thelen came
> across a different reproduction case that I've yet to remind myself
> of and try, I'll have to report back to you later in the week when
> I've run that with your fix.

Great, thanks a lot for your testing. It is really appreciated
especially now that I am quite busy with other internal stuff.

> > Not that I like it much :/
> 
> Well, I'm not in love with it, but I do think it's more appropriate
> than mine, if it really does fix the issues.

It fixes a potential endless loop. It is a question it is the one you
are seeing.

> It was only under questioning from you that we arrived at the belief
> that the problem is with the css_tryget of a root being removed: my
> patch was vaguer than that, not identifying the root cause.
> 
> I suspect that the underlying problem is actually the "do {} while ()"
> nature of the iteration loops, instead of "while () {}"s. 

I think the outside caller shouldn't care much. The iterator code has to
make sure that it doesn't loop itself. Doing while () {} has some issues
as well. Having a reason to reclaim but hen do not reclaim anything
might pop out as an issue upper in the calling stack.

> That places us (not for the first time) in the awkward position of
> having to supply something once (and once only) even when it doesn't
> really fit.
>
> (I have wondered whether making mem_cgroup_invalidate_reclaim_iterators
> visit the memcg as well as its parents, might provide another fix; nice
> if it did, but I doubt it, and have spent so much time fiddling around
> here that I've lost the will to try anything else.)

I do not see it as an easier alternative.

[...]
> > > > Cc: stable@vger.kernel.org # 3.10+
> > > 
> > > Well, I'm okay with that, if we use that as a way to shoehorn in the
> > > patch at the bottom instead for 3.10 and 3.11 stables.
> > 
> > So far I do not see how it would make a change for those two kernels as
> > they have the special handling for root.
> 
> That was my point: that patch does not fix 3.10 and 3.11 at all,
> but they suffer from the same problem (manifesting in a slightly
> different way, the hang revisiting mem_cgroup_iter repeatedly instead
> of being trapped inside it); so it may not be inappropriate to say 3.10+
> even though that particular patch will not apply and would not fix them.

OK, understood now. I will repost that patch with updated changelog
later.
 
> > [...]
> > > "Equivalent" patch for 3.10 or 3.11: fixing similar hangs but no leakage.
> > > 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > 
> > > --- v3.10/mm/memcontrol.c	2013-06-30 15:13:29.000000000 -0700
> > > +++ linux/mm/memcontrol.c	2014-01-15 18:18:24.476566659 -0800
> > > @@ -1226,7 +1226,8 @@ struct mem_cgroup *mem_cgroup_iter(struc
> > >  			}
> > >  		}
> > >  
> > > -		memcg = __mem_cgroup_iter_next(root, last_visited);
> > > +		if (!prev || last_visited)
> > > +			memcg = __mem_cgroup_iter_next(root, last_visited);
> > 
> > I am confused. What would change between those two calls to change the
> > outcome? The function doesn't have any internal state.
> 
> I don't understand your question (what two calls?).

OK, it was my selective blindness that stroke again here. Sorry about
the confusion.

With fresh eyes. Yes it would work as well.

> The 3.10 or 3.11
> __mem_cgroup_iter_next() begins with "if (!last_visited) return root;",
> which was problematic because again and again it would return root.
> Originally I passed in prev, and returned NULL instead of root if prev
> but !last_visited; but I've an aversion to passing a function an extra
> argument to say it shouldn't have been called, so in this version I'm
> testing !prev || last_visited before calling it.  Perhaps your "two
> calls" are the first with prev == NULL and the second with prev == root.
> 
> But I say I prefer your fix because mine above says nothing about root,
> which we now believe is the only problematic case.  Mine would leave
> memcg NULL whenever a change resets last_visited to NULL (once one memcg
> has been delivered): which is simple, but not what the iterator intends
> (if I read it right, it wants to start again from the beginning, whereas
> I'm hastening it to the end).  In practice mine works well, and I haven't
> seen the premature OOMs that you might suppose it leads to; but let's go
> for yours as more in keeping with the spirit of the iterator.

OK, let's keep it consistently ugly.

> "The spirit of the iterator", now that's a fine phrase.

:)

> Here's my 3.11 version of your 3.10, in case you spot something silly.
> I'll give it a try on Greg's testcase in coming days and report back.
> (Greg did suggest a different fix from mine back when he hit the issue,
> I'll also look that one out again in case it offers something better.)
> 
> --- v3.11/mm/memcontrol.c	2014-01-19 14:16:38.656701990 -0800
> +++ linux/mm/memcontrol.c	2014-01-20 19:04:50.635637615 -0800
> @@ -1148,19 +1148,17 @@ mem_cgroup_iter_load(struct mem_cgroup_r
>  	if (iter->last_dead_count == *sequence) {
>  		smp_rmb();
>  		position = iter->last_visited;
> -		if (position && !css_tryget(&position->css))
> +		if (position && position != root &&
> +		    !css_tryget(&position->css))
>  			position = NULL;
>  	}
>  	return position;
>  }
>  
>  static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
> -				   struct mem_cgroup *last_visited,
>  				   struct mem_cgroup *new_position,
>  				   int sequence)
>  {
> -	if (last_visited)
> -		css_put(&last_visited->css);
>  	/*
>  	 * We store the sequence count from the time @last_visited was
>  	 * loaded successfully instead of rereading it here so that we
> @@ -1234,7 +1232,10 @@ struct mem_cgroup *mem_cgroup_iter(struc
>  		memcg = __mem_cgroup_iter_next(root, last_visited);
>  
>  		if (reclaim) {
> -			mem_cgroup_iter_update(iter, last_visited, memcg, seq);
> +			if (last_visited && last_visited != root)
> +				css_put(&last_visited->css);
> +
> +			mem_cgroup_iter_update(iter, memcg, seq);
>  
>  			if (!memcg)
>  				iter->generation++;

Yes it looks good. Although I would probably go and add root into
mem_cgroup_iter_update and do the check and css_put there to have
it symmetric with mem_cgroup_iter_load. I will cook up a changelog for
this one as well (for both 3.10 and 3.11 because they share fail on root
case).

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
