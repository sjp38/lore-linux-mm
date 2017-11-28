Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6603D6B0253
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:20:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so254310itc.9
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 08:20:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i201sor3226358ioe.352.2017.11.28.08.20.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 08:20:04 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm, memcg: fix mem_cgroup_swapout() for THPs
Date: Tue, 28 Nov 2017 08:19:41 -0800
Message-Id: <20171128161941.20931-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org

The commit d6810d730022 ("memcg, THP, swap: make mem_cgroup_swapout()
support THP") changed mem_cgroup_swapout() to support transparent huge
page (THP). However the patch missed one location which should be
changed for correctly handling THPs. The resulting bug will cause the
memory cgroups whose THPs were swapped out to become zombies on
deletion.

Fixes: d6810d730022 ("memcg, THP, swap: make mem_cgroup_swapout() support THP")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: stable@vger.kernel.org
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 50e6906314f8..ac2ffd5e02b9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6044,7 +6044,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	memcg_check_events(memcg, page);
 
 	if (!mem_cgroup_is_root(memcg))
-		css_put(&memcg->css);
+		css_put_many(&memcg->css, nr_entries);
 }
 
 /**
-- 
2.15.0.417.g466bffb3ac-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
