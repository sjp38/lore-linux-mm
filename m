Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 817666B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:02:34 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id fz5so115701030obc.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:02:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q14si14361757pfi.166.2016.03.11.07.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:02:33 -0800 (PST)
Date: Fri, 11 Mar 2016 18:02:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311150224.GQ1946@esperanza>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
 <20160311123900.GM1946@esperanza>
 <20160311125104.GM27701@dhcp22.suse.cz>
 <20160311134533.GN1946@esperanza>
 <20160311143031.GS27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311143031.GS27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2016 at 03:30:31PM +0100, Michal Hocko wrote:
> On Fri 11-03-16 16:45:34, Vladimir Davydov wrote:
> > On Fri, Mar 11, 2016 at 01:51:05PM +0100, Michal Hocko wrote:
> > > On Fri 11-03-16 15:39:00, Vladimir Davydov wrote:
> > > > On Fri, Mar 11, 2016 at 12:54:50PM +0100, Michal Hocko wrote:
> > > > > On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> > > > > > These fields are used for dumping info about allocation that triggered
> > > > > > OOM. For cgroup this information doesn't make much sense, because OOM
> > > > > > killer is always invoked from page fault handler.
> > > > > 
> > > > > The oom killer is indeed invoked in a different context but why printing
> > > > > the original mask and order doesn't make any sense? Doesn't it help to
> > > > > see that the reclaim has failed because of GFP_NOFS?
> > > > 
> > > > I don't see how this can be helpful. How would you use it?
> > > 
> > > If we start seeing GFP_NOFS triggered OOMs we might be enforced to
> > > rethink our current strategy to ignore this charge context for OOM.
> > 
> > IMO the fact that a lot of OOMs are triggered by GFP_NOFS allocations
> > can't be a good enough reason to reconsider OOM strategy.
> 
> What I meant was that the global OOM doesn't trigger OOM got !__GFP_FS
> while we do in the memcg charge path.

OK, missed your point, sorry.

> 
> > We need to
> > know what kind of allocation fails anyway, and the current OOM dump
> > gives us no clue about that.
> 
> We do print gfp_mask now so we know what was the charging context.
> 
> > Besides, what if OOM was triggered by GFP_NOFS by pure chance, i.e. it
> > would have been triggered by GFP_KERNEL if it had happened at that time?
> 
> Not really. GFP_KERNEL would allow to invoke some shrinkers which are
> GFP_NOFS incopatible.

Can't a GFP_NOFS allocation happen when there is no shrinkable objects
to drop so that there's no real difference between GFP_KERNEL and
GFP_NOFS?

> 
> > IMO it's just confusing.
> > 
> > >  
> > > > Wouldn't it be better to print err msg in try_charge anyway?
> > > 
> > > Wouldn't that lead to excessive amount of logged messages?
> > 
> > We could ratelimit these messages. Slab charge failures are already
> > reported to dmesg (see ___slab_alloc -> slab_out_of_memory) and nobody's
> > complained so far. Are there any non-slab GFP_NOFS allocations charged
> > to memcg?
> 
> I believe there might be some coming from FS via add_to_page_cache_lru.
> Especially when their mapping gfp_mask clears __GFP_FS. I haven't
> checked the code deeper but some of those might be called from the page
> fault path and trigger memcg OOM. I would have to look closer.

If you think this warning is really a must have, and you don't like to
warn about every charge failure, may be we could just print info about
allocation that triggered OOM right in mem_cgroup_oom, like the code
below does? I think it would be more-or-less equivalent to what we have
now except it wouldn't require storing gfp_mask on task_struct.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a217b1374c32..d8e130d14f5d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1604,6 +1604,8 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 	 */
 	css_get(&memcg->css);
 	current->memcg_in_oom = memcg;
+
+	pr_warn("Process ... triggered OOM in memcg ... gfp ...\n");
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
