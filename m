Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 361576B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:48:16 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so24628596lbp.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 05:48:15 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x5si5809806lbb.5.2015.09.18.05.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 05:48:14 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] vmscan: fix sane_reclaim helper for legacy memcg
Date: Fri, 18 Sep 2015 15:48:00 +0300
Message-ID: <1442580480-30829-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The sane_reclaim() helper is supposed to return false for memcg reclaim
if the legacy hierarchy is used, because the latter lacks dirty
throttling mechanism, and so it did before it was accidentally broken by
commit 33398cf2f360c ("memcg: export struct mem_cgroup"). Fix it.

Fixes: 33398cf2f360c ("memcg: export struct mem_cgroup")
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index db5339dd4a32..dbc3b3ae48de 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -175,7 +175,7 @@ static bool sane_reclaim(struct scan_control *sc)
 	if (!memcg)
 		return true;
 #ifdef CONFIG_CGROUP_WRITEBACK
-	if (memcg->css.cgroup)
+	if (cgroup_on_dfl(memcg->css.cgroup))
 		return true;
 #endif
 	return false;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
