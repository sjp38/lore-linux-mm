Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D115828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:15:03 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so14890914pab.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:15:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bm5si9841966pad.107.2016.02.03.07.15.02
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:15:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] rmap: introduce rmap_walk_locked()
Date: Wed,  3 Feb 2016 18:14:16 +0300
Message-Id: <1454512459-94334-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

rmap_walk_locked() is the same as rmap_walk(), but caller takes care
about relevant rmap lock. It only supports anonymous pages for now.

It's preparation to switch THP splitting from custom rmap walk in
freeze_page()/unfreeze_page() to generic one.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  1 +
 mm/rmap.c            | 25 +++++++++++++++++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bdf597c4f0be..23a03fbeef61 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -280,6 +280,7 @@ struct rmap_walk_control {
 };
 
 int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
+int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc);
 
 #else	/* !CONFIG_MMU */
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 79f3bf047f38..a9cffb784502 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1719,14 +1719,21 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * LOCKED.
  */
-static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
+static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
+		bool locked)
 {
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = rmap_walk_anon_lock(page, rwc);
+	if (locked) {
+		anon_vma = page_anon_vma(page);
+		/* anon_vma disappear under us? */
+		VM_BUG_ON_PAGE(!anon_vma, page);
+	} else {
+		anon_vma = rmap_walk_anon_lock(page, rwc);
+	}
 	if (!anon_vma)
 		return ret;
 
@@ -1746,7 +1753,9 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 		if (rwc->done && rwc->done(page))
 			break;
 	}
-	anon_vma_unlock_read(anon_vma);
+
+	if (!locked)
+		anon_vma_unlock_read(anon_vma);
 	return ret;
 }
 
@@ -1808,11 +1817,19 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 	if (unlikely(PageKsm(page)))
 		return rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
-		return rmap_walk_anon(page, rwc);
+		return rmap_walk_anon(page, rwc, false);
 	else
 		return rmap_walk_file(page, rwc);
 }
 
+/* Like rmap_walk, but caller holds relevant rmap lock */
+int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
+{
+	/* only for anon pages for now */
+	VM_BUG_ON_PAGE(!PageAnon(page) || PageKsm(page), page);
+	return rmap_walk_anon(page, rwc, true);
+}
+
 #ifdef CONFIG_HUGETLB_PAGE
 /*
  * The following three functions are for anonymous (private mapped) hugepages.
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
