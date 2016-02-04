Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 582604403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 00:57:39 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so33127012pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:39 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id e71si14384740pfd.76.2016.02.03.21.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 21:57:38 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id w123so33242942pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:38 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/5] sound: query dynamic DEBUG_PAGEALLOC setting
Date: Thu,  4 Feb 2016 14:56:24 +0900
Message-Id: <1454565386-10489-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can disable debug_pagealloc processing even if the code is complied
with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
whether it is enabled or not in runtime.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 sound/drivers/pcsp/pcsp.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

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
