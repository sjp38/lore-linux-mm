Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id D53E46B0254
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 00:33:48 -0400 (EDT)
Received: by qgj62 with SMTP id 62so86909675qgj.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 21:33:48 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id d34si23370381qgd.127.2015.08.16.21.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Aug 2015 21:33:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/3] mm/hwpoison: introduce num_poisoned_pages wrappers
Date: Mon, 17 Aug 2015 04:32:11 +0000
Message-ID: <1439785924-27885-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
 <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

num_poisoned_pages counter will be changed outside mm/memory-failure.c by a
subsequent patch, so this patch prepares wrappers to manipulate it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/swapops.h | 23 +++++++++++++++++++++++
 mm/memory-failure.c     | 30 ++++++++++++++----------------
 2 files changed, 37 insertions(+), 16 deletions(-)

diff --git mmotm-2015-08-13-15-29.orig/include/linux/swapops.h mmotm-2015-0=
8-13-15-29/include/linux/swapops.h
index cedf3d3c373f..ec04669f2a3b 100644
--- mmotm-2015-08-13-15-29.orig/include/linux/swapops.h
+++ mmotm-2015-08-13-15-29/include/linux/swapops.h
@@ -164,6 +164,9 @@ static inline int is_write_migration_entry(swp_entry_t =
entry)
 #endif
=20
 #ifdef CONFIG_MEMORY_FAILURE
+
+extern atomic_long_t num_poisoned_pages __read_mostly;
+
 /*
  * Support for hardware poisoned pages
  */
@@ -177,6 +180,26 @@ static inline int is_hwpoison_entry(swp_entry_t entry)
 {
 	return swp_type(entry) =3D=3D SWP_HWPOISON;
 }
+
+static inline void num_poisoned_pages_inc(void)
+{
+	atomic_long_inc(&num_poisoned_pages);
+}
+
+static inline void num_poisoned_pages_dec(void)
+{
+	atomic_long_dec(&num_poisoned_pages);
+}
+
+static inline void num_poisoned_pages_add(long num)
+{
+	atomic_long_add(num, &num_poisoned_pages);
+}
+
+static inline void num_poisoned_pages_sub(long num)
+{
+	atomic_long_sub(num, &num_poisoned_pages);
+}
 #else
=20
 static inline swp_entry_t make_hwpoison_entry(struct page *page)
diff --git mmotm-2015-08-13-15-29.orig/mm/memory-failure.c mmotm-2015-08-13=
-15-29/mm/memory-failure.c
index a3d9c3946b36..ac3056c6fe9f 100644
--- mmotm-2015-08-13-15-29.orig/mm/memory-failure.c
+++ mmotm-2015-08-13-15-29/mm/memory-failure.c
@@ -1109,7 +1109,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 		nr_pages =3D 1 << compound_order(hpage);
 	else /* normal page or thp */
 		nr_pages =3D 1;
-	atomic_long_add(nr_pages, &num_poisoned_pages);
+	num_poisoned_pages_add(nr_pages);
=20
 	/*
 	 * We need/can do nothing about count=3D0 pages.
@@ -1137,7 +1137,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 			if (PageHWPoison(hpage)) {
 				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
 				    || (p !=3D hpage && TestSetPageHWPoison(hpage))) {
-					atomic_long_sub(nr_pages, &num_poisoned_pages);
+					num_poisoned_pages_sub(nr_pages);
 					unlock_page(hpage);
 					return 0;
 				}
@@ -1161,7 +1161,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 			else
 				pr_err("MCE: %#lx: thp split failed\n", pfn);
 			if (TestClearPageHWPoison(p))
-				atomic_long_sub(nr_pages, &num_poisoned_pages);
+				num_poisoned_pages_sub(nr_pages);
 			put_hwpoison_page(p);
 			return -EBUSY;
 		}
@@ -1221,14 +1221,14 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 	 */
 	if (!PageHWPoison(p)) {
 		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
-		atomic_long_sub(nr_pages, &num_poisoned_pages);
+		num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
 		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
-			atomic_long_sub(nr_pages, &num_poisoned_pages);
+			num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
 		return 0;
@@ -1457,7 +1457,7 @@ int unpoison_memory(unsigned long pfn)
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
-			atomic_long_dec(&num_poisoned_pages);
+			num_poisoned_pages_dec();
 		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
 		return 0;
 	}
@@ -1471,7 +1471,7 @@ int unpoison_memory(unsigned long pfn)
 	 */
 	if (TestClearPageHWPoison(page)) {
 		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
-		atomic_long_sub(nr_pages, &num_poisoned_pages);
+		num_poisoned_pages_sub(nr_pages);
 		freeit =3D 1;
 		if (PageHuge(page))
 			clear_page_hwpoison_huge_page(page);
@@ -1607,11 +1607,10 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
 			dequeue_hwpoisoned_huge_page(hpage);
-			atomic_long_add(1 << compound_order(hpage),
-					&num_poisoned_pages);
+			num_poisoned_pages_add(1 << compound_order(hpage));
 		} else {
 			SetPageHWPoison(page);
-			atomic_long_inc(&num_poisoned_pages);
+			num_poisoned_pages_inc();
 		}
 	}
 	return ret;
@@ -1650,7 +1649,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 		put_hwpoison_page(page);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		SetPageHWPoison(page);
-		atomic_long_inc(&num_poisoned_pages);
+		num_poisoned_pages_inc();
 		return 0;
 	}
=20
@@ -1671,7 +1670,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		if (!TestSetPageHWPoison(page))
-			atomic_long_inc(&num_poisoned_pages);
+			num_poisoned_pages_dec();
 		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
@@ -1687,7 +1686,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 			if (ret > 0)
 				ret =3D -EIO;
 			if (TestClearPageHWPoison(page))
-				atomic_long_dec(&num_poisoned_pages);
+				num_poisoned_pages_dec();
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %=
lx\n",
@@ -1753,11 +1752,10 @@ int soft_offline_page(struct page *page, int flags)
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
 			if (!dequeue_hwpoisoned_huge_page(hpage))
-				atomic_long_add(1 << compound_order(hpage),
-					&num_poisoned_pages);
+				num_poisoned_pages_add(1 << compound_order(hpage));
 		} else {
 			if (!TestSetPageHWPoison(page))
-				atomic_long_inc(&num_poisoned_pages);
+				num_poisoned_pages_inc();
 		}
 	}
 	return ret;
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
