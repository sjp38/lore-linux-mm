Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k6C4VdjZ007542
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 21:31:40 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k6C25v8s21212434
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 19:05:57 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k6C25vnB44652318
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 19:05:57 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1G0U6v-0004Zl-00
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 19:05:57 -0700
Date: Tue, 11 Jul 2006 18:56:22 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Cleanup gfp.h : Remove __GFP_DMA32 ifdef
Message-ID: <Pine.LNX.4.64.0607111855230.17525@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0607111905490.17592@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

The __GFP_xx definitions in include/linux/gfp.h are used to refer to
individual bits in the GFP bitmasks. I think they should not be conditional
via ifdef. If a conditional definition is required then a version without
the underscore should be used.

My patch from yesterday cleared up the definitions that resulted in zero
values. This one removes the #ifdef around __GFP_DMA32.

The x86_64 arch code is the only user of __GFP_DMA32 and x86_64 sets
CONFIG_ZONE_DMA32. No driver is using DMA32. So we do not really need fall
back behavior for ZONE_DMA32 at this point.

If ZONE_DMA32 would be used by a device driver in the future on a platform
that has not set CONFIG_ZONE_DMA32 then we will fall back to ZONE_NORMAL
because the __GFP_DMA32 bit is not set in GFP_ZONEMASK. I think if different
behavior is desired then the device driver would have to take care of falling
back to a different allocation. The absence of DMA32 slab support may already
force the device driver to deal with this case anyways.

Another solution would be to make the definition of GFP_DMA32 conditional
on CONFIG_ZONE_DMA32 and 32/64 bit. That would leave the __GFP_xx untouched.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc1-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc1-mm1.orig/include/linux/gfp.h	2006-07-11 11:46:05.574969363 -0700
+++ linux-2.6.18-rc1-mm1/include/linux/gfp.h	2006-07-11 18:28:48.376427095 -0700
@@ -9,16 +9,19 @@ struct vm_area_struct;
 
 /*
  * GFP bitmasks..
+ *
+ * Zone modifiers (see linux/mmzone.h - low three bits)
+ *
+ * These may be masked by GFP_ZONEMASK to make allocations with this bit
+ * set fall back to ZONE_NORMAL.
+ *
+ * Do not put any conditional on these. If necessary modify the definitions
+ * without the underscores and use the consistently. The definitions here may
+ * be used in bit comparisons.
  */
-/* Zone modifiers in GFP_ZONEMASK (see linux/mmzone.h - low three bits) */
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
-
-#if !defined(CONFIG_ZONE_DMA32) && BITS_PER_LONG >= 64
-#define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32 */
-#else
-#define __GFP_DMA32	((__force gfp_t)0x04)	/* Has own ZONE_DMA32 */
-#endif
+#define __GFP_DMA32	((__force gfp_t)0x04u)
 
 /*
  * Action modifiers - doesn't change the zoning

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
