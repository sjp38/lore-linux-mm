Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 0585C6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 16:55:43 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm/slob: avoid type warning about alignment value
Date: Tue, 10 Jul 2012 20:55:34 +0000
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201207102055.35278.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

The types for ARCH_KMALLOC_MINALIGN and ARCH_SLAB_MINALIGN are not always
the same, as seen by building ARM collie_defconfig:

mm/slob.c: In function 'kfree':
mm/slob.c:482:153: warning: comparison of distinct pointer types lacks a cast
mm/slob.c: In function 'ksize':
mm/slob.c:501:153: warning: comparison of distinct pointer types lacks a cast

Using max_t to find the correct alignment avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
diff --git a/mm/slob.c b/mm/slob.c
index 95d1c7d..51d6a27 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -426,7 +426,7 @@ out:
 void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 {
 	unsigned int *m;
-	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
 
 	gfp &= gfp_allowed_mask;
@@ -479,7 +479,7 @@ void kfree(const void *block)
 
 	sp = virt_to_page(block);
 	if (PageSlab(sp)) {
-		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+		int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		slob_free(m, *m + align);
 	} else
@@ -498,7 +498,7 @@ size_t ksize(const void *block)
 
 	sp = virt_to_page(block);
 	if (PageSlab(sp)) {
-		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+		int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
 		return SLOB_UNITS(*m) * SLOB_UNIT;
 	} else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
