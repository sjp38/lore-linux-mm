Date: Tue, 27 May 2008 01:49:47 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
Subject: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of
	__GFP_NORETRY
Message-ID: <20080526234940.GA1376@xs4all.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Glauber Costa <gcosta@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Please consider the below patch for 2.6.26 (can somebody from the
x86 team pick this up please? Thank you)



[PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of __GFP_NORETRY

arch/x86/kernel/pci-dma.c::dma_alloc_coherent() adds __GFP_NORETRY to
the gfp flags before calling alloc_pages() to prevent the oom killer
from running.

This has the expected side effect that that alloc_pages() doesn't
retry anymore. Not really a problem for dma_alloc_coherent(.. GFP_ATOMIC)
which is the way most drivers use it (through pci_alloc_consistent())
but drivers that call dma_alloc_coherent(.. GFP_KERNEL) directly can get
unexpected failures.

Until we have the mask allocator, use a new flag __GFP_NO_OOM
instead of __GFP_NORETRY.

Signed-off-by: Miquel van Smoorenburg <miquels@cistron.nl>

diff -ruN linux-2.6.26-rc3.orig/arch/x86/kernel/pci-dma.c linux-2.6.26-rc3/arch/x86/kernel/pci-dma.c
--- linux-2.6.26-rc3.orig/arch/x86/kernel/pci-dma.c	2008-05-18 23:36:41.000000000 +0200
+++ linux-2.6.26-rc3/arch/x86/kernel/pci-dma.c	2008-05-22 20:42:10.000000000 +0200
@@ -398,7 +398,7 @@
 		return NULL;
 
 	/* Don't invoke OOM killer */
-	gfp |= __GFP_NORETRY;
+	gfp |= __GFP_NO_OOM;
 
 #ifdef CONFIG_X86_64
 	/* Why <=? Even when the mask is smaller than 4GB it is often
diff -ruN linux-2.6.26-rc3.orig/include/linux/gfp.h linux-2.6.26-rc3/include/linux/gfp.h
--- linux-2.6.26-rc3.orig/include/linux/gfp.h	2008-05-18 23:36:41.000000000 +0200
+++ linux-2.6.26-rc3/include/linux/gfp.h	2008-05-22 21:17:36.000000000 +0200
@@ -43,6 +43,7 @@
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
+#define __GFP_NO_OOM	((__force gfp_t)0x2000u)/* Don't invoke oomkiller */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
diff -ruN linux-2.6.26-rc3.orig/mm/page_alloc.c linux-2.6.26-rc3/mm/page_alloc.c
--- linux-2.6.26-rc3.orig/mm/page_alloc.c	2008-05-18 23:36:41.000000000 +0200
+++ linux-2.6.26-rc3/mm/page_alloc.c	2008-05-22 17:39:12.000000000 +0200
@@ -1583,7 +1583,8 @@
 					zonelist, high_zoneidx, alloc_flags);
 		if (page)
 			goto got_pg;
-	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
+	} else if ((gfp_mask & __GFP_FS) &&
+			!(gfp_mask & (__GFP_NORETRY|__GFP_NO_OOM))) {
 		if (!try_set_zone_oom(zonelist, gfp_mask)) {
 			schedule_timeout_uninterruptible(1);
 			goto restart;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
