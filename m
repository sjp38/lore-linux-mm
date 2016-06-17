Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95DAB6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:26:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so695269wmr.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:26:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k2si12839484wjs.220.2016.06.17.09.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 09:26:26 -0700 (PDT)
Date: Fri, 17 Jun 2016 12:23:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] cgroup: fix idr leak for the first cgroup root
Message-ID: <20160617162359.GB19084@cmpxchg.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617162310.GA19084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The valid cgroup hierarchy ID range includes 0, so we can't filter for
positive numbers when freeing it, or it'll leak the first ID. No big
deal, just disruptive when reading the code.

The ID is freed during error handling and when the reference count
hits zero, so the double-free test is not necessary; remove it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/cgroup.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 86cb5c6e8932..36fc0ff506c3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1158,18 +1158,12 @@ static void cgroup_exit_root_id(struct cgroup_root *root)
 {
 	lockdep_assert_held(&cgroup_mutex);
 
-	if (root->hierarchy_id) {
-		idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
-		root->hierarchy_id = 0;
-	}
+	idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
 }
 
 static void cgroup_free_root(struct cgroup_root *root)
 {
 	if (root) {
-		/* hierarchy ID should already have been released */
-		WARN_ON_ONCE(root->hierarchy_id);
-
 		idr_destroy(&root->cgroup_idr);
 		kfree(root);
 	}
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
