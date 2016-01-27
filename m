Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 658CA6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:29:08 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so7174309pfd.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:29:08 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id n5si10423468pfj.17.2016.01.27.08.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 08:29:07 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] vmpressure: Fix subtree pressure detection
Date: Wed, 27 Jan 2016 19:28:57 +0300
Message-ID: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When vmpressure is called for the entire subtree under pressure we
mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
when checking if vmpressure work is to be scheduled. This results in
suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
it.

Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmpressure.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 9a6c0704211c..149fdf6c5c56 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -248,9 +248,8 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 
 	if (tree) {
 		spin_lock(&vmpr->sr_lock);
-		vmpr->tree_scanned += scanned;
+		scanned = vmpr->tree_scanned += scanned;
 		vmpr->tree_reclaimed += reclaimed;
-		scanned = vmpr->scanned;
 		spin_unlock(&vmpr->sr_lock);
 
 		if (scanned < vmpressure_win)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
