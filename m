Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5CEE6B02A3
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:28:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f8so12633907pgs.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:28:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor5820413plo.30.2017.12.19.05.28.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:28:57 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
Date: Tue, 19 Dec 2017 14:28:43 +0100
Message-Id: <20171219132844.28354-2-mhocko@kernel.org>
In-Reply-To: <20171219132844.28354-1-mhocko@kernel.org>
References: <20171219132844.28354-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glauber@scylladb.com>, Michal Hocko <mhocko@suse.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since allowing register_shrinker() callers to call unregister_shrinker()
when register_shrinker() failed can simplify error recovery path, this
patch makes unregister_shrinker() no-op when register_shrinker() failed.
Let's also make sure that double unregister_shrinker doesn't blow up as
well and NULL nr_deferred on successful de-registration to make the
clean up even simpler and prevent from potential memory corruptions.

[akaraliou.dev@gmail.com: set nr_deferred = NULL to handle double
 unregister]
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: syzbot <syzkaller@googlegroups.com>
Cc: Glauber Costa <glauber@scylladb.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 80dea50f421b..7a5801040fd4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -281,10 +281,13 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	if (!shrinker->nr_deferred)
+		return;
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
 	kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
