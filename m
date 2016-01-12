Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 82928680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 22:10:52 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so70901361pac.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:52 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id bw10si21409700pab.22.2016.01.11.19.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 19:10:51 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id a20so20167096pag.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:51 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/2] mm: soft-offline: clean up soft_offline_page()
Date: Tue, 12 Jan 2016 12:10:44 +0900
Message-Id: <1452568245-10412-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
 <1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

soft_offline_page() has some deeply indented code, that's the sign of demand
for cleanup. So let's do this. No functionality change.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 78 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 47 insertions(+), 31 deletions(-)

diff --git next-20160111/mm/memory-failure.c next-20160111_patched/mm/memory-failure.c
index 1b99403..2015c9a 100644
--- next-20160111/mm/memory-failure.c
+++ next-20160111_patched/mm/memory-failure.c
@@ -1684,6 +1684,49 @@ static int __soft_offline_page(struct page *page, int flags)
 	return ret;
 }
 
+static int soft_offline_in_use_page(struct page *page, int flags)
+{
+	int ret;
+	struct page *hpage = compound_head(page);
+
+	if (!PageHuge(page) && PageTransHuge(hpage)) {
+		lock_page(hpage);
+		ret = split_huge_page(hpage);
+		unlock_page(hpage);
+		if (unlikely(ret || PageTransCompound(page) ||
+			     !PageAnon(page))) {
+			pr_info("soft offline: %#lx: failed to split THP\n",
+				page_to_pfn(page));
+			if (flags & MF_COUNT_INCREASED)
+				put_hwpoison_page(hpage);
+			return -EBUSY;
+		}
+		get_hwpoison_page(page);
+		put_hwpoison_page(hpage);
+	}
+
+	if (PageHuge(page))
+		ret = soft_offline_huge_page(page, flags);
+	else
+		ret = __soft_offline_page(page, flags);
+
+	return ret;
+}
+
+static void soft_offline_free_page(struct page *page)
+{
+	if (PageHuge(page)) {
+		struct page *hpage = compound_head(page);
+
+		set_page_hwpoison_huge_page(hpage);
+		if (!dequeue_hwpoisoned_huge_page(hpage))
+			num_poisoned_pages_add(1 << compound_order(hpage));
+	} else {
+		if (!TestSetPageHWPoison(page))
+			num_poisoned_pages_inc();
+	}
+}
+
 /**
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
@@ -1710,7 +1753,6 @@ int soft_offline_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
-	struct page *hpage = compound_head(page);
 
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
@@ -1723,36 +1765,10 @@ int soft_offline_page(struct page *page, int flags)
 	ret = get_any_page(page, pfn, flags);
 	put_online_mems();
 
-	if (ret > 0) { /* for in-use pages */
-		if (!PageHuge(page) && PageTransHuge(hpage)) {
-			lock_page(hpage);
-			ret = split_huge_page(hpage);
-			unlock_page(hpage);
-			if (unlikely(ret || PageTransCompound(page) ||
-					!PageAnon(page))) {
-				pr_info("soft offline: %#lx: failed to split THP\n",
-					pfn);
-				if (flags & MF_COUNT_INCREASED)
-					put_hwpoison_page(hpage);
-				return -EBUSY;
-			}
-			get_hwpoison_page(page);
-			put_hwpoison_page(hpage);
-		}
+	if (ret > 0)
+		ret = soft_offline_in_use_page(page, flags);
+	else if (ret == 0)
+		soft_offline_free_page(page);
 
-		if (PageHuge(page))
-			ret = soft_offline_huge_page(page, flags);
-		else
-			ret = __soft_offline_page(page, flags);
-	} else if (ret == 0) { /* for free pages */
-		if (PageHuge(page)) {
-			set_page_hwpoison_huge_page(hpage);
-			if (!dequeue_hwpoisoned_huge_page(hpage))
-				num_poisoned_pages_add(1 << compound_order(hpage));
-		} else {
-			if (!TestSetPageHWPoison(page))
-				num_poisoned_pages_inc();
-		}
-	}
 	return ret;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
