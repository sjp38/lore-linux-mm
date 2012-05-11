Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 20A118D0010
	for <linux-mm@kvack.org>; Fri, 11 May 2012 13:48:00 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 01/29] slab: dup name string
Date: Fri, 11 May 2012 14:44:03 -0300
Message-Id: <1336758272-24284-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1336758272-24284-1-git-send-email-glommer@parallels.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

The slub allocator creates a copy of the name string, and
frees it later. I would like them both to behave the same,
whether it is the slab starting to create a copy of it itself,
or the slub ceasing to.

This is because when I create memcg copies of it, I have to
kmalloc strings for the new names, and having the allocators to
behave differently here, would make it a lot uglier.

My first submission removed the duplication for the slub. But
the code started to get a bit complicated when dealing with
deletion of chained caches. Also, Christoph voiced his opinion
that patching the slab to keep copies would be better.

So here it is.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/slab.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e901a36..91b9c13 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2118,6 +2118,7 @@ static void __kmem_cache_destroy(struct kmem_cache *cachep)
 			kfree(l3);
 		}
 	}
+	kfree(cachep->name);
 	kmem_cache_free(&cache_cache, cachep);
 }
 
@@ -2526,7 +2527,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
 	cachep->ctor = ctor;
-	cachep->name = name;
+	cachep->name = kstrdup(name, GFP_KERNEL);
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
