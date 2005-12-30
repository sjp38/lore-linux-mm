From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20051230224032.765.94689.sendpatchset@twins.localnet>
In-Reply-To: <20051230223952.765.21096.sendpatchset@twins.localnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
Subject: [PATCH 04/14] page-replace-activate_page.patch
Date: Fri, 30 Dec 2005 23:40:54 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

page-replace interface function:
  page_replace_activate()

This function will modify the page state for a reference action.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 include/linux/mm_page_replace.h |    4 ++++
 mm/vmscan.c                     |    3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6-git/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_page_replace.h	2005-12-10 17:13:56.000000000 +0100
+++ linux-2.6-git/include/linux/mm_page_replace.h	2005-12-10 18:19:30.000000000 +0100
@@ -7,6 +7,10 @@
 #include <linux/mm.h>
 
 void __page_replace_insert(struct zone *, struct page *);
+static inline void page_replace_activate(struct page *page)
+{
+	SetPageActive(page);
+}
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_PAGE_REPLACE_H */
Index: linux-2.6-git/mm/vmscan.c
===================================================================
--- linux-2.6-git.orig/mm/vmscan.c	2005-12-10 17:13:57.000000000 +0100
+++ linux-2.6-git/mm/vmscan.c	2005-12-10 18:19:34.000000000 +0100
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -573,7 +574,7 @@ static int shrink_list(struct list_head 
 
 		switch(try_pageout(page, sc)) {
 		case PAGEOUT_ACTIVATE:
-			SetPageActive(page);
+			page_replace_activate(page);
 			pgactivate++;
 			/* fall through */
 		case PAGEOUT_KEEP:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
