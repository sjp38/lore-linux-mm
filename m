Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB91128025B
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k6so1238222pgt.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h14si5103022pfj.360.2018.01.17.12.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:40 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 34/99] mm: Convert delete_from_swap_cache to XArray
Date: Wed, 17 Jan 2018 12:20:58 -0800
Message-Id: <20180117202203.19756-35-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Both callers of __delete_from_swap_cache have the swp_entry_t already,
so pass that in to make constructing the XA_STATE easier.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/swap.h |  5 +++--
 mm/swap_state.c      | 24 ++++++++++--------------
 mm/vmscan.c          |  2 +-
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e519554730fa..8eb99229dbc0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -408,7 +408,7 @@ extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *page);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
-extern void __delete_from_swap_cache(struct page *);
+extern void __delete_from_swap_cache(struct page *, swp_entry_t entry);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
@@ -583,7 +583,8 @@ static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
 	return -1;
 }
 
-static inline void __delete_from_swap_cache(struct page *page)
+static inline void __delete_from_swap_cache(struct page *page,
+							swp_entry_t entry)
 {
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index a57b5ad4c503..219e3b4f09e6 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -154,23 +154,22 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
-void __delete_from_swap_cache(struct page *page)
+void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 {
-	struct address_space *address_space;
+	struct address_space *address_space = swap_address_space(entry);
 	int i, nr = hpage_nr_pages(page);
-	swp_entry_t entry;
-	pgoff_t idx;
+	pgoff_t idx = swp_offset(entry);
+	XA_STATE(xas, &address_space->pages, idx);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(PageWriteback(page), page);
 
-	entry.val = page_private(page);
-	address_space = swap_address_space(entry);
-	idx = swp_offset(entry);
 	for (i = 0; i < nr; i++) {
-		radix_tree_delete(&address_space->pages, idx + i);
+		void *entry = xas_store(&xas, NULL);
+		VM_BUG_ON_PAGE(entry != page + i, entry);
 		set_page_private(page + i, 0);
+		xas_next(&xas);
 	}
 	ClearPageSwapCache(page);
 	address_space->nrpages -= nr;
@@ -246,14 +245,11 @@ int add_to_swap(struct page *page)
  */
 void delete_from_swap_cache(struct page *page)
 {
-	swp_entry_t entry;
-	struct address_space *address_space;
-
-	entry.val = page_private(page);
+	swp_entry_t entry = { .val = page_private(page) };
+	struct address_space *address_space = swap_address_space(entry);
 
-	address_space = swap_address_space(entry);
 	xa_lock_irq(&address_space->pages);
-	__delete_from_swap_cache(page);
+	__delete_from_swap_cache(page, entry);
 	xa_unlock_irq(&address_space->pages);
 
 	put_swap_page(page, entry);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2fa675a2db31..51d437a18db8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -718,7 +718,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		mem_cgroup_swapout(page, swap);
-		__delete_from_swap_cache(page);
+		__delete_from_swap_cache(page, swap);
 		xa_unlock_irqrestore(&mapping->pages, flags);
 		put_swap_page(page, swap);
 	} else {
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
