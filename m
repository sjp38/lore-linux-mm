Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADBE06B0069
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 06:36:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y71so5700829ita.4
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 03:36:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 65si9402685iti.86.2017.11.24.03.36.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 03:36:51 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2 2/2] mm,vmscan: Mark register_shrinker() as __must_check
Date: Fri, 24 Nov 2017 20:36:25 +0900
Message-Id: <1511523385-6433-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, Glauber Costa <glauber@scylladb.com>

Commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work") changed
register_shrinker() to fail when memory allocation failed.
Since that commit did not take appropriate precautions before allowing
register_shrinker() to fail, there are many register_shrinker() users
who continue running when register_shrinker() failed.
Since continuing when register_shrinker() failed can cause memory
pressure related issues (e.g. needless OOM killer invocations),
this patch marks register_shrinker() as __must_check in order to
encourage all register_shrinker() users to add error recovery path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Glauber Costa <glauber@scylladb.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/shrinker.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..a389491 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -75,6 +75,6 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
-extern int register_shrinker(struct shrinker *);
+extern __must_check int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
 #endif
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
