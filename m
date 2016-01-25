Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 24FC16B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 04:19:29 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n5so69122460wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 01:19:29 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id a65si23187527wmh.50.2016.01.25.01.19.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 01:19:28 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 25 Jan 2016 09:19:27 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0D9A417D8062
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:19:32 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0P9JOSW33816686
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:19:24 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0P9JNvA014166
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:19:24 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] mm/debug_pagealloc: Ask users for default setting of debug_pagealloc
Date: Mon, 25 Jan 2016 10:19:48 +0100
Message-Id: <1453713588-119602-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, heiko.carstens@de.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

since commit 031bc5743f158 ("mm/debug-pagealloc: make debug-pagealloc
boottime configurable") CONFIG_DEBUG_PAGEALLOC is by default a no-op.

This resulted in several unnoticed bugs, e.g.

https://lkml.kernel.org/g/<569F5E29.3090107@de.ibm.com>
or
https://lkml.kernel.org/g/<56A20F30.4050705@de.ibm.com>

as this behaviour change was not even documented in Kconfig.

Let's provide a new Kconfig symbol that allows to change the default
back to enabled, e.g. for debug kernels. This also makes the change
obvious to kernel packagers.

Let's also change the Kconfig description for CONFIG_DEBUG_PAGEALLOC,
to indicate that it is ok to enable this by default.

Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 mm/Kconfig.debug | 17 +++++++++++++++++
 mm/page_alloc.c  |  6 +++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 957d3da..4cf1212 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -26,5 +26,22 @@ config DEBUG_PAGEALLOC
 	  that would result in incorrect warnings of memory corruption after
 	  a resume because free pages are not saved to the suspend image.
 
+	  By default this option will be almost for free and can be activated
+	  in distribution kernels. The overhead and the debugging can be enabled
+	  by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc command line
+	  parameter.
+
+	  If unsure say yes.
+
+config DEBUG_PAGEALLOC_ENABLE_DEFAULT
+	bool "Enable debug page memory allocations by default?"
+        default off
+        depends on DEBUG_PAGEALLOC
+        ---help---
+	  Enable debug page memory allocations by default? This value
+	  can be overridden by debug_pagealloc=off|on.
+
+	  If unsure say no.
+
 config PAGE_POISONING
 	bool
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df..933def7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -479,7 +479,8 @@ void prep_compound_page(struct page *page, unsigned int order)
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 unsigned int _debug_guardpage_minorder;
-bool _debug_pagealloc_enabled __read_mostly;
+bool _debug_pagealloc_enabled __read_mostly
+			= IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
 bool _debug_guardpage_enabled __read_mostly;
 
 static int __init early_debug_pagealloc(char *buf)
@@ -490,6 +491,9 @@ static int __init early_debug_pagealloc(char *buf)
 	if (strcmp(buf, "on") == 0)
 		_debug_pagealloc_enabled = true;
 
+	if (strcmp(buf, "off") == 0)
+		_debug_pagealloc_enabled = false;
+
 	return 0;
 }
 early_param("debug_pagealloc", early_debug_pagealloc);
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
