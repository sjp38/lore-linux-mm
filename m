Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 324874403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 00:57:47 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id w123so33246829pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:47 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id d26si14349870pfb.137.2016.02.03.21.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 21:57:46 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id o185so33083973pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:46 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 5/5] tile: query dynamic DEBUG_PAGEALLOC setting
Date: Thu,  4 Feb 2016 14:56:26 +0900
Message-Id: <1454565386-10489-6-git-send-email-iamjoonsoo.kim@lge.com>
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
 arch/tile/mm/init.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index d4e1fc4..a0582b7 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -896,17 +896,15 @@ void __init pgtable_cache_init(void)
 		panic("pgtable_cache_init(): Cannot create pgd cache");
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-static long __write_once initfree;
-#else
 static long __write_once initfree = 1;
-#endif
+static bool __write_once set_initfree_done;
 
 /* Select whether to free (1) or mark unusable (0) the __init pages. */
 static int __init set_initfree(char *str)
 {
 	long val;
 	if (kstrtol(str, 0, &val) == 0) {
+		set_initfree_done = true;
 		initfree = val;
 		pr_info("initfree: %s free init pages\n",
 			initfree ? "will" : "won't");
@@ -919,6 +917,11 @@ static void free_init_pages(char *what, unsigned long begin, unsigned long end)
 {
 	unsigned long addr = (unsigned long) begin;
 
+	/* Prefer user request first */
+	if (!set_initfree_done) {
+		if (debug_pagealloc_enabled())
+			initfree = 0;
+	}
 	if (kdata_huge && !initfree) {
 		pr_warn("Warning: ignoring initfree=0: incompatible with kdata=huge\n");
 		initfree = 1;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
