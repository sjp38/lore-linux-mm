Message-Id: <20080321061726.192070985@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:12 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [09/14] vcompound: crypto: Fallback for temporary order 2 allocation
Content-Disposition: inline; filename=0012-vcompound-crypto-Fallback-for-temporary-order-2-al.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>
List-ID: <linux-mm.kvack.org>

The crypto subsystem needs an order 2 allocation. This is a temporary buffer
for xoring data so we can safely allow fallback.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 crypto/xor.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.25-rc5-mm1/crypto/xor.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/crypto/xor.c	2008-03-20 18:04:44.649120096 -0700
+++ linux-2.6.25-rc5-mm1/crypto/xor.c	2008-03-20 19:41:35.383789613 -0700
@@ -101,7 +101,7 @@ calibrate_xor_blocks(void)
 	void *b1, *b2;
 	struct xor_block_template *f, *fastest;
 
-	b1 = (void *) __get_free_pages(GFP_KERNEL, 2);
+	b1 = __alloc_vcompound(GFP_KERNEL, 2);
 	if (!b1) {
 		printk(KERN_WARNING "xor: Yikes!  No memory available.\n");
 		return -ENOMEM;
@@ -140,7 +140,7 @@ calibrate_xor_blocks(void)
 
 #undef xor_speed
 
-	free_pages((unsigned long)b1, 2);
+	__free_vcompound(b1);
 
 	active_template = fastest;
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
