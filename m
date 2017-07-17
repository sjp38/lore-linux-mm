Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 930606B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:45:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d80so35009416lfg.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:45:21 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id e23si7582822ljb.164.2017.07.17.09.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 09:45:20 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id t72so13643176lff.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:45:19 -0700 (PDT)
From: Alexander Popov <alex.popov@linux.com>
Subject: [PATCH 1/1] mm/slub.c: add a naive detection of double free or corruption
Date: Mon, 17 Jul 2017 19:45:07 +0300
Message-Id: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org, alex.popov@linux.com

Add an assertion similar to "fasttop" check in GNU C Library allocator:
an object added to a singly linked freelist should not point to itself.
That helps to detect some double free errors (e.g. CVE-2017-2636) without
slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
performance penalty.

Signed-off-by: Alexander Popov <alex.popov@linux.com>
---
 mm/slub.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slub.c b/mm/slub.c
index 1d3f983..a106939b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -261,6 +261,7 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
 
 static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
+	BUG_ON(object == fp); /* naive detection of double free or corruption */
 	*(void **)(object + s->offset) = fp;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
