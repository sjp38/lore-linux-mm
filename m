Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA216B4461
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:25:05 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so12513874pfk.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:25:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h191sor2685046pge.48.2018.11.26.15.25.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:25:04 -0800 (PST)
Date: Mon, 26 Nov 2018 15:25:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 05/10] mm/khugepaged: fix crashes due to misaccounted holes
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261523450.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Huge tmpfs testing on a shortish file mapped into a pmd-rounded extent hit
shmem_evict_inode()'s WARN_ON(inode->i_blocks) followed by clear_inode()'s
BUG_ON(inode->i_data.nrpages) when the file was later closed and unlinked.

khugepaged's collapse_shmem() was forgetting to update mapping->nrpages on
the rollback path, after it had added but then needs to undo some holes.

There is indeed an irritating asymmetry between shmem_charge(), whose
callers want it to increment nrpages after successfully accounting blocks,
and shmem_uncharge(), when __delete_from_page_cache() already decremented
nrpages itself: oh well, just add a comment on that to them both.

And shmem_recalc_inode() is supposed to be called when the accounting is
expected to be in balance (so it can deduce from imbalance that reclaim
discarded some pages): so change shmem_charge() to update nrpages earlier
(though it's rare for the difference to matter at all).

Fixes: 800d8c63b2e98 ("shmem: add huge pages support")
Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 5 ++++-
 mm/shmem.c      | 6 +++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 2070c316f06e..65e82f665c7c 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1506,9 +1506,12 @@ static void collapse_shmem(struct mm_struct *mm,
 		khugepaged_pages_collapsed++;
 	} else {
 		struct page *page;
+
 		/* Something went wrong: roll back page cache changes */
-		shmem_uncharge(mapping->host, nr_none);
 		xas_lock_irq(&xas);
+		mapping->nrpages -= nr_none;
+		shmem_uncharge(mapping->host, nr_none);
+
 		xas_set(&xas, start);
 		xas_for_each(&xas, page, end - 1) {
 			page = list_first_entry_or_null(&pagelist,
diff --git a/mm/shmem.c b/mm/shmem.c
index ea26d7a0342d..e6558e49b42a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -297,12 +297,14 @@ bool shmem_charge(struct inode *inode, long pages)
 	if (!shmem_inode_acct_block(inode, pages))
 		return false;
 
+	/* nrpages adjustment first, then shmem_recalc_inode() when balanced */
+	inode->i_mapping->nrpages += pages;
+
 	spin_lock_irqsave(&info->lock, flags);
 	info->alloced += pages;
 	inode->i_blocks += pages * BLOCKS_PER_PAGE;
 	shmem_recalc_inode(inode);
 	spin_unlock_irqrestore(&info->lock, flags);
-	inode->i_mapping->nrpages += pages;
 
 	return true;
 }
@@ -312,6 +314,8 @@ void shmem_uncharge(struct inode *inode, long pages)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	unsigned long flags;
 
+	/* nrpages adjustment done by __delete_from_page_cache() or caller */
+
 	spin_lock_irqsave(&info->lock, flags);
 	info->alloced -= pages;
 	inode->i_blocks -= pages * BLOCKS_PER_PAGE;
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
