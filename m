Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B51546B000C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:43:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t10-v6so1671999pfh.0
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:43:48 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00135.outbound.protection.outlook.com. [40.107.0.135])
        by mx.google.com with ESMTPS id f4-v6si9779955plo.226.2018.06.29.11.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jun 2018 11:43:47 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm/fadvise: Fix signed overflow UBSAN complaint
Date: Fri, 29 Jun 2018 21:44:53 +0300
Message-Id: <20180629184453.7614-1-aryabinin@virtuozzo.com>
In-Reply-To: <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
References: <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: icytxw@gmail.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Signed integer overflow is undefined according to the C standard.
The overflow in ksys_fadvise64_64() is deliberate, but since it is signed
overflow, UBSAN complains:
	UBSAN: Undefined behaviour in mm/fadvise.c:76:10
	signed integer overflow:
	4 + 9223372036854775805 cannot be represented in type 'long long int'

Use unsigned types to do math. Unsigned overflow is defined so UBSAN
will not complain about it. This patch doesn't change generated code.

Reported-by: <icytxw@gmail.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/fadvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index afa41491d324..1eaf2002d79a 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -73,7 +73,7 @@ int ksys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice)
 	}
 
 	/* Careful about overflows. Len == 0 means "as much as possible" */
-	endbyte = offset + len;
+	endbyte = (u64)offset + (u64)len;
 	if (!len || endbyte < len)
 		endbyte = -1;
 	else
-- 
2.16.4
