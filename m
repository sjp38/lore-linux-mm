Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5630082F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 03:03:19 -0500 (EST)
Received: by padhx2 with SMTP id hx2so107230158pad.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 00:03:19 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id di2si16003940pbd.158.2015.11.06.00.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 00:03:18 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so115294776pab.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 00:03:18 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] mm: hwpoison: adjust for new thp refcounting
Date: Fri,  6 Nov 2015 17:03:12 +0900
Message-Id: <1446796992-15798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
References: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Wanpeng Li <wanpeng.li@hotmail.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Some mm-related BUG_ON()s could trigger from hwpoison code due to recent
changes in thp refcounting rule. This patch fixes them up.

In the new refcounting, we no longer use tail->_mapcount to keep tail's
refcount, and thereby we can simplify get/put_hwpoison_page().

And another change is that tail's refcount is not transferred to the raw
page during thp split (more precisely, in new rule we don't take refcount
on tail page any more.) So when we need thp split, we have to transfer the
refcount properly to the 4kB soft-offlined page before migration.

thp split code goes into core code only when precheck (total_mapcount(head)
== page_count(head) - 1) passes to avoid useless split, where we assume that
one refcount is held by the caller of thp split and the others are taken
via mapping. To meet this assumption, this patch moves thp split part in
soft_offline_page() after get_any_page().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- leave put_hwpoison_page() as a macro

- based on mmotm-2015-10-21-14-41 + Kirill's "[PATCH 0/4] Bugfixes for THP
  refcounting" series.
---
 include/linux/mm.h  |    1 +
 mm/memory-failure.c |   75 +++++++++++++++------------------------------------
 2 files changed, 23 insertions(+), 53 deletions(-)

diff --git mmotm-2015-10-21-14-41/include/linux/mm.h mmotm-2015-10-21-14-41_patched/include/linux/mm.h
index a36f9fa..51e3ffe 100644
--- mmotm-2015-10-21-14-41/include/linux/mm.h
+++ mmotm-2015-10-21-14-41_patched/include/linux/mm.h
@@ -2173,6 +2173,7 @@ extern int memory_failure(unsigned long pfn, int trapno, int flags);
 extern void memory_failure_queue(unsigned long pfn, int trapno, int flags);
 extern int unpoison_memory(unsigned long pfn);
 extern int get_hwpoison_page(struct page *page);
+#define put_hwpoison_page(page)	put_page(page)
 extern void put_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
diff --git mmotm-2015-10-21-14-41/mm/memory-failure.c mmotm-2015-10-21-14-41_patched/mm/memory-failure.c
index a2c987d..1b99403 100644
--- mmotm-2015-10-21-14-41/mm/memory-failure.c
+++ mmotm-2015-10-21-14-41_patched/mm/memory-failure.c
@@ -882,15 +882,7 @@ int get_hwpoison_page(struct page *page)
 {
 	struct page *head = compound_head(page);
 
-	if (PageHuge(head))
-		return get_page_unless_zero(head);
-
-	/*
-	 * Thp tail page has special refcounting rule (refcount of tail pages
-	 * is stored in ->_mapcount,) so we can't call get_page_unless_zero()
-	 * directly for tail pages.
-	 */
-	if (PageTransHuge(head)) {
+	if (!PageHuge(head) && PageTransHuge(head)) {
 		/*
 		 * Non anonymous thp exists only in allocation/free time. We
 		 * can't handle such a case correctly, so let's give it up.
@@ -902,41 +894,12 @@ int get_hwpoison_page(struct page *page)
 				page_to_pfn(page));
 			return 0;
 		}
-
-		if (get_page_unless_zero(head)) {
-			if (PageTail(page))
-				get_page(page);
-			return 1;
-		} else {
-			return 0;
-		}
 	}
 
-	return get_page_unless_zero(page);
+	return get_page_unless_zero(head);
 }
 EXPORT_SYMBOL_GPL(get_hwpoison_page);
 
-/**
- * put_hwpoison_page() - Put refcount for memory error handling:
- * @page:	raw error page (hit by memory error)
- */
-void put_hwpoison_page(struct page *page)
-{
-	struct page *head = compound_head(page);
-
-	if (PageHuge(head)) {
-		put_page(head);
-		return;
-	}
-
-	if (PageTransHuge(head))
-		if (page != head)
-			put_page(head);
-
-	put_page(page);
-}
-EXPORT_SYMBOL_GPL(put_hwpoison_page);
-
 /*
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
@@ -1162,6 +1125,8 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			return -EBUSY;
 		}
 		unlock_page(hpage);
+		get_hwpoison_page(p);
+		put_hwpoison_page(hpage);
 		VM_BUG_ON_PAGE(!page_count(p), p);
 		hpage = compound_head(p);
 	}
@@ -1575,7 +1540,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		 * Did it turn free?
 		 */
 		ret = __get_any_page(page, pfn, 0);
-		if (!PageLRU(page)) {
+		if (ret == 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
 			put_hwpoison_page(page);
 			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
@@ -1753,24 +1718,28 @@ int soft_offline_page(struct page *page, int flags)
 			put_hwpoison_page(page);
 		return -EBUSY;
 	}
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(page);
-		ret = split_huge_page(hpage);
-		unlock_page(page);
-		if (unlikely(ret)) {
-			pr_info("soft offline: %#lx: failed to split THP\n",
-				pfn);
-			if (flags & MF_COUNT_INCREASED)
-				put_hwpoison_page(page);
-			return -EBUSY;
-		}
-	}
 
 	get_online_mems();
-
 	ret = get_any_page(page, pfn, flags);
 	put_online_mems();
+
 	if (ret > 0) { /* for in-use pages */
+		if (!PageHuge(page) && PageTransHuge(hpage)) {
+			lock_page(hpage);
+			ret = split_huge_page(hpage);
+			unlock_page(hpage);
+			if (unlikely(ret || PageTransCompound(page) ||
+					!PageAnon(page))) {
+				pr_info("soft offline: %#lx: failed to split THP\n",
+					pfn);
+				if (flags & MF_COUNT_INCREASED)
+					put_hwpoison_page(hpage);
+				return -EBUSY;
+			}
+			get_hwpoison_page(page);
+			put_hwpoison_page(hpage);
+		}
+
 		if (PageHuge(page))
 			ret = soft_offline_huge_page(page, flags);
 		else
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
