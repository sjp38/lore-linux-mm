Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBC656B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:28:47 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i77-v6so3173808ywe.19
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:28:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15-v6sor1213581ybm.23.2018.07.27.12.28.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 12:28:44 -0700 (PDT)
Date: Fri, 27 Jul 2018 15:31:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180727193134.GA10996@cmpxchg.org>
References: <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
 <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
 <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
 <20180413125101.GO17484@dhcp22.suse.cz>
 <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 04:25:12PM -0700, Andrew Morton wrote:
> On Fri, 13 Apr 2018 14:51:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 13-04-18 14:14:33, Michal Hocko wrote:
> > [...]
> > > Well, this is probably a matter of taste. I will not argue. I will not
> > > object if Johannes is OK with your patch. But the whole thing confused
> > > hell out of me so I would rather un-clutter it...
> > 
> > In other words, this
> > 
> 
> This discussion has rather petered out.  afaict we're waiting for
> hannes to offer an opinion?
> 
> 
> From: Kirill Tkhai <ktkhai@virtuozzo.com>
> Subject: memcg: remove memcg_cgroup::id from IDR on mem_cgroup_css_alloc() failure
> 
> In case of memcg_online_kmem() failure, memcg_cgroup::id remains hashed in
> mem_cgroup_idr even after memcg memory is freed.  This leads to leak of ID
> in mem_cgroup_idr.
> 
> This patch adds removal into mem_cgroup_css_alloc(), which fixes the
> problem.  For better readability, it adds a generic helper which is used
> in mem_cgroup_alloc() and mem_cgroup_id_put_many() as well.
> 
> Link: http://lkml.kernel.org/r/152354470916.22460.14397070748001974638.stgit@localhost.localdomain
> Fixes 73f576c04b94 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I also do wonder if we can do it cleaner, but since it's a fix I don't
want that discussion to hold things up:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

That said, the lifetime of the root reference on the ID is the online
state, we put that in css_offline. Is there a reason we need to have
the ID ready and the memcg in the IDR before onlining it? Can we do
something like this and not mess with the alloc/free sequence at all?

Michal, Vladimir, am I missing something?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c59519d600ea..865e6d41d3d1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4144,12 +4144,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
-	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
-				 1, MEM_CGROUP_ID_MAX,
-				 GFP_KERNEL);
-	if (memcg->id.id < 0)
-		goto fail;
-
 	memcg->stat_cpu = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat_cpu)
 		goto fail;
@@ -4176,11 +4170,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
-	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
-	if (memcg->id.id > 0)
-		idr_remove(&mem_cgroup_idr, memcg->id.id);
 	__mem_cgroup_free(memcg);
 	return NULL;
 }
@@ -4246,10 +4237,17 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	int i;
+
+	i = idr_alloc(&mem_cgroup_idr, memcg, 1, MEM_CGROUP_ID_MAX, GFP_KERNEL);
+	if (i < 0)
+		return i;
 
 	/* Online state pins memcg ID, memcg ID pins CSS */
+	memcg->id.id = i;
 	atomic_set(&memcg->id.ref, 1);
 	css_get(css);
+
 	return 0;
 }
 
