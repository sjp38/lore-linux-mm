Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id B10196B00E8
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:39 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr4so558265pbb.39
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:39 -0700 (PDT)
Received: from psmtp.com ([74.125.245.103])
        by mx.google.com with SMTP id w1si1769850pan.141.2013.10.24.05.05.37
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 12/15] memcg: allow kmem limit to be resized down
Date: Thu, 24 Oct 2013 16:05:03 +0400
Message-ID: <458dc248ec1a9b815231b8b5fbd1517db479e483.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

The userspace memory limit can be freely resized down. Upon attempt,
reclaim will be called to flush the pages away until we either reach the
limit we want or give up.

It wasn't possible so far with the kmem limit, since we had no way to
shrink the kmem buffers other than using the big hammer of shrink_slab,
that effectively frees data around the whole system.

The situation flips now that we have a per-memcg shrinker
infrastructure. We will proceed analogously to our user memory
counterpart and try to shrink our buffers until we either reach the
limit we want or give up.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   43 ++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 38 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 03178d0..7bf4dc7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5574,10 +5574,39 @@ static ssize_t mem_cgroup_read(struct cgroup_subsys_state *css,
 	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * This is slightly different than res or memsw reclaim.  We already have
+ * vmscan behind us to drive the reclaim, so we can basically keep trying until
+ * all buffers that can be flushed are flushed. We have a very clear signal
+ * about it in the form of the return value of try_to_free_mem_cgroup_kmem.
+ */
+static int mem_cgroup_resize_kmem_limit(struct mem_cgroup *memcg,
+					unsigned long long val)
+{
+	int ret = -EBUSY;
+
+	for (;;) {
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+
+		ret = res_counter_set_limit(&memcg->kmem, val);
+		if (!ret)
+			break;
+
+		/* Can't free anything, pointless to continue */
+		if (!try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL))
+			break;
+	}
+
+	return ret;
+}
+
 static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
 {
 	int ret = -EINVAL;
-#ifdef CONFIG_MEMCG_KMEM
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -5612,16 +5641,15 @@ static int memcg_update_kmem_limit(struct cgroup_subsys_state *css, u64 val)
 		 * starts accounting before all call sites are patched
 		 */
 		memcg_kmem_set_active(memcg);
-	} else
-		ret = res_counter_set_limit(&memcg->kmem, val);
+	} else {
+		ret = mem_cgroup_resize_kmem_limit(memcg, val);
+	}
 out:
 	mutex_unlock(&set_limit_mutex);
 	mutex_unlock(&memcg_create_mutex);
-#endif
 	return ret;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 {
 	int ret = 0;
@@ -5658,6 +5686,11 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 out:
 	return ret;
 }
+#else
+static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
+{
+	return -EINVAL;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
