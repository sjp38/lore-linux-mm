Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 202376B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:35:57 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7ZrjY025571
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:35:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B0CB45DE70
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:35:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F2C945DE6E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:35:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 250171DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:35:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4BAB1DB803A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:35:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  8/8] Don't deactivate many touched page
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210163429.2568.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:35:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Changelog
 o from v1
   - Fix comments.
   - Rename too_many_young_bit_found() with too_many_referenced()
     [as Rik's mention].
 o from andrea's original patch
   - Rebase topon my patches.
   - Use list_cut_position/list_splice_tail pair instead
     list_del/list_add to make pte scan fairness.
   - Only use max young threshold when soft_try is true.
     It avoid wrong OOM sideeffect.
   - Return SWAP_AGAIN instead successful result if max
     young threshold exceed. It prevent the pages without clear
     pte young bit will be deactivated wrongly.
   - Add to treat ksm page logic

Many shared and frequently used page don't need deactivate and
try_to_unamp(). It's pointless while VM pressure is low, the page
might reactivate soon. it's only makes cpu wasting.

Then, This patch makes to stop pte scan if wipe_page_reference()
found lots young pte bit.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h |   18 ++++++++++++++++++
 mm/ksm.c             |    4 ++++
 mm/rmap.c            |   19 +++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 499972e..ddf2578 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -128,6 +128,24 @@ int wipe_page_reference_one(struct page *page,
 			    struct page_reference_context *refctx,
 			    struct vm_area_struct *vma, unsigned long address);
 
+#define MAX_YOUNG_BIT_CLEARED 64
+/*
+ * If VM pressure is low and the page has lots of active users, we only
+ * clear up to MAX_YOUNG_BIT_CLEARED accessed bits at a time.  Clearing
+ * accessed bits takes CPU time, needs TLB invalidate IPIs and could
+ * cause lock contention.  Since a heavily shared page is very likely
+ * to be used again soon, the cost outweighs the benefit of making such
+ * a heavily shared page a candidate for eviction.
+ */
+static inline
+int too_many_referenced(struct page_reference_context *refctx)
+{
+	if (refctx->soft_try &&
+	    refctx->referenced >= MAX_YOUNG_BIT_CLEARED)
+		return 1;
+	return 0;
+}
+
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
 	TTU_MIGRATION = 1,		/* migration mode */
diff --git a/mm/ksm.c b/mm/ksm.c
index 19559ae..e959c41 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1586,6 +1586,10 @@ again:
 						      rmap_item->address);
 			if (ret != SWAP_SUCCESS)
 				goto out;
+			if (too_many_referenced(refctx)) {
+				ret = SWAP_AGAIN;
+				goto out;
+			}
 			mapcount--;
 			if (!search_new_forks || !mapcount)
 				break;
diff --git a/mm/rmap.c b/mm/rmap.c
index cfda0a0..d66b8dc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -473,6 +473,21 @@ static int wipe_page_reference_anon(struct page *page,
 		ret = wipe_page_reference_one(page, refctx, vma, address);
 		if (ret != SWAP_SUCCESS)
 			break;
+		if (too_many_referenced(refctx)) {
+			LIST_HEAD(tmp_list);
+
+			/*
+			 * Rotating the anon vmas around help spread out lock
+			 * pressure in the VM. It help to reduce heavy lock
+			 * contention.
+			 */
+			list_cut_position(&tmp_list,
+					  &vma->anon_vma_node,
+					  &anon_vma->head);
+			list_splice_tail(&tmp_list, &vma->anon_vma_node);
+			ret = SWAP_AGAIN;
+			break;
+		}
 		mapcount--;
 		if (!mapcount || refctx->maybe_mlocked)
 			break;
@@ -543,6 +558,10 @@ static int wipe_page_reference_file(struct page *page,
 		ret = wipe_page_reference_one(page, refctx, vma, address);
 		if (ret != SWAP_SUCCESS)
 			break;
+		if (too_many_referenced(refctx)) {
+			ret = SWAP_AGAIN;
+			break;
+		}
 		mapcount--;
 		if (!mapcount || refctx->maybe_mlocked)
 			break;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
