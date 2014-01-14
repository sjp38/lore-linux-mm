Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3538D6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:26:13 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so4487342wib.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:26:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si1501745eev.5.2014.01.14.06.26.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 06:26:11 -0800 (PST)
Date: Tue, 14 Jan 2014 15:26:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140114142610.GF32227@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
 <20140114132727.GB32227@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114132727.GB32227@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-01-14 14:27:27, Michal Hocko wrote:
> On Mon 13-01-14 17:52:30, Hugh Dickins wrote:
> > On one home machine I can easily reproduce (by rmdir of memcgdir during
> > reclaim) multiple processes stuck looping forever in mem_cgroup_iter():
> > __mem_cgroup_iter_next() keeps selecting the memcg being destroyed, fails
> > to tryget it, returns NULL to mem_cgroup_iter(), which goes around again.
> 
> So you had a single memcg (without any children) and a limit-reclaim
> on it when you removed it, right?

Hmm, thinking about this once more how can this happen? There must be a
task to trigger the limit reclaim so the cgroup cannot go away (or is
this somehow related to kmem accounting?). Only if the taks was migrated
after the reclaim was initiated but before we started iterating?

I am confused now and have to rush shortly so I will think about it
tomorrow some more.

> This is nasty because __mem_cgroup_iter_next will try to skip it but
> there is nothing else so it returns NULL. We update iter->generation++
> but that doesn't help us as prev = NULL as this is the first iteration
> so
> 		if (prev && reclaim->generation != iter->generation)
> 
> break out will not help us.

> You patch will surely help I am just not sure it is the right thing to
> do. Let me think about this.

The patch is actually not correct after all. You are returning root
memcg without taking a reference. So there is a risk that memcg will
disappear. Although, it is true that the race with removal is not that
probable because mem_cgroup_css_offline (resp. css_free) will see some
pages on LRUs and they will reclaim as well.

Ouch. And thinking about this shows that out_css_put is broken as well
for subtree walks (those that do not start at root_mem_cgroup level). We
need something like the the snippet bellow.
I really hate this code, especially when I tried to de-obfuscate it and
that introduced other subtle issues.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1f9d14e2f8de..f75277b0bf82 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1080,7 +1080,7 @@ skip_node:
 	if (next_css) {
 		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
 
-		if (css_tryget(&mem->css))
+		if (mem == root_mem_cgroup || css_tryget(&mem->css))
 			return mem;
 		else {
 			prev_css = next_css;
@@ -1219,7 +1219,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 out_unlock:
 	rcu_read_unlock();
 out_css_put:
-	if (prev && prev != root)
+	if (prev && prev != root_mem_cgroup)
 		css_put(&prev->css);
 
 	return memcg;

> Anyway very well spotted!
> 
> > It's better to err on the side of leaving the loop too soon than never
> > when such races occur: once we've served prev (using root if none),
> > get out the next time __mem_cgroup_iter_next() cannot deliver.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> > Securing the tree iterator against such races is difficult, I've
> > certainly got it wrong myself before.  Although the bug is real, and
> > deserves a Cc stable, you may want to play around with other solutions
> > before committing to this one.  The current iterator goes back to v3.12:
> > I'm really not sure if v3.11 was good or not - I never saw the problem
> > in the vanilla kernel, but with Google mods in we also had to make an
> > adjustment, there to stop __mem_cgroup_iter() being called endlessly
> > from the reclaim level.
> > 
> >  mm/memcontrol.c |    5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > --- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
> > +++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
> > @@ -1254,8 +1252,11 @@ struct mem_cgroup *mem_cgroup_iter(struc
> >  				reclaim->generation = iter->generation;
> >  		}
> >  
> > -		if (prev && !memcg)
> > +		if (!memcg) {
> > +			if (!prev)
> > +				memcg = root;
> >  			goto out_unlock;
> > +		}
> >  	}
> >  out_unlock:
> >  	rcu_read_unlock();
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
