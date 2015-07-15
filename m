Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3314C28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:15:15 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so30756827wgk.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:14 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id by11si8452342wib.105.2015.07.15.04.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:15:13 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so37700165wic.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/5] memcg: get rid of mem_cgroup_root_css for !CONFIG_MEMCG
Date: Wed, 15 Jul 2015 13:14:42 +0200
Message-Id: <1436958885-18754-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The only user is cgwb_bdi_init and that one depends on
CONFIG_CGROUP_WRITEBACK which in turn depends on CONFIG_MEMCG
so it doesn't make much sense to definte an empty stub for
!CONFIG_MEMCG. Moreover ERR_PTR(-EINVAL) is ugly and would lead
to runtime crashes if used in unguarded code paths. Better fail
during compilation.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Michal Hocko <mhocko@kernel.org>
---
 include/linux/memcontrol.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 42f118ae04cf..292e6701f3fd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -497,8 +497,6 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
-#define mem_cgroup_root_css ((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
-
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 				     enum mem_cgroup_events_index idx,
 				     unsigned int nr)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
