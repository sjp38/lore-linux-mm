Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 120482802FE
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:39:49 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c189so20514289oia.13
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 20:39:49 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u4si2720048oig.391.2017.06.28.20.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 20:39:48 -0700 (PDT)
From: Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH v4 2/2] fs/dcache.c: fix spin lockup issue on nlru->lock
Date: Thu, 29 Jun 2017 09:09:35 +0530
Message-Id: <1498707575-2472-1-git-send-email-stummala@codeaurora.org>
In-Reply-To: <20170628171854.t4sjyjv55j673qzv@esperanza>
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Sahitya Tummala <stummala@codeaurora.org>

__list_lru_walk_one() acquires nlru spin lock (nlru->lock) for
longer duration if there are more number of items in the lru list.
As per the current code, it can hold the spin lock for upto maximum
UINT_MAX entries at a time. So if there are more number of items in
the lru list, then "BUG: spinlock lockup suspected" is observed in
the below path -

[<ffffff8eca0fb0bc>] spin_bug+0x90
[<ffffff8eca0fb220>] do_raw_spin_lock+0xfc
[<ffffff8ecafb7798>] _raw_spin_lock+0x28
[<ffffff8eca1ae884>] list_lru_add+0x28
[<ffffff8eca1f5dac>] dput+0x1c8
[<ffffff8eca1eb46c>] path_put+0x20
[<ffffff8eca1eb73c>] terminate_walk+0x3c
[<ffffff8eca1eee58>] path_lookupat+0x100
[<ffffff8eca1f00fc>] filename_lookup+0x6c
[<ffffff8eca1f0264>] user_path_at_empty+0x54
[<ffffff8eca1e066c>] SyS_faccessat+0xd0
[<ffffff8eca084e30>] el0_svc_naked+0x24

This nlru->lock is acquired by another CPU in this path -

[<ffffff8eca1f5fd0>] d_lru_shrink_move+0x34
[<ffffff8eca1f6180>] dentry_lru_isolate_shrink+0x48
[<ffffff8eca1aeafc>] __list_lru_walk_one.isra.10+0x94
[<ffffff8eca1aec34>] list_lru_walk_node+0x40
[<ffffff8eca1f6620>] shrink_dcache_sb+0x60
[<ffffff8eca1e56a8>] do_remount_sb+0xbc
[<ffffff8eca1e583c>] do_emergency_remount+0xb0
[<ffffff8eca0ba510>] process_one_work+0x228
[<ffffff8eca0bb158>] worker_thread+0x2e0
[<ffffff8eca0c040c>] kthread+0xf4
[<ffffff8eca084dd0>] ret_from_fork+0x10

Fix this lockup by reducing the number of entries to be shrinked
from the lru list to 1024 at once. Also, add cond_resched() before
processing the lru list again.

Link: http://marc.info/?t=149722864900001&r=1&w=2
Fix-suggested-by: Jan kara <jack@suse.cz>
Fix-suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
---
 fs/dcache.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index a9f995f..1161390 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1133,11 +1133,12 @@ void shrink_dcache_sb(struct super_block *sb)
 		LIST_HEAD(dispose);
 
 		freed = list_lru_walk(&sb->s_dentry_lru,
-			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
+			dentry_lru_isolate_shrink, &dispose, 1024);
 
 		this_cpu_sub(nr_dentry_unused, freed);
 		shrink_dentry_list(&dispose);
-	} while (freed > 0);
+		cond_resched();
+	} while (list_lru_count(&sb->s_dentry_lru) > 0);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
