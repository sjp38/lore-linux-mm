Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 477926B006C
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 22:10:43 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so76435229pab.12
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:10:43 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id he8si21901532pac.236.2015.02.01.19.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 19:10:42 -0800 (PST)
From: green@linuxhacker.ru
Subject: [PATCH 1/2] mm: Export __vmalloc_node
Date: Sun,  1 Feb 2015 22:10:26 -0500
Message-Id: <1422846627-26890-2-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1422846627-26890-1-git-send-email-green@linuxhacker.ru>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

vzalloc_node helpfully suggests to use __vmalloc_node if a more tight
control over allocation flags is needed, but in fact __vmalloc_node
is not only not exported, it's also static, so could not be used
outside of mm/vmalloc.c
Make it to be available as it was apparently intended.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 include/linux/vmalloc.h |  3 +++
 mm/vmalloc.c            | 10 ++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index b87696f..7eb2c46 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -73,6 +73,9 @@ extern void *vmalloc_exec(unsigned long size);
 extern void *vmalloc_32(unsigned long size);
 extern void *vmalloc_32_user(unsigned long size);
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
+extern void *__vmalloc_node(unsigned long size, unsigned long align,
+			    gfp_t gfp_mask, pgprot_t prot, int node,
+			    const void *caller);
 extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, int node, const void *caller);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 39c3388..b882d95 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1552,9 +1552,6 @@ void *vmap(struct page **pages, unsigned int count,
 }
 EXPORT_SYMBOL(vmap);
 
-static void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, const void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
@@ -1685,13 +1682,14 @@ fail:
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
  */
-static void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, const void *caller)
+void *__vmalloc_node(unsigned long size, unsigned long align,
+		     gfp_t gfp_mask, pgprot_t prot, int node,
+		     const void *caller)
 {
 	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
 				gfp_mask, prot, node, caller);
 }
+EXPORT_SYMBOL(__vmalloc_node);
 
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
