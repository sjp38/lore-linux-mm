Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04A066B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 08:18:52 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so75344847igb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 05:18:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v11si5186614pdi.230.2015.09.08.05.18.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 05:18:51 -0700 (PDT)
Message-ID: <55EED09E.3010107@huawei.com>
Date: Tue, 8 Sep 2015 20:12:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] kasan: fix last shadow judgement in memory_is_poisoned_16()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The shadow which correspond 16 bytes memory may span 2 or 3 bytes. If the
memory is aligned on 8, then the shadow takes only 2 bytes. So we check
"shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
But the code "if (likely(!last_byte))" is wrong judgement.

e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
continue to call "memory_is_poisoned_1(addr + 15);"

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/kasan/kasan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 7b28e9c..8da2114 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -135,12 +135,11 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 
 	if (unlikely(*shadow_addr)) {
 		u16 shadow_first_bytes = *(u16 *)shadow_addr;
-		s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
 
 		if (unlikely(shadow_first_bytes))
 			return true;
 
-		if (likely(!last_byte))
+		if (likely(IS_ALIGNED(addr, 8)))
 			return false;
 
 		return memory_is_poisoned_1(addr + 15);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
