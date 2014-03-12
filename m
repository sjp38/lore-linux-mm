Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7A04C6B0044
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 21:28:59 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id mz13so1361857bkb.17
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:28:58 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id u5si9805615bkh.292.2014.03.11.18.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 18:28:58 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/8] memcg: remove unnecessary !mm check from try_get_mem_cgroup_from_mm()
Date: Tue, 11 Mar 2014 21:28:31 -0400
Message-Id: <1394587714-6966-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Users pass either a mm that has been established under task lock, or
use a verified current->mm, which means the task can't be exiting.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c40186cf22ad..1780e66ec61e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1075,13 +1075,6 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
 
-	if (!mm)
-		return NULL;
-	/*
-	 * Because we have no locks, mm->owner's may be being moved to other
-	 * cgroup. We use css_tryget() here even if this looks
-	 * pessimistic (rather than adding locks here).
-	 */
 	rcu_read_lock();
 	do {
 		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
