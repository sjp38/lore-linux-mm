Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8937D6B0460
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 21:20:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so186862106pgc.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 18:20:14 -0800 (PST)
Received: from smtpproxy19.qq.com (smtpproxy19.qq.com. [184.105.206.84])
        by mx.google.com with ESMTPS id t69si4720710pgd.166.2017.03.10.18.20.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 18:20:13 -0800 (PST)
From: Yisheng Xie <ysxie@foxmail.com>
Subject: [PATCH RFC] mm/vmscan: donot retry shrink zones when memcg is disabled
Date: Sat, 11 Mar 2017 10:19:58 +0800
Message-Id: <1489198798-6632-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

When we enter do_try_to_free_pages, the may_thrash is always clear, and
it will retry shrink zones to tap cgroup's reserves memory by setting
may_thrash when the former shrink_zones reclaim nothing.

However, if CONFIG_MEMCG=n, it should not do this useless retry at all,
for we do not have any cgroup's reserves memory to tap, and we have
already done hard work and made no progress.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031e..b03ccc1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2808,7 +2808,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		return 1;
 
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
-	if (!sc->may_thrash) {
+	if (!sc->may_thrash && IS_ENABLED(CONFIG_MEMCG)) {
 		sc->priority = initial_priority;
 		sc->may_thrash = 1;
 		goto retry;
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
