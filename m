Message-Id: <20080430044320.758185153@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:59 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [08/11] crypto: Use virtualizable compounds for temporary order 2 allocation
Content-Disposition: inline; filename=vcp_crypto_fallback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>
List-ID: <linux-mm.kvack.org>

The crypto subsystem needs an order 2 allocation. This is a temporary buffer
for xoring data so we can safely allow the use of a virtualizable compound.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 crypto/xor.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.25-rc8-mm1/crypto/xor.c
===================================================================
--- linux-2.6.25-rc8-mm1.orig/crypto/xor.c	2008-04-01 12:44:26.000000000 -0700
+++ linux-2.6.25-rc8-mm1/crypto/xor.c	2008-04-02 20:53:25.634569955 -0700
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
