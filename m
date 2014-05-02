Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0726C6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:48 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id as1so5072927iec.39
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:48 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id j10si3325995igx.20.2014.05.02.06.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:48 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 6/6] mm: Postpone the disabling of kmemleak early logging
Date: Fri,  2 May 2014 14:41:10 +0100
Message-Id: <1399038070-1540-7-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Currently, kmemleak_early_log is disabled at the beginning of the
kmemleak_init() function, before the full kmemleak tracing is actually
enabled. In this small window, kmem_cache_create() is called by kmemleak
which triggers additional memory allocation that are not traced. This
patch moves the kmemleak_early_log disabling further down and at the
same time with full kmemleak enabling.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/kmemleak.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 61a64ed2fbef..0cd6aabd45a0 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1809,8 +1809,6 @@ void __init kmemleak_init(void)
 	int i;
 	unsigned long flags;
 
-	kmemleak_early_log = 0;
-
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
 		kmemleak_disable();
@@ -1833,8 +1831,9 @@ void __init kmemleak_init(void)
 	if (kmemleak_error) {
 		local_irq_restore(flags);
 		return;
-	} else
-		kmemleak_enabled = 1;
+	}
+	kmemleak_early_log = 0;
+	kmemleak_enabled = 1;
 	local_irq_restore(flags);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
