Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 77E236B0258
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:21 -0400 (EDT)
Received: by lanb10 with SMTP id b10so107779552lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:20 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id tt2si13885318lbb.13.2015.09.15.07.08.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:20 -0700 (PDT)
Received: by lahg1 with SMTP id g1so78910580lah.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:19 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 01/10] mm/msync: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:07:25 +0600
Message-Id: <1442326045-7147-1-git-send-email-kuleshovmail@gmail.com>
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
 mm/msync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/msync.c b/mm/msync.c
index bb04d53..24e612f 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -38,7 +38,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
-	if (start & ~PAGE_MASK)
+	if (offset_in_page(start))
 		goto out;
 	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
 		goto out;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
