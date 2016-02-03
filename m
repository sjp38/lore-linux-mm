Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9539D6B0256
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 03:39:44 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l66so152314192wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:39:44 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id uj7si8485583wjc.0.2016.02.03.00.39.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 00:39:43 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 3 Feb 2016 08:39:43 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 23599219005C
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:39:28 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u138dfdx10027380
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 08:39:41 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u138degi010975
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 01:39:41 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v4 4/4] x86: also use debug_pagealloc_enabled() for free_init_pages
Date: Wed,  3 Feb 2016 09:39:35 +0100
Message-Id: <1454488775-108777-10-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>

we want to couple all debugging features with debug_pagealloc_enabled()
and not with the config option CONFIG_DEBUG_PAGEALLOC.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 arch/x86/mm/init.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 39823fd..9d56f27 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -667,21 +667,22 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	 * mark them not present - any buggy init-section access will
 	 * create a kernel page fault:
 	 */
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	printk(KERN_INFO "debug: unmapping init [mem %#010lx-%#010lx]\n",
-		begin, end - 1);
-	set_memory_np(begin, (end - begin) >> PAGE_SHIFT);
-#else
-	/*
-	 * We just marked the kernel text read only above, now that
-	 * we are going to free part of that, we need to make that
-	 * writeable and non-executable first.
-	 */
-	set_memory_nx(begin, (end - begin) >> PAGE_SHIFT);
-	set_memory_rw(begin, (end - begin) >> PAGE_SHIFT);
+	if (debug_pagealloc_enabled()) {
+		pr_info("debug: unmapping init [mem %#010lx-%#010lx]\n",
+			begin, end - 1);
+		set_memory_np(begin, (end - begin) >> PAGE_SHIFT);
+	} else {
+		/*
+		 * We just marked the kernel text read only above, now that
+		 * we are going to free part of that, we need to make that
+		 * writeable and non-executable first.
+		 */
+		set_memory_nx(begin, (end - begin) >> PAGE_SHIFT);
+		set_memory_rw(begin, (end - begin) >> PAGE_SHIFT);
 
-	free_reserved_area((void *)begin, (void *)end, POISON_FREE_INITMEM, what);
-#endif
+		free_reserved_area((void *)begin, (void *)end,
+				   POISON_FREE_INITMEM, what);
+	}
 }
 
 void free_initmem(void)
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
