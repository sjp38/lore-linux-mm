Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE3A6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 09:29:20 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so754469eek.30
        for <linux-mm@kvack.org>; Wed, 07 May 2014 06:29:19 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id l44si8492460eem.283.2014.05.07.06.29.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 06:29:18 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: Postpone the disabling of kmemleak early logging
Date: Wed,  7 May 2014 14:28:35 +0100
Message-Id: <1399469315-29239-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Li Zefan <lizefan@huawei.com>

Commit 8910ae896c8c (kmemleak: change some global variables to int), in
addition to the atomic -> int conversion, moved the kmemleak_early_log
disabling at the beginning of the kmemleak_init() function, before the
full kmemleak tracing is actually enabled. In this small window,
kmem_cache_create() is called by kmemleak which triggers additional
memory allocation that are not traced. This patch restores the original
logic with kmemleak_early_log disabling when kmemleak is fully
functional.

Fixes: 8910ae896c8c (kmemleak: change some global variables to int)
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Li Zefan <lizefan@huawei.com>
---
 mm/kmemleak.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 61a64ed2fbef..33599ba0cd8d 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1809,10 +1809,9 @@ void __init kmemleak_init(void)
 	int i;
 	unsigned long flags;
 
-	kmemleak_early_log = 0;
-
 #ifdef CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF
 	if (!kmemleak_skip_disable) {
+		kmemleak_early_log = 0;
 		kmemleak_disable();
 		return;
 	}
@@ -1830,6 +1829,7 @@ void __init kmemleak_init(void)
 
 	/* the kernel is still in UP mode, so disabling the IRQs is enough */
 	local_irq_save(flags);
+	kmemleak_early_log = 0;
 	if (kmemleak_error) {
 		local_irq_restore(flags);
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
