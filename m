Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFDE36B194D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 09:28:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k44-v6so3420276wre.21
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:28:57 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80125.outbound.protection.outlook.com. [40.107.8.125])
        by mx.google.com with ESMTPS id q142-v6si8627819wmb.71.2018.08.20.06.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Aug 2018 06:28:56 -0700 (PDT)
Subject: [PATCH] mm: Check shrinker is memcg-aware in
 register_shrinker_prepared()
References: <0000000000003427e80573bcde5c@google.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <8ff8a793-8211-713a-4ed9-d6e52390c2fc@virtuozzo.com>
Date: Mon, 20 Aug 2018 16:28:45 +0300
MIME-Version: 1.0
In-Reply-To: <0000000000003427e80573bcde5c@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+d5f648a1bfe15678786b@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, hannes@cmpxchg.org, jbacik@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

There is a sad BUG introduced in patch adding SHRINKER_REGISTERING.
shrinker_idr business is only for memcg-aware shrinkers. Only
such type of shrinkers have id and they must be finaly installed
via idr_replace() in this function. For !memcg-aware shrinkers
we never initialize shrinker->id field.

But there are all types of shrinkers passed to idr_replace(),
and every !memcg-aware shrinker with random ID (most probably,
its id is 0) replaces memcg-aware shrinker pointed by the ID
in IDR.

This patch fixes the problem.
    
Reported-by: syzbot+d5f648a1bfe15678786b@syzkaller.appspotmail.com
Fixes: 7e010df53c80 "mm: use special value SHRINKER_REGISTERING instead of list_empty() check"
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4375b1e9bd56..3c6e2bfee427 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -408,7 +408,8 @@ void register_shrinker_prepared(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 #ifdef CONFIG_MEMCG_KMEM
-	idr_replace(&shrinker_idr, shrinker, shrinker->id);
+	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
+		idr_replace(&shrinker_idr, shrinker, shrinker->id);
 #endif
 	up_write(&shrinker_rwsem);
 }
