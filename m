Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8D48A6B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 00:17:13 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f73so1726829yha.3
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:17:13 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id t26si4206907yhl.30.2014.01.20.21.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 21:17:12 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so2898808pbb.20
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:17:11 -0800 (PST)
Date: Mon, 20 Jan 2014 21:16:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
In-Reply-To: <20140117154143.GF5356@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1401201958330.1155@eggly.anvils>
References: <alpine.LSU.2.11.1401131751080.2229@eggly.anvils> <20140114132727.GB32227@dhcp22.suse.cz> <20140114142610.GF32227@dhcp22.suse.cz> <alpine.LSU.2.11.1401141201120.3762@eggly.anvils> <20140115095829.GI8782@dhcp22.suse.cz> <20140115121728.GJ8782@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401151241280.9004@eggly.anvils> <20140116081738.GA28157@dhcp22.suse.cz> <20140116152259.GG28157@dhcp22.suse.cz> <alpine.LSU.2.11.1401161011110.1321@eggly.anvils> <20140117154143.GF5356@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 17 Jan 2014, Michal Hocko wrote:
> On Thu 16-01-14 11:15:36, Hugh Dickins wrote:
> 
> > I don't believe 19f39402864e was responsible for a reference leak,
> > that came later.  But I think it was responsible for the original
> > endless iteration (shrink_zone going around and around getting root
> > again and again from mem_cgroup_iter).
> 
> So your hang is not within mem_cgroup_iter but you are getting root all
> the time without any way out?

In the 3.10 and 3.11 cases, yes.

> 
> [3.10 code base]
> shrink_zone
> 						[rmdir root]
>   mem_cgroup_iter(root, NULL, reclaim)
>     // prev = NULL
>     rcu_read_lock()
>     last_visited = iter->last_visited	// gets root || NULL
>     css_tryget(last_visited) 		// failed
>     last_visited = NULL			[1]
>     memcg = root = __mem_cgroup_iter_next(root, NULL)
>     iter->last_visited = root;
>     reclaim->generation = iter->generation
> 
>  mem_cgroup_iter(root, root, reclaim)
>    // prev = root
>    rcu_read_lock
>     last_visited = iter->last_visited	// gets root
>     css_tryget(last_visited) 		// failed
>     [1]
> 
> So we indeed can loop here without any progress. I just fail
> to see how my patch could help. We even do not get down to
> cgroup_next_descendant_pre.
> 
> Or am I missing something?

Your patch to 3.12 and 3.13 mem_cgroup_iter_next() doesn't help
in 3.10 and 3.11, correct.  That's why I appended a different patch,
to mem_cgroup_iter(), for the 3.10 and 3.11 versions of the hang.

> 
> The following should fix this kind of endless loop:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 194721839cf5..168e5abcca92 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1221,7 +1221,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  				smp_rmb();
>  				last_visited = iter->last_visited;
>  				if (last_visited &&
> -				    !css_tryget(&last_visited->css))
> +				    last_visited != root &&
> +				     !css_tryget(&last_visited->css))
>  					last_visited = NULL;
>  			}
>  		}
> @@ -1229,7 +1230,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  		memcg = __mem_cgroup_iter_next(root, last_visited);
>  
>  		if (reclaim) {
> -			if (last_visited)
> +			if (last_visited && last_visited != root)
>  				css_put(&last_visited->css);
>  
>  			iter->last_visited = memcg;

Right, that appears to fix 3.10, and seems a better alternative to the
patch I suggested.  I say "appears" because my success in reproducing
the hang is variable, so when I see that it's "fixed" I cannot be
quite sure.  I say "seems" because I think yours respects the intention
of the iterator better than mine, but I've never been convinced that
the iterator is as sensible as it intends in the face of races.

At the bottom I've appended the version of yours that I've been trying
on 3.11.  I did succeed in reproducing the hang twice on 3.11.10.3
(which I don't think differs in any essential from 3.11.0 for this issue,
but after my lack of success with 3.11.0 I tried harder with that.)

More so than in the 3.10 case, I haven't really given it long enough
with the patch to really assert that it's good; and Greg Thelen came
across a different reproduction case that I've yet to remind myself
of and try, I'll have to report back to you later in the week when
I've run that with your fix.

> 
> Not that I like it much :/

Well, I'm not in love with it, but I do think it's more appropriate
than mine, if it really does fix the issues.  It was only under
questioning from you that we arrived at the belief that the problem
is with the css_tryget of a root being removed: my patch was vaguer
than that, not identifying the root cause.

I suspect that the underlying problem is actually the "do {} while ()"
nature of the iteration loops, instead of "while () {}"s.  That places
us (not for the first time) in the awkward position of having to supply
something once (and once only) even when it doesn't really fit.

(I have wondered whether making mem_cgroup_invalidate_reclaim_iterators
visit the memcg as well as its parents, might provide another fix; nice
if it did, but I doubt it, and have spent so much time fiddling around
here that I've lost the will to try anything else.)

> 
> > But beware of my conclusion, please check for yourself: with my
> > separate kbuilds in separate /cg/cg/? memcgs, what "cg m" is doing
> > is very simple and segregated, can hardly be called testing reclaim
> > iteration, so I hope you have something better to check it.  Plus
> > I was testing on 3.10 and 3.11 vanilla, not latest stable versions.
> > 
> > (If I'm very honest, I'll admit that I still did not see that hang
> > on 3.11 vanilla:
> 
> But I assume you can still reproduce it with 3.10, right?

Yes, and given subsequent "success" with 3.11.10.3 (after several hours),
I expect I would manage to reproduce it with 3.11 if allowed enough time.

> I am sorry but I didn't get to run your script yet.
> 
> > what I hit was a crash in kfree instead, but the
> > same patch got rid of that too. 
> 
> Care to post an oops?

I didn't collect one at the time, and haven't seen it since.
It was an oops within __kfree() called from __mem_cgroup_free(),
but whether of the "struct mem_cgroup" or one of its ancillary
structures I cannot say.  I've chosen to believe that it wasn't
actually a memcg problem, but something caused by unrelated code
sharing the same kmalloc slab.

...

> > 
> > > Cc: stable@vger.kernel.org # 3.10+
> > 
> > Well, I'm okay with that, if we use that as a way to shoehorn in the
> > patch at the bottom instead for 3.10 and 3.11 stables.
> 
> So far I do not see how it would make a change for those two kernels as
> they have the special handling for root.

That was my point: that patch does not fix 3.10 and 3.11 at all,
but they suffer from the same problem (manifesting in a slightly
different way, the hang revisiting mem_cgroup_iter repeatedly instead
of being trapped inside it); so it may not be inappropriate to say 3.10+
even though that particular patch will not apply and would not fix them.

> 
> [...]
> > "Equivalent" patch for 3.10 or 3.11: fixing similar hangs but no leakage.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > 
> > --- v3.10/mm/memcontrol.c	2013-06-30 15:13:29.000000000 -0700
> > +++ linux/mm/memcontrol.c	2014-01-15 18:18:24.476566659 -0800
> > @@ -1226,7 +1226,8 @@ struct mem_cgroup *mem_cgroup_iter(struc
> >  			}
> >  		}
> >  
> > -		memcg = __mem_cgroup_iter_next(root, last_visited);
> > +		if (!prev || last_visited)
> > +			memcg = __mem_cgroup_iter_next(root, last_visited);
> 
> I am confused. What would change between those two calls to change the
> outcome? The function doesn't have any internal state.

I don't understand your question (what two calls?).  The 3.10 or 3.11
__mem_cgroup_iter_next() begins with "if (!last_visited) return root;",
which was problematic because again and again it would return root.
Originally I passed in prev, and returned NULL instead of root if prev
but !last_visited; but I've an aversion to passing a function an extra
argument to say it shouldn't have been called, so in this version I'm
testing !prev || last_visited before calling it.  Perhaps your "two
calls" are the first with prev == NULL and the second with prev == root.

But I say I prefer your fix because mine above says nothing about root,
which we now believe is the only problematic case.  Mine would leave
memcg NULL whenever a change resets last_visited to NULL (once one memcg
has been delivered): which is simple, but not what the iterator intends
(if I read it right, it wants to start again from the beginning, whereas
I'm hastening it to the end).  In practice mine works well, and I haven't
seen the premature OOMs that you might suppose it leads to; but let's go
for yours as more in keeping with the spirit of the iterator.

"The spirit of the iterator", now that's a fine phrase.

Here's my 3.11 version of your 3.10, in case you spot something silly.
I'll give it a try on Greg's testcase in coming days and report back.
(Greg did suggest a different fix from mine back when he hit the issue,
I'll also look that one out again in case it offers something better.)

--- v3.11/mm/memcontrol.c	2014-01-19 14:16:38.656701990 -0800
+++ linux/mm/memcontrol.c	2014-01-20 19:04:50.635637615 -0800
@@ -1148,19 +1148,17 @@ mem_cgroup_iter_load(struct mem_cgroup_r
 	if (iter->last_dead_count == *sequence) {
 		smp_rmb();
 		position = iter->last_visited;
-		if (position && !css_tryget(&position->css))
+		if (position && position != root &&
+		    !css_tryget(&position->css))
 			position = NULL;
 	}
 	return position;
 }
 
 static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
-				   struct mem_cgroup *last_visited,
 				   struct mem_cgroup *new_position,
 				   int sequence)
 {
-	if (last_visited)
-		css_put(&last_visited->css);
 	/*
 	 * We store the sequence count from the time @last_visited was
 	 * loaded successfully instead of rereading it here so that we
@@ -1234,7 +1232,10 @@ struct mem_cgroup *mem_cgroup_iter(struc
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
-			mem_cgroup_iter_update(iter, last_visited, memcg, seq);
+			if (last_visited && last_visited != root)
+				css_put(&last_visited->css);
+
+			mem_cgroup_iter_update(iter, memcg, seq);
 
 			if (!memcg)
 				iter->generation++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
