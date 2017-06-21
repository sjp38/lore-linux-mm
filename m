Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30CCE6B0397
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:39:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k126so98817269oia.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 23:39:40 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f184si4749510oih.322.2017.06.20.23.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 23:39:38 -0700 (PDT)
From: Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH v2] fs/dcache.c: fix spin lockup issue on nlru->lock
Date: Wed, 21 Jun 2017 12:09:15 +0530
Message-Id: <1498027155-4456-1-git-send-email-stummala@codeaurora.org>
In-Reply-To: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
References: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
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
v2: patch shrink_dcache_sb() instead of list_lru_walk()
---
 fs/dcache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index cddf397..c8ca150 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1133,10 +1133,11 @@ void shrink_dcache_sb(struct super_block *sb)
 		LIST_HEAD(dispose);
 
 		freed = list_lru_walk(&sb->s_dentry_lru,
-			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
+			dentry_lru_isolate_shrink, &dispose, 1024);
 
 		this_cpu_sub(nr_dentry_unused, freed);
 		shrink_dentry_list(&dispose);
+		cond_resched();
 	} while (freed > 0);
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
