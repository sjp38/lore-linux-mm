From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: cleanup swap unused warning
Date: Wed, 10 May 2006 21:32:40 +1000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200605102132.41217.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Are there any users of swp_entry_t when CONFIG_SWAP is not defined?

This patch fixes a warning for !CONFIG_SWAP for me.

---
if CONFIG_SWAP is not defined we get:

mm/vmscan.c: In function a??remove_mappinga??:
mm/vmscan.c:387: warning: unused variable a??swapa??

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 include/linux/swap.h |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

Index: linux-2.6.17-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc3-mm1.orig/include/linux/swap.h	2006-05-10 21:14:41.000000000 +1000
+++ linux-2.6.17-rc3-mm1/include/linux/swap.h	2006-05-10 21:24:31.000000000 +1000
@@ -67,13 +67,20 @@ union swap_header {
 	} info;
 };
 
- /* A swap entry has to fit into a "unsigned long", as
-  * the entry is hidden in the "index" field of the
-  * swapper address space.
-  */
+/*
+ * A swap entry has to fit into a "unsigned long", as
+ * the entry is hidden in the "index" field of the
+ * swapper address space.
+ */
+#ifdef CONFIG_SWAP
 typedef struct {
 	unsigned long val;
 } swp_entry_t;
+#else
+typedef struct {
+	unsigned long val;
+} swp_entry_t __attribute__((__unused__));
+#endif
 
 /*
  * current->reclaim_state points to one of these when a task is running

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
