Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id B7F596B0069
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:02 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id eh20so8176582lab.33
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:02 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si26419732lal.147.2013.12.02.03.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 01/18] memcg: make cache index determination more robust
Date: Mon, 2 Dec 2013 15:19:36 +0400
Message-ID: <a35230f1d3fd31dfadfdf34f49c643cba3c75904.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1a0ae6..02b5176 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3073,7 +3073,9 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
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
