Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id D79CA6B025A
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:37 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so13625426lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:37 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id ku10si13877242lac.18.2015.09.15.07.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:36 -0700 (PDT)
Received: by lahg1 with SMTP id g1so78916459lah.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:36 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 03/10] mm/mincore: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:07:40 +0600
Message-Id: <1442326060-7261-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/mincore.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index be25efd..a011355 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -234,8 +234,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 
 	/* This also avoids any overflows on PAGE_CACHE_ALIGN */
 	pages = len >> PAGE_SHIFT;
-	pages += (len & ~PAGE_MASK) != 0;
+	pages += (offset_in_page(len)) != 0;
 
 	if (!access_ok(VERIFY_WRITE, vec, pages))
 		return -EFAULT;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
