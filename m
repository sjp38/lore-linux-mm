Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5326B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 10:41:46 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so2160053eei.35
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 07:41:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g41si21291779eem.204.2014.01.17.07.41.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 07:41:44 -0800 (PST)
Date: Fri, 17 Jan 2014 16:41:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140117154143.GF5356@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
 <20140114132727.GB32227@dhcp22.suse.cz>
 <20140114142610.GF32227@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz>
 <20140115121728.GJ8782@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401151241280.9004@eggly.anvils>
 <20140116081738.GA28157@dhcp22.suse.cz>
 <20140116152259.GG28157@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401161011110.1321@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401161011110.1321@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 16-01-14 11:15:36, Hugh Dickins wrote:
> On Thu, 16 Jan 2014, Michal Hocko wrote:
> > From 543df5c82f6eec622f669ea322ba6ff03924fded Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 16 Jan 2014 16:17:13 +0100
> > Subject: [PATCH] memcg: fix css reference leak from mem_cgroup_iter
> > 
> > 19f39402864e (memcg: simplify mem_cgroup_iter) has introduced a css
> > refrence leak (thus memory leak) because mem_cgroup_iter makes sure it
> > doesn't put a css reference on the root of the tree walk. The mentioned
> > commit however dropped the root check when the css reference is taken
> > while it keept the css_put optimization fora the root in place.
> 
> I don't think that's quite right, actually - and I think it's all
> so confusing that we do need to be pedantic and set it down right.

You are right!

> I spent quite a while yesterday trying out my "cg m" on 3.10, 3.11,

I have done the same now (with a different test - simple mem_eater
with hard_limit really low to trigger reclaim and trace_printk in both
mem_cgroup_css_{alloc,free}) and you are right that 3.10 and 3.11 were
OK regarding the leak. Which is a relief...
3.12 resp. mmotm which I was testing on previously has the leak though.
So there must have been some other escape part which didn't allow
css_tryget on the root.

> 3.12 and 3.13-rc8 on this laptop: first just counting mem_cgroup_allocs
> and frees (if I could get that far without hanging or crashing), then
> also with your patch in (on 3.12 and 3.13-rc8) or the completely
> different patch appended at the bottom (on 3.10 and 3.11), checking
> for leftover mem_cgroups afterwards.
> 
> I saw no evidence of mem_cgroup leakage on 3.10 and 3.11, which had
> 	/*
> 	 * Root is not visited by cgroup iterators so it needs an
> 	 * explicit visit.
> 	 */
> 	if (!last_visited)
> 		return root;
> at the head of __mem_cgroup_iter_next(), removed around the same
> time as changeover from prev_cgroup etc to prev_css etc in 3.12.

Ohh, now I get it. Cgroup iterators originally didn't visit the root and
all the callers had to special case it. Then Tejun changed them to visit
root as well by bd8815a6d802 (cgroup: make css_for_each_descendant() and
friends include the origin css in the iteration) which was a good change
but I didn't realize it would be a problem when I reviewed it. Now it
makes sense again.

> I don't believe 19f39402864e was responsible for a reference leak,
> that came later.  But I think it was responsible for the original
> endless iteration (shrink_zone going around and around getting root
> again and again from mem_cgroup_iter).

So your hang is not within mem_cgroup_iter but you are getting root all
the time without any way out?

[3.10 code base]
shrink_zone
						[rmdir root]
  mem_cgroup_iter(root, NULL, reclaim)
    // prev = NULL
    rcu_read_lock()
    last_visited = iter->last_visited	// gets root || NULL
    css_tryget(last_visited) 		// failed
    last_visited = NULL			[1]
    memcg = root = __mem_cgroup_iter_next(root, NULL)
    iter->last_visited = root;
    reclaim->generation = iter->generation

 mem_cgroup_iter(root, root, reclaim)
   // prev = root
   rcu_read_lock
    last_visited = iter->last_visited	// gets root
    css_tryget(last_visited) 		// failed
    [1]

So we indeed can loop here without any progress. I just fail
to see how my patch could help. We even do not get down to
cgroup_next_descendant_pre.

Or am I missing something?

The following should fix this kind of endless loop:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 194721839cf5..168e5abcca92 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1221,7 +1221,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				smp_rmb();
 				last_visited = iter->last_visited;
 				if (last_visited &&
-				    !css_tryget(&last_visited->css))
+				    last_visited != root &&
+				     !css_tryget(&last_visited->css))
 					last_visited = NULL;
 			}
 		}
@@ -1229,7 +1230,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
-			if (last_visited)
+			if (last_visited && last_visited != root)
 				css_put(&last_visited->css);
 
 			iter->last_visited = memcg;

Not that I like it much :/

> But beware of my conclusion, please check for yourself: with my
> separate kbuilds in separate /cg/cg/? memcgs, what "cg m" is doing
> is very simple and segregated, can hardly be called testing reclaim
> iteration, so I hope you have something better to check it.  Plus
> I was testing on 3.10 and 3.11 vanilla, not latest stable versions.
> 
> (If I'm very honest, I'll admit that I still did not see that hang
> on 3.11 vanilla:

But I assume you can still reproduce it with 3.10, right?
I am sorry but I didn't get to run your script yet.

> what I hit was a crash in kfree instead, but the
> same patch got rid of that too. 

Care to post an oops?

> Of course I ought to investigate
> further, but at some point I just have to give up and move on,
> there's just too much breakage to chase all over the kernel...)
> 
> > This means that css_put is not called and so css along with mem_cgroup
> > and other cgroup internal object tied by css lifetime are never freed.
> > 
> > Fix the issue by reintroducing root check in __mem_cgroup_iter_next.
> > 
> > This patch also fixes issue reported by Hugh Dickins when
> > mem_cgroup_iter might end up in an endless loop because a group which is
> > under hard limit reclaim is removed in parallel with iteration.
> > __mem_cgroup_iter_next would always return NULL because css_tryget on
> > the root (reclaimed memcg) would fail and there are no other memcg in
> > the hierarchy. prev == NULL in mem_cgroup_iter would prevent break out
> > from the root and so the while (!memcg) loop would never terminate.
> > as css_tryget is no longer called for the root of the tree walk this
> > doesn't happen anymore.
> > 
> > [hughd@google.com: Fixed root vs. root->css fix]
> > [hughd@google.com: Get rid of else branch because it is ugly]
> 
> Thanks for your courtesy!  But let's not clutter it with those two.
> 
> > <Hugh's-selection>-by: Hugh Dickins <hughd@google.com>
> 
> You already credited me above, but "Reported-by:" here if you insist.
> 
> > Cc: stable@vger.kernel.org # 3.10+
> 
> Well, I'm okay with that, if we use that as a way to shoehorn in the
> patch at the bottom instead for 3.10 and 3.11 stables.

So far I do not see how it would make a change for those two kernels as
they have the special handling for root.

[...]
> "Equivalent" patch for 3.10 or 3.11: fixing similar hangs but no leakage.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> --- v3.10/mm/memcontrol.c	2013-06-30 15:13:29.000000000 -0700
> +++ linux/mm/memcontrol.c	2014-01-15 18:18:24.476566659 -0800
> @@ -1226,7 +1226,8 @@ struct mem_cgroup *mem_cgroup_iter(struc
>  			}
>  		}
>  
> -		memcg = __mem_cgroup_iter_next(root, last_visited);
> +		if (!prev || last_visited)
> +			memcg = __mem_cgroup_iter_next(root, last_visited);

I am confused. What would change between those two calls to change the
outcome? The function doesn't have any internal state.

>  
>  		if (reclaim) {
>  			if (last_visited)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
