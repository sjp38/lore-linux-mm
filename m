Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B208A6B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 15:11:33 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id 128so91021wmz.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:11:33 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id c2si51128437wjb.214.2016.02.09.12.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 12:11:32 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id g62so38798476wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:11:32 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 5/5] mm/backing-dev.c: fix error path in wb_init()
Date: Tue,  9 Feb 2016 21:11:16 +0100
Message-Id: <1455048677-19882-6-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "David S. Miller" <davem@davemloft.net>, Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

We need to use post-decrement to get percpu_counter_destroy() called
on &wb->stat[0]. Moreover, the pre-decremebt would cause infinite
out-of-bounds accesses if the setup code failed at i==0.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index cc5d29d2da9b..723f3e624b9a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -328,7 +328,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
 	return 0;
 
 out_destroy_stat:
-	while (--i)
+	while (i--)
 		percpu_counter_destroy(&wb->stat[i]);
 	fprop_local_destroy_percpu(&wb->completions);
 out_put_cong:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
