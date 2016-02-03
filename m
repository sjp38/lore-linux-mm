Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 23FC36B025A
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 03:39:52 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l66so58810089wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:39:52 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id h84si7430933wmf.124.2016.02.03.00.39.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 00:39:46 -0800 (PST)
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 3 Feb 2016 08:39:45 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id BC4CB1B0805F
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:39:48 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u138dcQB8651114
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 08:39:38 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u138dbmb001788
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 03:39:37 -0500
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v4 4/4] x86: also use debug_pagealloc_enabled() for free_init_pages
Date: Wed,  3 Feb 2016 09:39:30 +0100
Message-Id: <1454488775-108777-5-git-send-email-borntraeger@de.ibm.com>
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
