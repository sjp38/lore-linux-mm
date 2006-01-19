Date: Thu, 19 Jan 2006 21:52:59 +0000
Subject: [PATCH 2/2] GFP_ZONETYPES calculate from GFP_ZONEMASK
Message-ID: <20060119215259.GA29627@shadowen.org>
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

GFP_ZONETYPES calculate from GFP_ZONEMASK

GFP_ZONETYPES's value is directly related to the value of GFP_ZONEMASK. 
It takes one of two forms depending whether the top bit of GFP_ZONEMASK
is a 'loner'.  Supply both forms, enabling the loner.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mmzone.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -98,11 +98,14 @@ struct per_cpu_pageset {
  * of three zone modifier bits, we could require up to eight zonelists.
  * If the left most zone modifier is a "loner" then the highest valid
  * zonelist would be four allowing us to allocate only five zonelists.
+ * Use the first form for GFP_ZONETYPES when the left most bit is not
+ * a "loner", otherwise use the second.
  *
  * NOTE! Make sure this matches the zones in <linux/gfp.h>
  */
 #define GFP_ZONEMASK	0x07
-#define GFP_ZONETYPES	5
+/* #define GFP_ZONETYPES       (GFP_ZONEMASK + 1) */           /* Non-loner */
+#define GFP_ZONETYPES  ((GFP_ZONEMASK + 1) / 2 + 1)            /* Loner */
 
 /*
  * On machines where it is needed (eg PCs) we divide physical memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
