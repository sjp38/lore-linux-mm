Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 872B18D0041
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 14:08:26 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 3/8] Preserve local node for KSM copies
Date: Mon, 21 Feb 2011 11:07:45 -0800
Message-Id: <1298315270-10434-4-git-send-email-andi@firstfloor.org>
In-Reply-To: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>arcange@redhat.com

From: Andi Kleen <ak@linux.intel.com>

Add a alloc_page_vma_node that allows passing the "local" node in.
Use it in ksm to allocate copy pages on the same node as
the original as possible.

Cc: arcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/gfp.h |    2 ++
 mm/ksm.c            |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 782e74a..814d50e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -343,6 +343,8 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
+#define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
+	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/mm/ksm.c b/mm/ksm.c
index c2b2a94..fc83335 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1575,7 +1575,8 @@ struct page *ksm_does_need_to_copy(struct page *page,
 {
 	struct page *new_page;
 
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	new_page = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE, vma, address,
+				       page_to_nid(page));
 	if (new_page) {
 		copy_user_highpage(new_page, page, address, vma);
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
