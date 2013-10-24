Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0616F6B00E0
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:24 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2993726pad.21
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:24 -0700 (PDT)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id js8si827745pbc.44.2013.10.24.05.05.23
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:24 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 01/15] memcg: make cache index determination more robust
Date: Thu, 24 Oct 2013 16:04:52 +0400
Message-ID: <8a57aeb96530f5f256d81b71fce24ac46b988374.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

I caught myself doing something like the following outside memcg core:

	memcg_id = -1;
	if (memcg && memcg_kmem_is_active(memcg))
		memcg_id = memcg_cache_id(memcg);

to be able to handle all possible memcgs in a sane manner. In particular, the
root cache will have kmemcg_id = -1 (just because we don't call memcg_kmem_init
to the root cache since it is not limitable). We have always coped with that by
making sure we sanitize which cache is passed to memcg_cache_id. Although this
example is given for root, what we really need to know is whether or not a
cache is kmem active.

But outside the memcg core testing for root, for instance, is not trivial since
we don't export mem_cgroup_is_root. I ended up realizing that this tests really
belong inside memcg_cache_id. This patch moves a similar but stronger test
inside memcg_cache_id and make sure it always return a meaningful value.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 34d3ca9..0712277 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3057,7 +3057,9 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
  */
 int memcg_cache_id(struct mem_cgroup *memcg)
 {
-	return memcg ? memcg->kmemcg_id : -1;
+	if (!memcg || !memcg_can_account_kmem(memcg))
+		return -1;
+	return memcg->kmemcg_id;
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
