Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6494A82F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:07:30 -0500 (EST)
Received: by lbbwb3 with SMTP id wb3so77278960lbb.1
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:07:29 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g129si4496497lfb.151.2015.11.07.12.07.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 12:07:28 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/5] Revert "kernfs: do not account ino_ida allocations to memcg"
Date: Sat, 7 Nov 2015 23:07:05 +0300
Message-ID: <c468a2d2b39d755de2383c6ae49be6a53360a22b.1446924358.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1446924358.git.vdavydov@virtuozzo.com>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This reverts commit 499611ed451508a42d1d7d1faff10177827755d5.

Black-list kmem accounting policy (aka __GFP_NOACCOUNT) turned out to be
fragile and difficult to maintain, because there seem to be many more
allocations that should not be accounted than those that should be.
Besides, false accounting an allocation might result in much worse
consequences than not accounting at all, namely increased memory
consumption due to pinned dead kmem caches.

So it was decided to switch to the white-list policy. This patch reverts
bits introducing the black-list policy. The white-list policy will be
introduced later in the series.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 fs/kernfs/dir.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 91e004518237..0239a0a76ed5 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -541,14 +541,7 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 	if (!kn)
 		goto err_out1;
 
-	/*
-	 * If the ino of the sysfs entry created for a kmem cache gets
-	 * allocated from an ida layer, which is accounted to the memcg that
-	 * owns the cache, the memcg will get pinned forever. So do not account
-	 * ino ida allocations.
-	 */
-	ret = ida_simple_get(&root->ino_ida, 1, 0,
-			     GFP_KERNEL | __GFP_NOACCOUNT);
+	ret = ida_simple_get(&root->ino_ida, 1, 0, GFP_KERNEL);
 	if (ret < 0)
 		goto err_out2;
 	kn->ino = ret;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
