Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 70AA26B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 08:36:47 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id x13so7517653qcv.5
        for <linux-mm@kvack.org>; Mon, 12 May 2014 05:36:47 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0187.outbound.protection.outlook.com. [207.46.163.187])
        by mx.google.com with ESMTPS id t1si5943641qga.172.2014.05.12.05.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 May 2014 05:36:46 -0700 (PDT)
From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] mm: slub: Place count_partial() outside CONFIG_SLUB_DEBUG if block
Date: Mon, 12 May 2014 09:36:30 -0300
Message-ID: <1399898190-18376-1-git-send-email-fabio.estevam@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, festevam@gmail.com, Fabio Estevam <fabio.estevam@freescale.com>, Christoph Lameter <cl@linux.com>, David
 Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

Commit f7f15520731 (mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled-fix)
caused the following build error when CONFIG_SLUB_DEBUG=n:

mm/slub.c:4361:5: error: implicit declaration of function 'count_partial' [-Werror=implicit-function-declaration

Place count_partial() outside CONFIG_SLUB_DEBUG if block, as it is also used
when CONFIG_SLUB_DEBUG=n.

Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 mm/slub.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4d5002f..0a642a4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2127,12 +2127,6 @@ static inline int node_match(struct page *page, int node)
 	return 1;
 }
 
-#ifdef CONFIG_SLUB_DEBUG
-static int count_free(struct page *page)
-{
-	return page->objects - page->inuse;
-}
-
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -2147,6 +2141,12 @@ static unsigned long count_partial(struct kmem_cache_node *n,
 	return x;
 }
 
+#ifdef CONFIG_SLUB_DEBUG
+static int count_free(struct page *page)
+{
+	return page->objects - page->inuse;
+}
+
 static inline unsigned long node_nr_objs(struct kmem_cache_node *n)
 {
 	return atomic_long_read(&n->total_objects);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
