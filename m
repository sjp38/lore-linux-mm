Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E9D656B00EA
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:45 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so2351930pdj.10
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id mj9si1762693pab.190.2013.10.24.05.05.44
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:45 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 15/15] memcg: flush memcg items upon memcg destruction
Date: Thu, 24 Oct 2013 16:05:06 +0400
Message-ID: <d5a0fce2a7812cbfccd8950e5b0cc72b99b5160c.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

When a memcg is destroyed, it won't be imediately released until all
objects are gone. This means that if a memcg is restarted with the very
same workload - a very common case, the objects already cached won't be
billed to the new memcg. This is mostly undesirable since a container
can exploit this by restarting itself every time it reaches its limit,
and then coming up again with a fresh new limit.

Since now we have targeted reclaim, I sustain that we should assume that
a memcg that is destroyed should be flushed away. It makes perfect sense
if we assume that a memcg that goes away most likely indicates an
isolated workload that is terminated.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 628ea0d..6dadbbe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6441,12 +6441,29 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
+	int ret;
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
 	cancel_work_sync(&memcg->kmemcg_shrink_work);
 
 	/*
+	 * When a memcg is destroyed, it won't be imediately released until all
+	 * objects are gone. This means that if a memcg is restarted with the
+	 * very same workload - a very common case, the objects already cached
+	 * won't be billed to the new memcg. This is mostly undesirable since a
+	 * container can exploit this by restarting itself every time it
+	 * reaches its limit, and then coming up again with a fresh new limit.
+	 *
+	 * Therefore a memcg that is destroyed should be flushed away. It makes
+	 * perfect sense if we assume that a memcg that goes away indicates an
+	 * isolated workload that is terminated.
+	 */
+	do {
+		ret = try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL);
+	} while (ret);
+
+	/*
 	 * kmem charges can outlive the cgroup. In the case of slab
 	 * pages, for instance, a page contain objects from various
 	 * processes. As we prevent from taking a reference for every
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
