Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 043916B0253
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 16:14:20 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so51076432qkc.3
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 13:14:19 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id v111si9324284qge.10.2015.09.13.13.14.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 13:14:19 -0700 (PDT)
Received: by qgev79 with SMTP id v79so100551777qge.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 13:14:18 -0700 (PDT)
Date: Sun, 13 Sep 2015 16:14:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/3] memcg: collect kmem bypass conditions into
 __memcg_kmem_bypass()
Message-ID: <20150913201416.GC25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

memcg_kmem_newpage_charge() and memcg_kmem_get_cache() are testing the
same series of conditions to decide whether to bypass kmem accounting.
Collect the tests into __memcg_kmem_bypass().

This is pure refactoring.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
Hello,

These three patches are on top of mmotm as of Sep 13th and the two
patches from the following thread.

 http://lkml.kernel.org/g/20150913185940.GA25369@htj.duckdns.org

Thanks.

 include/linux/memcontrol.h |   46 +++++++++++++++++++++------------------------
 1 file changed, 22 insertions(+), 24 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -776,20 +776,7 @@ int memcg_charge_kmem(struct mem_cgroup
 		      unsigned long nr_pages);
 void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
 
-/**
- * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
- * @gfp: the gfp allocation flags.
- * @memcg: a pointer to the memcg this was charged against.
- * @order: allocation order.
- *
- * returns true if the memcg where the current task belongs can hold this
- * allocation.
- *
- * We return true automatically if this allocation is not to be accounted to
- * any memcg.
- */
-static inline bool
-memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
+static inline bool __memcg_kmem_bypass(gfp_t gfp)
 {
 	if (!memcg_kmem_enabled())
 		return true;
@@ -811,6 +798,26 @@ memcg_kmem_newpage_charge(gfp_t gfp, str
 	if (unlikely(fatal_signal_pending(current)))
 		return true;
 
+	return false;
+}
+
+/**
+ * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
+ * @gfp: the gfp allocation flags.
+ * @memcg: a pointer to the memcg this was charged against.
+ * @order: allocation order.
+ *
+ * returns true if the memcg where the current task belongs can hold this
+ * allocation.
+ *
+ * We return true automatically if this allocation is not to be accounted to
+ * any memcg.
+ */
+static inline bool
+memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
+{
+	if (__memcg_kmem_bypass(gfp))
+		return true;
 	return __memcg_kmem_newpage_charge(gfp, memcg, order);
 }
 
@@ -853,17 +860,8 @@ memcg_kmem_commit_charge(struct page *pa
 static __always_inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
-	if (!memcg_kmem_enabled())
-		return cachep;
-	if (gfp & __GFP_NOACCOUNT)
-		return cachep;
-	if (gfp & __GFP_NOFAIL)
+	if (__memcg_kmem_bypass(gfp))
 		return cachep;
-	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
-		return cachep;
-	if (unlikely(fatal_signal_pending(current)))
-		return cachep;
-
 	return __memcg_kmem_get_cache(cachep);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
