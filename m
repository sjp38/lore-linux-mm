Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33AFC6B0279
	for <linux-mm@kvack.org>; Sun, 11 Jun 2017 20:47:55 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 36so31706443otv.7
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 17:47:55 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u132si2624422oia.239.2017.06.11.17.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Jun 2017 17:47:53 -0700 (PDT)
From: Sahitya Tummala <stummala@codeaurora.org>
Subject: [PATCH] mm/list_lru.c: use cond_resched_lock() for nlru->lock
Date: Mon, 12 Jun 2017 06:17:20 +0530
Message-Id: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Sahitya Tummala <stummala@codeaurora.org>

__list_lru_walk_one() can hold the spin lock for longer duration
if there are more number of entries to be isolated.

This results in "BUG: spinlock lockup suspected" in the below path -

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

This nlru->lock has been acquired by another CPU in this path -

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

Link: http://marc.info/?t=149511514800002&r=1&w=2
Fix-suggested-by: Jan kara <jack@suse.cz>
Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
---
 mm/list_lru.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 5d8dffd..1af0709 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -249,6 +249,8 @@ restart:
 		default:
 			BUG();
 		}
+		if (cond_resched_lock(&nlru->lock))
+			goto restart;
 	}
 
 	spin_unlock(&nlru->lock);
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
