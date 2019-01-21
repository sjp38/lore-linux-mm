Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D59FD8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:38:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so15567090pfj.15
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:38:24 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id e69si11679964pfg.137.2019.01.21.01.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:38:23 -0800 (PST)
From: <miles.chen@mediatek.com>
Subject: [PATCH] mm/slub: use WARN_ON() for some slab errors
Date: Mon, 21 Jan 2019 17:38:10 +0800
Message-ID: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

When debugging with slub.c, sometimes we have to trigger a panic in
order to get the coredump file. To do that, we have to modify slub.c and
rebuild kernel. To make debugging easier, use WARN_ON() for these slab
errors so we can dump stack trace by default or set panic_on_warn to
trigger a panic.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/slub.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..e48c3bb30c93 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -684,7 +684,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		print_section(KERN_ERR, "Padding ", p + off,
 			      size_from_object(s) - off);
 
-	dump_stack();
+	WARN_ON(1);
 }
 
 void object_err(struct kmem_cache *s, struct page *page,
@@ -705,7 +705,7 @@ static __printf(3, 4) void slab_err(struct kmem_cache *s, struct page *page,
 	va_end(args);
 	slab_bug(s, "%s", buf);
 	print_page_info(page);
-	dump_stack();
+	WARN_ON(1);
 }
 
 static void init_object(struct kmem_cache *s, void *object, u8 val)
@@ -1690,7 +1690,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		flags &= ~GFP_SLAB_BUG_MASK;
 		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
 				invalid_mask, &invalid_mask, flags, &flags);
-		dump_stack();
+		WARN_ON(1);
 	}
 
 	return allocate_slab(s,
-- 
2.18.0
