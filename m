Date: Thu, 19 Jan 2006 21:52:36 +0000
Subject: [PATCH 1/2] GFP_ZONETYPES add commentry on how to calculate
Message-ID: <20060119215236.GA29614@shadowen.org>
References: <1137205485.7130.81.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

GFP_ZONETYPES define using GFP_ZONEMASK and add commentry

Add commentry explaining the optimisation that we can apply to
GFP_ZONETYPES when the lest most bit is a 'loaner', it can only be
set in isolation.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mmzone.h |    8 ++++++++
 1 file changed, 8 insertions(+)
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -91,6 +91,14 @@ struct per_cpu_pageset {
  * be 8 (2 ** 3) zonelists.  GFP_ZONETYPES defines the number of possible
  * combinations of zone modifiers in "zone modifier space".
  *
+ * As an optimisation any zone modifier bits which are only valid when
+ * no other zone modifier bits are set (loners) should be placed in
+ * the highest order bits of this field.  This allows us to reduce the
+ * extent of the zonelists thus saving space.  For example in the case
+ * of three zone modifier bits, we could require up to eight zonelists.
+ * If the left most zone modifier is a "loner" then the highest valid
+ * zonelist would be four allowing us to allocate only five zonelists.
+ *
  * NOTE! Make sure this matches the zones in <linux/gfp.h>
  */
 #define GFP_ZONEMASK	0x07

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
