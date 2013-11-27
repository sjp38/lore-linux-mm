Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF4E86B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 10:46:12 -0500 (EST)
Received: by mail-lb0-f172.google.com with SMTP id z5so5594578lbh.31
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 07:46:12 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h4si12598833lam.41.2013.11.27.07.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 07:46:11 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: fix kmem_account_flags check in memcg_can_account_kmem()
Date: Wed, 27 Nov 2013 19:46:01 +0400
Message-ID: <1385567162-14973-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

We should start kmem accounting for a memory cgroup only after both its
kmem limit is set (KMEM_ACCOUNTED_ACTIVE) and related call sites are
patched (KMEM_ACCOUNTED_ACTIVATED). Currently memcg_can_account_kmem()
allows kmem accounting even if only one of the conditions is true.
Fix it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1a0ae6..40efb9d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2956,7 +2956,8 @@ static DEFINE_MUTEX(set_limit_mutex);
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
 	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
-		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK);
+		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK) ==
+							KMEM_ACCOUNTED_MASK;
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
