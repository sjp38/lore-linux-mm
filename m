Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3D06B007E
	for <linux-mm@kvack.org>; Sat, 18 Sep 2010 12:00:45 -0400 (EDT)
Message-Id: <20100918155652.623204840@chello.nl>
Date: Sat, 18 Sep 2010 17:53:27 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/5] mm: strictly nested kmap_atomic
References: <20100918155326.478277313@chello.nl>
Content-Disposition: inline; filename=kmap-2.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Ensure kmap_atomic usage is strictly nested

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
---
 crypto/async_tx/async_memcpy.c |    2 +-
 crypto/blkcipher.c             |    2 +-
 drivers/block/loop.c           |    4 ++--
 include/linux/highmem.h        |    4 ++--
 kernel/power/snapshot.c        |    4 ++--
 5 files changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6/crypto/async_tx/async_memcpy.c
===================================================================
--- linux-2.6.orig/crypto/async_tx/async_memcpy.c
+++ linux-2.6/crypto/async_tx/async_memcpy.c
@@ -83,8 +83,8 @@ async_memcpy(struct page *dest, struct p
 
 		memcpy(dest_buf, src_buf, len);
 
-		kunmap_atomic(dest_buf, KM_USER0);
 		kunmap_atomic(src_buf, KM_USER1);
+		kunmap_atomic(dest_buf, KM_USER0);
 
 		async_tx_sync_epilog(submit);
 	}
Index: linux-2.6/crypto/blkcipher.c
===================================================================
--- linux-2.6.orig/crypto/blkcipher.c
+++ linux-2.6/crypto/blkcipher.c
@@ -89,9 +89,9 @@ static inline unsigned int blkcipher_don
 		memcpy(walk->dst.virt.addr, walk->page, n);
 		blkcipher_unmap_dst(walk);
 	} else if (!(walk->flags & BLKCIPHER_WALK_PHYS)) {
-		blkcipher_unmap_src(walk);
 		if (walk->flags & BLKCIPHER_WALK_DIFF)
 			blkcipher_unmap_dst(walk);
+		blkcipher_unmap_src(walk);
 	}
 
 	scatterwalk_advance(&walk->in, n);
Index: linux-2.6/drivers/block/loop.c
===================================================================
--- linux-2.6.orig/drivers/block/loop.c
+++ linux-2.6/drivers/block/loop.c
@@ -99,8 +99,8 @@ static int transfer_none(struct loop_dev
 	else
 		memcpy(raw_buf, loop_buf, size);
 
-	kunmap_atomic(raw_buf, KM_USER0);
 	kunmap_atomic(loop_buf, KM_USER1);
+	kunmap_atomic(raw_buf, KM_USER0);
 	cond_resched();
 	return 0;
 }
@@ -128,8 +128,8 @@ static int transfer_xor(struct loop_devi
 	for (i = 0; i < size; i++)
 		*out++ = *in++ ^ key[(i & 511) % keysize];
 
-	kunmap_atomic(raw_buf, KM_USER0);
 	kunmap_atomic(loop_buf, KM_USER1);
+	kunmap_atomic(raw_buf, KM_USER0);
 	cond_resched();
 	return 0;
 }
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -191,8 +191,8 @@ static inline void copy_user_highpage(st
 	vfrom = kmap_atomic(from, KM_USER0);
 	vto = kmap_atomic(to, KM_USER1);
 	copy_user_page(vto, vfrom, vaddr, to);
-	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
+	kunmap_atomic(vfrom, KM_USER0);
 }
 
 #endif
@@ -204,8 +204,8 @@ static inline void copy_highpage(struct 
 	vfrom = kmap_atomic(from, KM_USER0);
 	vto = kmap_atomic(to, KM_USER1);
 	copy_page(vto, vfrom);
-	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
+	kunmap_atomic(vfrom, KM_USER0);
 }
 
 #endif /* _LINUX_HIGHMEM_H */
Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -978,8 +978,8 @@ static void copy_data_page(unsigned long
 		src = kmap_atomic(s_page, KM_USER0);
 		dst = kmap_atomic(d_page, KM_USER1);
 		do_copy_page(dst, src);
-		kunmap_atomic(src, KM_USER0);
 		kunmap_atomic(dst, KM_USER1);
+		kunmap_atomic(src, KM_USER0);
 	} else {
 		if (PageHighMem(d_page)) {
 			/* Page pointed to by src may contain some kernel
@@ -2253,8 +2253,8 @@ swap_two_pages_data(struct page *p1, str
 	memcpy(buf, kaddr1, PAGE_SIZE);
 	memcpy(kaddr1, kaddr2, PAGE_SIZE);
 	memcpy(kaddr2, buf, PAGE_SIZE);
-	kunmap_atomic(kaddr1, KM_USER0);
 	kunmap_atomic(kaddr2, KM_USER1);
+	kunmap_atomic(kaddr1, KM_USER0);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
