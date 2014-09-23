Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id F2CA26B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:44:02 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id 29so1468716yhl.33
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 18:44:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n67si7943051yhp.61.2014.09.22.18.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 18:44:02 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: fix build breakage in dump_mm if CONFIG_MEMCG is not set
Date: Mon, 22 Sep 2014 21:43:49 -0400
Message-Id: <1411436629-12764-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

mm_struct->owner is only available if CONFIG_MEMCG is set, fix build
by taking that into account.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/debug.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 281abb2..544d8f6 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -181,7 +181,10 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_AIO
 		"ioctx_table %p\n"
 #endif
-		"owner %p exe_file %p\n"
+#ifdef CONFIG_MEMCG
+		"owner %p\n"
+#endif
+		"exe_file %p\n"
 #ifdef CONFIG_MMU_NOTIFIER
 		"mmu_notifier_mm %p\n"
 #endif
@@ -209,7 +212,10 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_AIO
 		mm->ioctx_table,
 #endif
-		mm->owner, mm->exe_file,
+#ifdef CONFIG_MEMCG
+		mm->owner,
+#endif
+		mm->exe_file,
 #ifdef CONFIG_MMU_NOTIFIER
 		mm->mmu_notifier_mm,
 #endif
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
