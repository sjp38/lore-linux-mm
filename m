Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 207146B0267
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:25:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so77443745lfw.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:25:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g8si16507606wmf.22.2016.08.01.08.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 08:24:59 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so26655773wme.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:24:59 -0700 (PDT)
Date: Mon, 1 Aug 2016 17:24:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801152454.GK13544@dhcp22.suse.cz>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
 <20160801135757.GB19395@esperanza>
 <20160801141227.GI13544@dhcp22.suse.cz>
 <20160801150343.GA7603@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801150343.GA7603@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 01-08-16 11:03:43, Johannes Weiner wrote:
> On Mon, Aug 01, 2016 at 04:12:28PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c265212bec8c..c0b57b6a194e 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2543,6 +2543,11 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  	return ret;
> >  }
> >  
> > +static inline bool soft_limit_tree_empty(struct mem_cgroup_tree_per_node *mctz)
> > +{
> > +	return RB_EMPTY_ROOT(&mctz->rb_root);
> > +}
> 
> Can you please fold this into the caller? It should be obvious enough.

OK, fair enough. There will probably be no other callers. I've added
comment as well

> Other than that, this patch makes sense to me.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

If the following sounds good I will resend v2.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c0b57b6a194e..e56d6a0f92ac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2543,11 +2543,6 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
-static inline bool soft_limit_tree_empty(struct mem_cgroup_tree_per_node *mctz)
-{
-	return RB_EMPTY_ROOT(&mctz->rb_root);
-}
-
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 					    gfp_t gfp_mask,
 					    unsigned long *total_scanned)
@@ -2564,7 +2559,13 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 		return 0;
 
 	mctz = soft_limit_tree_node(pgdat->node_id);
-	if (soft_limit_tree_empty(mctz))
+
+	/*
+	 * Do not even bother to check the largest node if the node
+	 * is empty. Do it lockless to prevent lock bouncing. Races
+	 * are acceptable as soft limit is best effort anyway.
+	 */
+	if (RB_EMPTY_ROOT(&mctz->rb_root))
 		return 0;
 
 	/*

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
