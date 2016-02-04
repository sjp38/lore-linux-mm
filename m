Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9F74403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 00:57:35 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so33125097pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:35 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id lu9si14279029pab.215.2016.02.03.21.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 21:57:34 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id n128so32834608pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:34 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/5] mm/slub: query dynamic DEBUG_PAGEALLOC setting
Date: Thu,  4 Feb 2016 14:56:23 +0900
Message-Id: <1454565386-10489-3-git-send-email-iamjoonsoo.kim@lge.com>
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
 mm/slub.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7d4da68..7b5a965 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -256,11 +256,12 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
 {
 	void *p;
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
-#else
-	p = get_freepointer(s, object);
-#endif
+	if (debug_pagealloc_enabled()) {
+		probe_kernel_read(&p,
+			(void **)(object + s->offset), sizeof(p));
+	} else
+		p = get_freepointer(s, object);
+
 	return p;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
