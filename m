Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCFFB6B025E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:47:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e190so208037271pfe.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 22:47:12 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id p123si14400181pfb.235.2016.04.28.22.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 22:47:12 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id r187so13282999pfr.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 22:47:11 -0700 (PDT)
From: Minfei Huang <mnghuan@gmail.com>
Subject: [PATCH] Use existing helper to convert "on/off" to boolean
Date: Fri, 29 Apr 2016 13:47:04 +0800
Message-Id: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, alexander.h.duyck@redhat.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minfei Huang <mnghuan@gmail.com>

It's more convenient to use existing function helper to convert string
"on/off" to boolean.

Signed-off-by: Minfei Huang <mnghuan@gmail.com>
---
 lib/kstrtox.c    | 2 +-
 mm/page_alloc.c  | 9 +--------
 mm/page_poison.c | 8 +-------
 3 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/lib/kstrtox.c b/lib/kstrtox.c
index d8a5cf6..3c66fc4 100644
--- a/lib/kstrtox.c
+++ b/lib/kstrtox.c
@@ -326,7 +326,7 @@ EXPORT_SYMBOL(kstrtos8);
  * @s: input string
  * @res: result
  *
- * This routine returns 0 iff the first character is one of 'Yy1Nn0', or
+ * This routine returns 0 if the first character is one of 'Yy1Nn0', or
  * [oO][NnFf] for "on" and "off". Otherwise it will return -EINVAL.  Value
  * pointed to by res is updated upon finding a match.
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d..d31426d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -513,14 +513,7 @@ static int __init early_debug_pagealloc(char *buf)
 {
 	if (!buf)
 		return -EINVAL;
-
-	if (strcmp(buf, "on") == 0)
-		_debug_pagealloc_enabled = true;
-
-	if (strcmp(buf, "off") == 0)
-		_debug_pagealloc_enabled = false;
-
-	return 0;
+	return kstrtobool(buf, &_debug_pagealloc_enabled);
 }
 early_param("debug_pagealloc", early_debug_pagealloc);
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index 479e7ea..1eae5fa 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -13,13 +13,7 @@ static int early_page_poison_param(char *buf)
 {
 	if (!buf)
 		return -EINVAL;
-
-	if (strcmp(buf, "on") == 0)
-		want_page_poisoning = true;
-	else if (strcmp(buf, "off") == 0)
-		want_page_poisoning = false;
-
-	return 0;
+	return strtobool(buf, &want_page_poisoning);
 }
 early_param("page_poison", early_page_poison_param);
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
