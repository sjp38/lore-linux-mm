Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A6D696B016C
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:48:51 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so112412400pdb.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:48:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id zc7si32280099pac.154.2015.05.21.08.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:48:47 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v3 PATCH 03/10] mm/hugetlb: add region_del() to delete a specific range of entries
Date: Thu, 21 May 2015 08:47:37 -0700
Message-Id: <1432223264-4414-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

fallocate hole punch will want to remove a specific range of pages.
The existing region_truncate() routine deletes all region/reserve
map entries after a specified offset.  region_del() will provide
this same functionality if the end of region is specified as -1.
Hence, region_del() can replace region_truncate().

Unlike region_truncate(), region_del() can return an error in the
rare case where it can not allocate memory for a region descriptor.
This ONLY happens in the case where an existing region must be split.
Current callers passing -1 as end of range will never experience
this error and do not need to deal with error handling.  Future
callers of region_del() (such as fallocate hole punch) will need to
handle this error.  A routine hugetlb_fix_reserve_counts() is added
to assist in cleaning up if fallocate hole punch experiences this
type of error in region_del().

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 99 ++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 79 insertions(+), 21 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7b57850..fd337f2 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -81,6 +81,7 @@ bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 bool is_hugepage_active(struct page *page);
 void free_huge_page(struct page *page);
+void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 63f6d43..620cc9e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -261,38 +261,74 @@ out_nrg:
 	return chg;
 }
 
-static long region_truncate(struct resv_map *resv, long end)
+static long region_del(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
 	struct file_region *rg, *trg;
+	struct file_region *nrg = NULL;
 	long chg = 0;
 
+	/*
+	 * Locate segments we overlap and etiher split, remove or
+	 * trim the existing regions.  The end of region (t) == -1
+	 * indicates all remaining regions.  Special case t == -1 as
+	 * all comparisons are signed.  Also, when t == -1 it is not
+	 * possible to return an error (-ENOMEM) as this only happens
+	 * when splitting a region.  Callers take advantage of this
+	 * when calling with -1.
+	 */
+	if (t == -1)
+		t = LONG_MAX;
+retry:
 	spin_lock(&resv->lock);
-	/* Locate the region we are either in or before. */
-	list_for_each_entry(rg, head, link)
-		if (end <= rg->to)
+	list_for_each_entry_safe(rg, trg, head, link) {
+		if (rg->to <= f)
+			continue;
+		if (rg->from >= t)
 			break;
-	if (&rg->link == head)
-		goto out;
 
-	/* If we are in the middle of a region then adjust it. */
-	if (end > rg->from) {
-		chg = rg->to - end;
-		rg->to = end;
-		rg = list_entry(rg->link.next, typeof(*rg), link);
-	}
+		if (f > rg->from && t < rg->to) { /* must split region */
+			if (!nrg) {
+				spin_unlock(&resv->lock);
+				nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+				if (!nrg)
+					return -ENOMEM;
+				goto retry;
+			}
 
-	/* Drop any remaining regions. */
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
+			chg += t - f;
+
+			/* new entry for end of split region */
+			nrg->from = t;
+			nrg->to = rg->to;
+			INIT_LIST_HEAD(&nrg->link);
+
+			/* original entry is trimmed */
+			rg->to = f;
+
+			list_add(&nrg->link, &rg->link);
+			nrg = NULL;
 			break;
-		chg += rg->to - rg->from;
-		list_del(&rg->link);
-		kfree(rg);
+		}
+
+		if (f <= rg->from && t >= rg->to) { /* remove entire region */
+			chg += rg->to - rg->from;
+			list_del(&rg->link);
+			kfree(rg);
+			continue;
+		}
+
+		if (f <= rg->from) {	/* trim beginning of region */
+			chg += t - rg->from;
+			rg->from = t;
+		} else {		/* trim end of region */
+			chg += rg->to - f;
+			rg->to = f;
+		}
 	}
 
-out:
 	spin_unlock(&resv->lock);
+	kfree(nrg);
 	return chg;
 }
 
@@ -324,6 +360,27 @@ static long region_count(struct resv_map *resv, long f, long t)
 }
 
 /*
+ * A rare out of memory error was encountered which prevented removal of
+ * the reserve map region for a page.  The huge page itself was free''ed
+ * and removed from the page cache.  This routine will adjust the global
+ * reserve count if needed, and the subpool usage count.  By incrementing
+ * these counts, the reserve map entry which could not be deleted will
+ * appear as a "reserved" entry instead of simply dangling with incorrect
+ * counts.
+ */
+void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve)
+{
+	struct hugepage_subpool *spool = subpool_inode(inode);
+
+	if (restore_reserve) {
+		struct hstate *h = hstate_inode(inode);
+
+		h->resv_huge_pages++;
+	}
+	hugepage_subpool_get_pages(spool, 1);
+}
+
+/*
  * Convert the address within this vma to the page offset within
  * the mapping, in pagecache page units; huge pages here.
  */
@@ -427,7 +484,7 @@ void resv_map_release(struct kref *ref)
 	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
 
 	/* Clear out any active regions before we release the map. */
-	region_truncate(resv_map, 0);
+	region_del(resv_map, 0, -1);
 	kfree(resv_map);
 }
 
@@ -3558,7 +3615,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
 	if (resv_map)
-		chg = region_truncate(resv_map, offset);
+		chg = region_del(resv_map, offset, -1);
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
