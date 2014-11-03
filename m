Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D9F2F6B00F7
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:17 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so12225447pdj.38
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:17 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ca3si16187500pad.126.2014.11.03.13.00.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:16 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 5/8] memcg: free kmem cache id on css offline
Date: Mon, 3 Nov 2014 23:59:43 +0300
Message-ID: <6618a87bfb6bbad5c8a72f2d1fafedcfb6e93f6e.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This will allow new kmem active cgroups to reuse the id and therefore
the caches used by the dead memory cgroup.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 923fe4c29e92..755604079d8e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -605,14 +605,10 @@ int memcg_limited_groups_array_size;
 struct static_key memcg_kmem_enabled_key;
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-static void memcg_free_cache_id(int id);
-
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg)) {
+	if (memcg_kmem_is_active(memcg))
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		memcg_free_cache_id(memcg->kmemcg_id);
-	}
 	/*
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
@@ -4730,6 +4726,11 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	spin_unlock(&memcg->event_list_lock);
 
 	vmpressure_cleanup(&memcg->vmpressure);
+
+#ifdef CONFIG_MEMCG_KMEM
+	if (memcg_kmem_is_active(memcg))
+		memcg_free_cache_id(memcg_cache_id(memcg));
+#endif
 }
 
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
