Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 406986B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 21:47:04 -0400 (EDT)
Received: by obqa2 with SMTP id a2so72002517obq.3
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 18:47:04 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id y3si1067157oie.0.2015.09.07.18.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Sep 2015 18:47:03 -0700 (PDT)
Message-ID: <55EE3D03.8000502@huawei.com>
Date: Tue, 8 Sep 2015 09:42:27 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] kasan: fix last shadow judgement in memory_is_poisoned_16()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, adech.fo@gmail.com, rusty@rustcorp.com.au, mmarek@suse.cz
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhongjiang@huawei.com

The shadow which correspond 16 bytes may span 2 or 3 bytes. If shadow
only take 2 bytes, we can return in "if (likely(!last_byte)) ...", but
it calculates wrong, so fix it.

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
