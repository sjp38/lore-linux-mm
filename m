Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE06C6B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:04:31 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id i38so18661540iod.6
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:04:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 39si9985853iog.321.2017.11.21.04.04.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 04:04:30 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
Date: Tue, 21 Nov 2017 21:04:13 +0900
Message-Id: <1511265853-15654-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

There are users calling unregister_shrinker() when register_shrinker()
failed. Add sanity check to unregister_shrinker().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/vmscan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850..9e100cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -297,6 +297,8 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	if (!shrinker->nr_deferred)
+		return;
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
