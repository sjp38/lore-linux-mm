Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BD216828E1
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 23:05:24 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id x65so22821805pfb.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 20:05:24 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id fm8si9628210pad.29.2016.02.10.20.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 20:05:24 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id yy13so1842930pab.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 20:05:23 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 3/5] sound: query dynamic DEBUG_PAGEALLOC setting
Date: Thu, 11 Feb 2016 13:04:59 +0900
Message-Id: <1455163501-9341-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1455163501-9341-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1455163501-9341-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can disable debug_pagealloc processing even if the code is compiled
with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
whether it is enabled or not in runtime.

v2: export _debug_pagealloc_enabled to modules, per Andrew.

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Takashi Iwai <tiwai@suse.de>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c           | 1 +
 sound/drivers/pcsp/pcsp.c | 9 +++++----
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 87b3e2f..00118fe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -498,6 +498,7 @@ void prep_compound_page(struct page *page, unsigned int order)
 unsigned int _debug_guardpage_minorder;
 bool _debug_pagealloc_enabled __read_mostly
 			= IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
+EXPORT_SYMBOL(_debug_pagealloc_enabled);
 bool _debug_guardpage_enabled __read_mostly;
 
 static int __init early_debug_pagealloc(char *buf)
diff --git a/sound/drivers/pcsp/pcsp.c b/sound/drivers/pcsp/pcsp.c
index 27e25bb..72e2d00 100644
--- a/sound/drivers/pcsp/pcsp.c
+++ b/sound/drivers/pcsp/pcsp.c
@@ -14,6 +14,7 @@
 #include <linux/input.h>
 #include <linux/delay.h>
 #include <linux/bitops.h>
+#include <linux/mm.h>
 #include "pcsp_input.h"
 #include "pcsp.h"
 
@@ -148,11 +149,11 @@ static int alsa_card_pcsp_init(struct device *dev)
 		return err;
 	}
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
 	/* Well, CONFIG_DEBUG_PAGEALLOC makes the sound horrible. Lets alert */
-	printk(KERN_WARNING "PCSP: CONFIG_DEBUG_PAGEALLOC is enabled, "
-	       "which may make the sound noisy.\n");
-#endif
+	if (debug_pagealloc_enabled()) {
+		printk(KERN_WARNING "PCSP: CONFIG_DEBUG_PAGEALLOC is enabled, "
+		       "which may make the sound noisy.\n");
+	}
 
 	return 0;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
