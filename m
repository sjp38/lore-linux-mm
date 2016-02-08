Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D88E4830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 09:28:46 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id g73so196167309ioe.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 06:28:46 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g9si16884640iga.78.2016.02.08.06.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 06:28:46 -0800 (PST)
Date: Mon, 8 Feb 2016 17:28:35 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/5] mm: workingset: make shadow node shrinker memcg aware
Message-ID: <20160208142835.GB13379@esperanza>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <934ce4e1cfe42b57e8114c72a447656fe5a01267.1454864628.git.vdavydov@virtuozzo.com>
 <20160208062353.GE22202@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160208062353.GE22202@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 08, 2016 at 01:23:53AM -0500, Johannes Weiner wrote:
> On Sun, Feb 07, 2016 at 08:27:35PM +0300, Vladimir Davydov wrote:
> > Workingset code was recently made memcg aware, but shadow node shrinker
> > is still global. As a result, one small cgroup can consume all memory
> > available for shadow nodes, possibly hurting other cgroups by reclaiming
> > their shadow nodes, even though reclaim distances stored in its shadow
> > nodes have no effect. To avoid this, we need to make shadow node
> > shrinker memcg aware.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> This patch is straight forward, but there is one tiny thing that bugs
> me about it, and that is switching from available memory to the size
> of the active list. Because the active list can shrink drastically at
> runtime.

Yeah, active file lru is a volatile thing indeed. Not only can it shrink
rapidly, it can also grow in an instant (e.g. due to mark_page_accessed)
so you're right - sizing shadow node lru basing solely on the active lru
size would be too unpredictable.

> 
> It's true that both the shrinking of the active list and subsequent
> activations to regrow it will reduce the number of actionable
> refaults, and so it wouldn't be unreasonable to also shrink shadow
> nodes when the active list shrinks.
> 
> However, I think these are too many assumptions to encode in the
> shrinker, because it is only meant to prevent a worst-case explosion
> of radix tree nodes. I'd prefer it to be dumb and conservative.
> 
> Could we instead go with the current usage of the memcg? Whether
> reclaim happens globally or due to the memory limit, the usage at the
> time of reclaim gives a good idea of the memory is available to the
> group. But it's making less assumptions about the internal composition
> of the memcg's memory, and the consequences associated with that.

But that would likely result in wasting a considerable chunk of memory
for stale shadow nodes in case file caches constitute only a small part
of memcg memory consumption, which isn't good IMHO.

May be, we'd better use LRU_ALL_FILE / 2 instead?

diff --git a/mm/workingset.c b/mm/workingset.c
index 8c07cd8af15e..8a75f8d2916a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -351,9 +351,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 
 	if (memcg_kmem_enabled())
 		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
-						     BIT(LRU_ACTIVE_FILE));
+						     LRU_ALL_FILE);
 	else
-		pages = node_page_state(sc->nid, NR_ACTIVE_FILE);
+		pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
+			node_page_state(sc->nid, NR_INACTIVE_FILE);
 
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
@@ -369,7 +370,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 *
 	 * PAGE_SIZE / radix_tree_nodes / node_entries / PAGE_SIZE
 	 */
-	max_nodes = pages >> (RADIX_TREE_MAP_SHIFT - 3);
+	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
 
 	if (shadow_nodes <= max_nodes)
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
