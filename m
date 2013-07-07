Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 163FE6B0068
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:32 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id r10so3110276lbi.20
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:30 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 13/16] memcg: allow kmem limit to be resized down
Date: Sun,  7 Jul 2013 11:56:53 -0400
Message-Id: <1373212616-11713-14-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>

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
 mm/memcontrol.c | 43 ++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 38 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cce8a22..8623172 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5446,10 +5446,39 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
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
 static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 {
 	int ret = -EINVAL;
-#ifdef CONFIG_MEMCG_KMEM
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -5484,16 +5513,15 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
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
@@ -5530,6 +5558,11 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
