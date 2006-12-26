Message-ID: <1167152987.4591575b1a824@imp8-g19.free.fr>
Date: Tue, 26 Dec 2006 18:09:47 +0100
From: dimitri.gorokhovik@free.fr
Subject: [PATCH 1/1 2.6.20-rc2] MM: ramfs breaks without CONFIG_BLOCK
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
From: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

ramfs doesn't provide the .set_dirty_page a_op, and when the BLOCK
layer is not configured in, 'set_page_dirty' makes a call via a NULL
pointer.

Signed-off-by: Dimitri Gorokhovik <dimitri.gorokhovik@free.fr>

---

--- linux-2.6.20-rc2-orig/mm/page-writeback.c	2006-12-26
15:12:21.000000000 +0100
+++ linux-2.6.20-rc2/mm/page-writeback.c	2006-12-26 18:32:26.000000000
+0100
@@ -800,8 +800,8 @@ int redirty_page_for_writepage(struct wr
 EXPORT_SYMBOL(redirty_page_for_writepage);

 /*
- * If the mapping doesn't provide a set_page_dirty a_op, then
- * just fall through and assume that it wants buffer_heads.
+ * If the mapping doesn't provide a set_page_dirty a_op, and the BLOCK
layer is
+ * available, just fall through and assume that it wants buffer_heads.
  */
 int fastcall set_page_dirty(struct page *page)
 {
@@ -812,8 +812,12 @@ int fastcall set_page_dirty(struct page
 #ifdef CONFIG_BLOCK
 		if (!spd)
 			spd = __set_page_dirty_buffers;
-#endif
 		return (*spd)(page);
+#else
+		if (spd)
+			return (*spd)(page);
+#endif
+
 	}
 	if (!PageDirty(page)) {
 		if (!TestSetPageDirty(page))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
