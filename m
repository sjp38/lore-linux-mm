Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB0076B0338
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 17:56:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v1so18921054pgv.8
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 14:56:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x3si7261036plb.1.2017.04.28.14.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 14:56:51 -0700 (PDT)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH 1/2] mm/memcontrol: check cmpxchg(iter->pos...) result in mem_cgroup_iter()
Date: Fri, 28 Apr 2017 14:55:46 -0700
Message-Id: <1493416547-19212-2-git-send-email-sean.j.christopherson@intel.com>
In-Reply-To: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
References: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, sean.j.christopherson@intel.com

Check the return value of cmpxchg when updating iter->position in
mem_cgroup_iter().  If cmpxchg failed, i.e. a different thread won
the race to update iter->position, then restart the entire flow of
reading, processing and updating iter->position.  Simply ensuring
that there aren't multiple writes to iter->position doesn't avoid
redundant reclaims of a memcg, as competing threads will compute
the same memcg given the same iter->position.

The cmpxchg will only fail if a different thread saw the same value
of iter->position, meaning it called css_next_descendant_pre() with
the same css and therefore computed the same memcg (ignoring the
corner case where the threads see different versions of the tree).

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 mm/memcontrol.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 16c556a..6a7ca3c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -758,6 +758,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	rcu_read_lock();
 
+start:
 	if (reclaim) {
 		struct mem_cgroup_per_node *mz;
 
@@ -818,11 +819,27 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	if (reclaim) {
 		/*
-		 * The position could have already been updated by a competing
-		 * thread, so check that the value hasn't changed since we read
-		 * it to avoid reclaiming from the same cgroup twice.
+		 * Competing reclaim threads may attempt to consume the same
+		 * iter->position, check that the value hasn't changed since
+		 * we read it to avoid reclaiming from the same cgroup twice.
+		 * Note that just avoiding multiple writes to iter->position
+		 * does not prevent redundant reclaims to memcg.  Given the
+		 * same input css on competing threads, the css returned by
+		 * css_next_descendant_pre will also be the same (unless the
+		 * tree itself changes).  So, if a different thread read the
+		 * same iter->position, then it also computed the same memcg.
+		 * If we lost the race, put our css references and restart
+		 * the entire process of reading and updating iter->position.
 		 */
-		(void)cmpxchg(&iter->position, pos, memcg);
+		if (cmpxchg(&iter->position, pos, memcg) != pos) {
+			if (memcg && memcg != root)
+				css_put(&memcg->css);
+			if (pos)
+				css_put(&pos->css);
+			css = NULL;
+			memcg = NULL;
+			goto start;
+		}
 
 		if (pos)
 			css_put(&pos->css);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
