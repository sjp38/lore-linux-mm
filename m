Date: Mon, 14 Apr 2008 11:40:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: sparc64: Fix NR_PAGEFLAGS check V2
Message-ID: <Pine.LNX.4.64.0804141139270.7130@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Update checks to make sure that we can place the cpu number in the
upper portion of the page flags.

Its okay if we use less than 32 page flags. There can only be a problem if
the page flags grow beyond 32 bits to reach into the area reserved for the
cpu number.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/sparc64/mm/init.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.25-rc8-mm2/arch/sparc64/mm/init.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/arch/sparc64/mm/init.c	2008-04-11 19:21:24.000000000 -0700
+++ linux-2.6.25-rc8-mm2/arch/sparc64/mm/init.c	2008-04-11 19:26:00.000000000 -0700
@@ -1300,10 +1300,21 @@
 	 * functions like clear_dcache_dirty_cpu use the cpu mask
 	 * in 13-bit signed-immediate instruction fields.
 	 */
-	BUILD_BUG_ON(BITS_PER_LONG - NR_PAGEFLAGS != 32);
+
+	/*
+	 * Page flags must not reach into upper 32 bits that are used
+	 * for the cpu number
+	 */
+	BUILD_BUG_ON(NR_PAGEFLAGS > 32);
+
+	/*
+	 * The bit fields placed in the high range must not reach below
+	 * the 32 bit boundary. Otherwise we cannot place the cpu field
+	 * at the 32 bit boundary.
+	 */
 	BUILD_BUG_ON(SECTIONS_WIDTH + NODES_WIDTH + ZONES_WIDTH +
-		ilog2(roundup_pow_of_two(NR_CPUS)) >
-				BITS_PER_LONG - NR_PAGEFLAGS);
+		ilog2(roundup_pow_of_two(NR_CPUS)) > 32);
+
 	BUILD_BUG_ON(NR_CPUS > 4096);
 
 	kern_base = (prom_boot_mapping_phys_low >> 22UL) << 22UL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
