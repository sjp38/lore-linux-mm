Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F00E6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:47:17 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so45037332lbb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:47:17 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id k135si2301526wmg.61.2016.06.22.10.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 10:47:16 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id f126so97185839wma.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:47:16 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] mm: prevent KASAN false positives in kmemleak
Date: Wed, 22 Jun 2016 19:47:11 +0200
Message-Id: <1466617631-68387-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com, kasan-dev@googlegroups.com, glider@google.com, Dmitry Vyukov <dvyukov@google.com>

When kmemleak dumps contents of leaked objects it reads whole
objects regardless of user-requested size. This upsets KASAN.
Disable KASAN checks around object dump.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---
 mm/kmemleak.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e642992..04320d3 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -307,8 +307,10 @@ static void hex_dump_object(struct seq_file *seq,
 	len = min_t(size_t, object->size, HEX_MAX_LINES * HEX_ROW_SIZE);
 
 	seq_printf(seq, "  hex dump (first %zu bytes):\n", len);
+	kasan_disable_current();
 	seq_hex_dump(seq, "    ", DUMP_PREFIX_NONE, HEX_ROW_SIZE,
 		     HEX_GROUP_SIZE, ptr, len, HEX_ASCII);
+	kasan_enable_current();
 }
 
 /*
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
