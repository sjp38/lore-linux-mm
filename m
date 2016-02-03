Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B0BA16B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 04:57:26 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so11005707pab.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:57:26 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id m65si8266488pfi.251.2016.02.03.01.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 01:57:26 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id pv5so743090pac.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:57:25 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] mm/workingset: do not forget to unlock page
Date: Wed,  3 Feb 2016 18:58:33 +0900
Message-Id: <1454493513-19316-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Do not leave page locked (and RCU read side locked) when
return from workingset_activation() due to disabled memcg
or page not being a page_memcg().

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/workingset.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 14522ed..54138a9 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -315,8 +315,10 @@ void workingset_activation(struct page *page)
 	 * XXX: See workingset_refault() - this should return
 	 * root_mem_cgroup even for !CONFIG_MEMCG.
 	 */
-	if (!mem_cgroup_disabled() && !page_memcg(page))
+	if (!mem_cgroup_disabled() && !page_memcg(page)) {
+		unlock_page_memcg(page);
 		return;
+	}
 	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
 	atomic_long_inc(&lruvec->inactive_age);
 	unlock_page_memcg(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
