Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D66E66B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 04:33:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i75so18278101ioa.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:33:04 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0118.outbound.protection.outlook.com. [104.47.2.118])
        by mx.google.com with ESMTPS id g4si31010596igk.100.2016.05.10.01.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 May 2016 01:33:03 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] x86-kasan-instrument-user-memory-access-api-fix
Date: Tue, 10 May 2016 11:33:29 +0300
Message-ID: <1462869209-21096-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <20160509062921.GA2522@gmail.com>
References: <20160509062921.GA2522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, x86@kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Move kasan check under the condition, otherwise we may fail and not
do a user copy.

Reported-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 lib/strncpy_from_user.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index e3472b0..33f655e 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -104,13 +104,13 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 	if (unlikely(count <= 0))
 		return 0;
 
-	kasan_check_write(dst, count);
 	max_addr = user_addr_max();
 	src_addr = (unsigned long)src;
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
 
+		kasan_check_write(dst, count);
 		user_access_begin();
 		retval = do_strncpy_from_user(dst, src, count, max);
 		user_access_end();
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
