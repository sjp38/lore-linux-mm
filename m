Date: Mon, 18 Oct 2004 13:04:44 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] change pagevec counters back to unsigned long and cacheline align
Message-ID: <20041018150444.GD2403@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Change pagevec "nr" and "cold" back to "unsigned long", 
because 4 byte accesses can be slow on architectures < Pentium III 
(additional "data16" operand on instruction).

This still honours the cacheline alignment, making the size
of "pagevec" structure a power of two (either 64 or 128 bytes).

Haven't been able to see any significant change on performance on my 
limited testing.



--- rc4-mm1.orig/include/linux/pagevec.h	2004-10-15 01:02:39.209481760 -0300
+++ rc4-mm1/include/linux/pagevec.h	2004-10-15 01:17:58.853674592 -0300
@@ -5,14 +5,15 @@
  * pages.  A pagevec is a multipage container which is used for that.
  */
 
-#define PAGEVEC_SIZE	15
+/* 14 pointers + two long's align the pagevec structure to a power of two */
+#define PAGEVEC_SIZE	14
 
 struct page;
 struct address_space;
 
 struct pagevec {
-	unsigned short nr;
-	unsigned short cold;
+	unsigned long nr;
+	unsigned long cold;
 	struct page *pages[PAGEVEC_SIZE];
 };
 

----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
