Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id DEF95828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 17:00:55 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id x67so377767046ykd.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 14:00:55 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id x134si1408147ywd.55.2016.01.08.14.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 14:00:55 -0800 (PST)
Received: by mail-yk0-x229.google.com with SMTP id k129so354930210yke.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 14:00:54 -0800 (PST)
Date: Fri, 8 Jan 2016 17:00:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] cgroup, memcg, writeback: drop spurious rcu locking around
 mem_cgroup_css_from_page()
Message-ID: <20160108220053.GB1898@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jens Axboe <axboe@kernel.dk>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

In earlier versions, mem_cgroup_css_from_page() could return non-root
css on a legacy hierarchy which can go away and required rcu locking;
however, the eventual version simply returns the root cgroup if memcg
is on a legacy hierarchy and thus doesn't need rcu locking around or
in it.  Remove spurious rcu lockings.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/fs-writeback.c |    2 --
 mm/memcontrol.c   |    3 ---
 2 files changed, 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 023f6a1..6915c95 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -677,9 +677,7 @@ void wbc_account_io(struct writeback_control *wbc, struct page *page,
 	if (!wbc->wb)
 		return;
 
-	rcu_read_lock();
 	id = mem_cgroup_css_from_page(page)->id;
-	rcu_read_unlock();
 
 	if (id == wbc->wb_id) {
 		wbc->wb_bytes += bytes;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fc10620..3230201 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -431,14 +431,11 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
 {
 	struct mem_cgroup *memcg;
 
-	rcu_read_lock();
-
 	memcg = page->mem_cgroup;
 
 	if (!memcg || !cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		memcg = root_mem_cgroup;
 
-	rcu_read_unlock();
 	return &memcg->css;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
