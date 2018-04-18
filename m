Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 229BA6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:23:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so976741pfh.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:23:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor318329pfa.109.2018.04.18.06.23.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 06:23:34 -0700 (PDT)
Date: Wed, 18 Apr 2018 22:23:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180418132328.GB210164@rodete-desktop-imager.corp.google.com>
References: <20180418022912.248417-1-minchan@kernel.org>
 <20180418072002.GN17484@dhcp22.suse.cz>
 <20180418074117.GA210164@rodete-desktop-imager.corp.google.com>
 <20180418075437.GP17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418075437.GP17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Apr 18, 2018 at 09:54:37AM +0200, Michal Hocko wrote:
> On Wed 18-04-18 16:41:17, Minchan Kim wrote:
> > On Wed, Apr 18, 2018 at 09:20:02AM +0200, Michal Hocko wrote:
> > > On Wed 18-04-18 11:29:12, Minchan Kim wrote:
> [...]
> > > > Let's not make user scared.
> > > 
> > > This is not a proper explanation. So what exactly happens when this
> > > allocation fails? I would suggest something like the following
> > > "
> > > __memcg_schedule_kmem_cache_create tries to create a shadow slab cache
> > > and the worker allocation failure is not really critical because we will
> > > retry on the next kmem charge. We might miss some charges but that
> > > shouldn't be critical. The excessive allocation failure report is not
> > > very much helpful. Replace it with a rate limited single line output so
> > > that we know that there is a lot of these failures and that we need to
> > > do something about it in future.
> > > "
> > > 
> > > With the last part to be implemented of course.
> > 
> > If you want to see warning and catch on it in future, I don't see any reason
> > to change it. Because I didn't see any excessive warning output that it could
> > make system slow unless we did ratelimiting.
> 
> Yeah, but a single line would be as much informative and less scary to
> users.
> 
> > It was a just report from non-MM guys who have a concern that somethings
> > might go wrong on the system. I just wanted them relax since it's not
> > critical.
> 
> I do agree with __GFP_NOWARN but I think a single line warning is due
> and helpful for further debugging.

Okay, no problem. However, I don't feel we need ratelimit at this moment.
We can do when we got real report. Let's add just one line warning.
However, I have no talent to write a poem to express with one line.
Could you help me?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 671d07e73a3b..e26f85cac63f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2201,8 +2201,11 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
        struct memcg_kmem_cache_create_work *cw;

        cw = kmalloc(sizeof(*cw), GFP_NOWAIT | __GFP_NOWARN);
-       if (!cw)
+       if (!cw) {
+               pr_warn("Fail to create shadow slab cache for memcg but it's not critical.\n");
+               pr_warn("If you see lots of this message, send an email to linux-mm@kvack.org\n");
                return;
+       }

        css_get(&memcg->css);
