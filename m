From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Apr 2007 14:02:21 +1000
Subject: [PATCH 12/14] get_unmapped_area handles MAP_FIXED in /dev/mem (nommu)
In-Reply-To: <1175659331.690672.592289266160.qpush@grosgo>
Message-Id: <20070404040232.2FEF6DDEBA@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This also fixes a bug, I think, it used to return a pgoff (pfn)
instead of an address. (To split ?)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/char/mem.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-cell/drivers/char/mem.c
===================================================================
--- linux-cell.orig/drivers/char/mem.c	2007-03-22 16:24:04.000000000 +1100
+++ linux-cell/drivers/char/mem.c	2007-03-22 16:26:30.000000000 +1100
@@ -246,9 +246,12 @@ static unsigned long get_unmapped_area_m
 					   unsigned long pgoff,
 					   unsigned long flags)
 {
+	if (flags & MAP_FIXED)
+		if ((addr >> PAGE_SHIFT) != pgoff)
+			return (unsigned long) -EINVAL;
 	if (!valid_mmap_phys_addr_range(pgoff, len))
 		return (unsigned long) -EINVAL;
-	return pgoff;
+	return pgoff << PAGE_SHIFT;
 }
 
 /* can't do an in-place private mapping if there's no MMU */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
