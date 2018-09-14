Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0758E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:05:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d10-v6so9827523wrw.6
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:05:06 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50100.outbound.protection.outlook.com. [40.107.5.100])
        by mx.google.com with ESMTPS id p2-v6si6340165wrj.355.2018.09.14.06.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 06:05:04 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/3] vfree, kvfree: Add debug might sleeps.
Date: Fri, 14 Sep 2018 16:05:12 +0300
Message-Id: <20180914130512.10394-3-aryabinin@virtuozzo.com>
In-Reply-To: <20180914130512.10394-1-aryabinin@virtuozzo.com>
References: <20180914130512.10394-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Add might_sleep() calls to vfree(), kvfree() to catch potential
sleep-in-atomic bugs earlier.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/util.c    | 2 ++
 mm/vmalloc.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index 7f1f165f46af..929ed1795bc1 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -446,6 +446,8 @@ EXPORT_SYMBOL(kvmalloc_node);
  */
 void kvfree(const void *addr)
 {
+	might_sleep_if(!in_interrupt());
+
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d00d42d6bf79..97d4b25d0373 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1587,6 +1587,8 @@ void vfree(const void *addr)
 
 	kmemleak_free(addr);
 
+	might_sleep_if(!in_interrupt());
+
 	if (!addr)
 		return;
 	if (unlikely(in_interrupt()))
-- 
2.16.4
