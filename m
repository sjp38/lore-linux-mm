Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C85A66B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:26:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so1689166wml.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:26:28 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id r8si2918894wjf.267.2016.08.11.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 08:26:27 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id i5so3365080wmg.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:26:27 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] kasan: remove the unnecessary WARN_ONCE from quarantine.c
Date: Thu, 11 Aug 2016 17:26:22 +0200
Message-Id: <1470929182-101413-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's quite unlikely that the user will so little memory that the
per-CPU quarantines won't fit into the given fraction of the available
memory. Even in that case he won't be able to do anything with the
information given in the warning.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/kasan/quarantine.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index b6728a3..baabaad 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -217,11 +217,8 @@ void quarantine_reduce(void)
 	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
 	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
-	if (WARN_ONCE(new_quarantine_size < percpu_quarantines,
-		"Too little memory, disabling global KASAN quarantine.\n"))
-		new_quarantine_size = 0;
-	else
-		new_quarantine_size -= percpu_quarantines;
+	new_quarantine_size = (new_quarantine_size < percpu_quarantines) ?
+		0 : new_quarantine_size - percpu_quarantines;
 	WRITE_ONCE(quarantine_size, new_quarantine_size);
 
 	last = global_quarantine.head;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
