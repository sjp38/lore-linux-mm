Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4AE6B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 22:07:45 -0400 (EDT)
Received: by lanb10 with SMTP id b10so39002657lan.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 19:07:44 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l9si12240344laf.101.2015.09.10.19.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 19:07:44 -0700 (PDT)
Message-ID: <55F23635.1010109@huawei.com>
Date: Fri, 11 Sep 2015 10:02:29 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] kasan: use IS_ALIGNED in memory_is_poisoned_8()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Use IS_ALIGNED() to determine whether the shadow span two bytes.
It generates less code and more readable.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 7b28e9c..c6ddff1 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -120,7 +120,7 @@ static __always_inline bool memory_is_poisoned_8(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 7))
 			return true;
 
-		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
+		if (likely(IS_ALIGNED(addr, 8)))
 			return false;
 
 		return unlikely(*(u8 *)shadow_addr);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
