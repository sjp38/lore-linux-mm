Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A08286B0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 13:18:25 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3] mm: clean up soft_offline_page() (Re: [PATCH v2] mm: clean up soft_offline_page())
Date: Mon, 28 Jan 2013 13:18:10 -0500
Message-Id: <1359397090-9644-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130127014811.GL30577@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 27, 2013 at 02:48:11AM +0100, Andi Kleen wrote:
> On Sat, Jan 26, 2013 at 12:02:11AM -0500, Naoya Horiguchi wrote:
> > Currently soft_offline_page() is hard to maintain because it has many
> > return points and goto statements. All of this mess come from get_any_page().
> > This function should only get page refcount as the name implies, but it does
> > some page isolating actions like SetPageHWPoison() and dequeuing hugepage.
> > This patch corrects it and introduces some internal subroutines to make
> > soft offlining code more readable and maintainable.
> > 
> > ChangeLog v2:
> >   - receive returned value from __soft_offline_page and soft_offline_huge_page
> >   - place __soft_offline_page after soft_offline_page to reduce the diff
> >   - rebased onto mmotm-2013-01-23-17-04
> >   - add comment on double checks of PageHWpoison
> 
> Ok for me if it passes mce-test
> 
> Reviewed-by: Andi Kleen <andi@firstfloor.org>

As Xishi pointed out, the patch was broken. Mce-test did catch it, but the
related testcase HWPOISON-SOFT showed PASS falsely, so I overlooked it.
Now I confirm that tsoft.c and tsoftinj.c in mce-test surely passes (returns
with success exitcode) with the fixed one (attached).

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 28 Jan 2013 11:00:02 -0500
Subject: [PATCH v3] mm: clean up soft_offline_page()

Currently soft_offline_page() is hard to maintain because it has many
return points and goto statements. All of this mess come from get_any_page().
This function should only get page refcount as the name implies, but it does
some page isolating actions like SetPageHWPoison() and dequeuing hugepage.
This patch corrects it and introduces some internal subroutines to make
soft offlining code more readable and maintainable.

ChangeLog v3:
  - fixed soft_offline_huge_page for in-use hugepage case (thanks to Xishi Qiu)

ChangeLog v2:
  - receive returned value from __soft_offline_page and soft_offline_huge_page
  - place __soft_offline_page after soft_offline_page to reduce the diff
  - rebased onto mmotm-2013-01-23-17-04
  - add comment on double checks of PageHWpoison

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <andi@firstfloor.org>
---
 mm/memory-failure.c | 156 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 87 insertions(+), 69 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index c95e19a..9cab165 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1368,7 +1368,7 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
  * that is not free, and 1 for any other page type.
  * For 1 the page is returned with increased page count, otherwise not.
  */
-static int get_any_page(struct page *p, unsigned long pfn, int flags)
+static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 {
 	int ret;
 
@@ -1393,11 +1393,9 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	if (!get_page_unless_zero(compound_head(p))) {
 		if (PageHuge(p)) {
 			pr_info("%s: %#lx free huge page\n", __func__, pfn);
-			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
+			ret = 0;
 		} else if (is_free_buddy_page(p)) {
 			pr_info("%s: %#lx free buddy page\n", __func__, pfn);
-			/* Set hwpoison bit while page is still isolated */
-			SetPageHWPoison(p);
 			ret = 0;
 		} else {
 			pr_info("%s: %#lx: unknown zero refcount page type %lx\n",
@@ -1413,23 +1411,48 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
 	return ret;
 }
 
+static int get_any_page(struct page *page, unsigned long pfn, int flags)
+{
+	int ret = __get_any_page(page, pfn, flags);
+
+	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
+		/*
+		 * Try to free it.
+		 */
+		put_page(page);
+		shake_page(page, 1);
+
+		/*
+		 * Did it turn free?
+		 */
+		ret = __get_any_page(page, pfn, 0);
+		if (!PageLRU(page)) {
+			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
+				pfn, page->flags);
+			return -EIO;
+		}
+	}
+	return ret;
+}
+
 static int soft_offline_huge_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_head(page);
 
+	/*
+	 * This double-check of PageHWPoison is to avoid the race with
+	 * memory_failure(). See also comment in __soft_offline_page().
+	 */
+	lock_page(hpage);
 	if (PageHWPoison(hpage)) {
+		unlock_page(hpage);
+		put_page(hpage);
 		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
-		ret = -EBUSY;
-		goto out;
+		return -EBUSY;
 	}
-
-	ret = get_any_page(page, pfn, flags);
-	if (ret < 0)
-		goto out;
-	if (ret == 0)
-		goto done;
+	unlock_page(hpage);
 
 	/* Keep page count to indicate a given hugepage is isolated. */
 	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
@@ -1438,17 +1461,18 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	if (ret) {
 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 			pfn, ret, page->flags);
-		goto out;
+	} else {
+		set_page_hwpoison_huge_page(hpage);
+		dequeue_hwpoisoned_huge_page(hpage);
+		atomic_long_add(1 << compound_trans_order(hpage),
+				&num_poisoned_pages);
 	}
-done:
 	/* keep elevated page count for bad page */
-	atomic_long_add(1 << compound_trans_order(hpage), &num_poisoned_pages);
-	set_page_hwpoison_huge_page(hpage);
-	dequeue_hwpoisoned_huge_page(hpage);
-out:
 	return ret;
 }
 
+static int __soft_offline_page(struct page *page, int flags);
+
 /**
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
@@ -1477,62 +1501,60 @@ int soft_offline_page(struct page *page, int flags)
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_trans_head(page);
 
-	if (PageHuge(page)) {
-		ret = soft_offline_huge_page(page, flags);
-		goto out;
+	if (PageHWPoison(page)) {
+		pr_info("soft offline: %#lx page already poisoned\n", pfn);
+		return -EBUSY;
 	}
-	if (PageTransHuge(hpage)) {
+	if (!PageHuge(page) && PageTransHuge(hpage)) {
 		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
 			pr_info("soft offline: %#lx: failed to split THP\n",
 				pfn);
-			ret = -EBUSY;
-			goto out;
+			return -EBUSY;
 		}
 	}
 
-	if (PageHWPoison(page)) {
-		pr_info("soft offline: %#lx page already poisoned\n", pfn);
-		ret = -EBUSY;
-		goto out;
-	}
-
 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
-		goto out;
-	if (ret == 0)
-		goto done;
-
-	/*
-	 * Page cache page we can handle?
-	 */
-	if (!PageLRU(page)) {
-		/*
-		 * Try to free it.
-		 */
-		put_page(page);
-		shake_page(page, 1);
-
-		/*
-		 * Did it turn free?
-		 */
-		ret = get_any_page(page, pfn, 0);
-		if (ret < 0)
-			goto out;
-		if (ret == 0)
-			goto done;
-	}
-	if (!PageLRU(page)) {
-		pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
-			pfn, page->flags);
-		ret = -EIO;
-		goto out;
+		return ret;
+	if (ret) { /* for in-use pages */
+		if (PageHuge(page))
+			ret = soft_offline_huge_page(page, flags);
+		else
+			ret = __soft_offline_page(page, flags);
+	} else { /* for free pages */
+		if (PageHuge(page)) {
+			set_page_hwpoison_huge_page(hpage);
+			dequeue_hwpoisoned_huge_page(hpage);
+			atomic_long_add(1 << compound_trans_order(hpage),
+					&num_poisoned_pages);
+		} else {
+			SetPageHWPoison(page);
+			atomic_long_inc(&num_poisoned_pages);
+		}
 	}
+	/* keep elevated page count for bad page */
+	return ret;
+}
+
+static int __soft_offline_page(struct page *page, int flags)
+{
+	int ret;
+	unsigned long pfn = page_to_pfn(page);
 
 	/*
-	 * Synchronized using the page lock with memory_failure()
+	 * Check PageHWPoison again inside page lock because PageHWPoison
+	 * is set by memory_failure() outside page lock. Note that
+	 * memory_failure() also double-checks PageHWPoison inside page lock,
+	 * so there's no race between soft_offline_page() and memory_failure().
 	 */
 	lock_page(page);
 	wait_on_page_writeback(page);
+	if (PageHWPoison(page)) {
+		unlock_page(page);
+		put_page(page);
+		pr_info("soft offline: %#lx page already poisoned\n", pfn);
+		return -EBUSY;
+	}
 	/*
 	 * Try to invalidate first. This should work for
 	 * non dirty unmapped page cache pages.
@@ -1545,9 +1567,10 @@ int soft_offline_page(struct page *page, int flags)
 	 */
 	if (ret == 1) {
 		put_page(page);
-		ret = 0;
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
-		goto done;
+		SetPageHWPoison(page);
+		atomic_long_inc(&num_poisoned_pages);
+		return 0;
 	}
 
 	/*
@@ -1575,18 +1598,13 @@ int soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret = -EIO;
+		} else {
+			SetPageHWPoison(page);
+			atomic_long_inc(&num_poisoned_pages);
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
 			pfn, ret, page_count(page), page->flags);
 	}
-	if (ret)
-		goto out;
-
-done:
-	/* keep elevated page count for bad page */
-	atomic_long_inc(&num_poisoned_pages);
-	SetPageHWPoison(page);
-out:
 	return ret;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
