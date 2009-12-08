Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CAE5760079A
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:35 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [16/31] HWPOISON: return 0 to indicate success reliably
Message-Id: <20091208211632.6E4C5B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:32 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Return 0 to indicate success, when
- action result is RECOVERED or DELAYED
- no extra page reference

Note that dirty swapcache pages are kept in swapcache, so can have one
more reference count.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -656,17 +656,21 @@ static int page_action(struct page_state
 	action_result(pfn, ps->msg, result);
 
 	count = page_count(p) - 1;
-	if (count != 0)
+	if (ps->action == me_swapcache_dirty && result == DELAYED)
+		count--;
+	if (count != 0) {
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
 		       pfn, ps->msg, count);
+		result = FAILED;
+	}
 
 	/* Could do more checks here if page looks ok */
 	/*
 	 * Could adjust zone counters here to correct for the missing page.
 	 */
 
-	return result == RECOVERED ? 0 : -EBUSY;
+	return (result == RECOVERED || result == DELAYED) ? 0 : -EBUSY;
 }
 
 #define N_UNMAP_TRIES 5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
