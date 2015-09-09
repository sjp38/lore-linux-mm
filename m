Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBF36B0257
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 00:09:06 -0400 (EDT)
Received: by ykei199 with SMTP id i199so151656194yke.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 21:09:05 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y64si3706638ykc.120.2015.09.08.21.08.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 21:09:04 -0700 (PDT)
From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH 2/2] kasan: Fix a type conversion error
Date: Wed, 9 Sep 2015 03:59:40 +0000
Message-ID: <1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
In-Reply-To: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ryabinin.a.a@gmail.com, adech.fo@gmail.com
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au, long.wanglong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

The current KASAN code can find the following out-of-bounds
bugs:
	char *ptr;
	ptr = kmalloc(8, GFP_KERNEL);
	memset(ptr+7, 0, 2);

the cause of the problem is the type conversion error in
*memory_is_poisoned_n* function. So this patch fix that.

Signed-off-by: Wang Long <long.wanglong@huawei.com>
---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 7b28e9c..5d65d06 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -204,7 +204,7 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 		s8 *last_shadow = (s8 *)kasan_mem_to_shadow((void *)last_byte);
 
 		if (unlikely(ret != (unsigned long)last_shadow ||
-			((last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
+			((long)(last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
 			return true;
 	}
 	return false;
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
