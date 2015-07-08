Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 167496B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 08:28:04 -0400 (EDT)
Received: by wiga1 with SMTP id a1so283610088wig.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 05:28:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si3712815wjx.17.2015.07.08.05.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 05:28:02 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/8] memcg: get rid of mem_cgroup_root_css for !CONFIG_MEMCG
Date: Wed,  8 Jul 2015 14:27:46 +0200
Message-Id: <1436358472-29137-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The only user is cgwb_bdi_init and that one depends on
CONFIG_CGROUP_WRITEBACK which in turn depends on CONFIG_MEMCG
so it doesn't make much sense to definte an empty stub for
!CONFIG_MEMCG. Moreover ERR_PTR(-EINVAL) is ugly and would lead
to runtime crashes if used in unguarded code paths. Better fail
during compilation.

Signed-off-by: Michal Hocko <mhocko@kernel.org>
---
 include/linux/memcontrol.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f5a8d0bbef8d..680cefec8c2a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -496,8 +496,6 @@ void mem_cgroup_split_huge_fixup(struct page *head);
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
