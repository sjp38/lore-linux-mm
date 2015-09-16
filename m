Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 66A7C6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 02:30:43 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so200239026pac.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 23:30:43 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id dh2si9170648pbb.114.2015.09.15.23.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 23:30:42 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hwpoison: ratelimit messages from unpoison_memory()
Date: Wed, 16 Sep 2015 06:28:12 +0000
Message-ID: <1442384889-12087-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Wanpeng Li <wanpeng.li@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently kernel prints out results of every single unpoison event, which i=
s
not necessary because unpoison is purely a testing feature and testers can =
get
little or no information from lots of lines of unpoison log storm. So this
patch ratelimits printk in unpoison_memory().

This patch introduces a file local ratelimit_state, which adds 64 bytes to
memory-failure.o. If we apply pr_info_ratelimited() for 8 callsite below, 2=
56
bytes is added, so it's a win.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git v4.3-rc1/mm/memory-failure.c v4.3-rc1_patched/mm/memory-failure.=
c
index 95882692e747..16a0ec385320 100644
--- v4.3-rc1/mm/memory-failure.c
+++ v4.3-rc1_patched/mm/memory-failure.c
@@ -56,6 +56,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
+#include <linux/ratelimit.h>
 #include "internal.h"
 #include "ras/ras_event.h"
=20
@@ -1403,6 +1404,12 @@ static int __init memory_failure_init(void)
 }
 core_initcall(memory_failure_init);
=20
+#define unpoison_pr_info(fmt, pfn, rs)			\
+({							\
+	if (__ratelimit(rs))				\
+		pr_info(fmt, pfn);			\
+})
+
 /**
  * unpoison_memory - Unpoison a previously poisoned page
  * @pfn: Page number of the to be unpoisoned page
@@ -1421,6 +1428,8 @@ int unpoison_memory(unsigned long pfn)
 	struct page *p;
 	int freeit =3D 0;
 	unsigned int nr_pages;
+	static DEFINE_RATELIMIT_STATE(unpoison_rs, DEFAULT_RATELIMIT_INTERVAL,
+					DEFAULT_RATELIMIT_BURST);
=20
 	if (!pfn_valid(pfn))
 		return -ENXIO;
@@ -1429,23 +1438,26 @@ int unpoison_memory(unsigned long pfn)
 	page =3D compound_head(p);
=20
 	if (!PageHWPoison(p)) {
-		pr_info("MCE: Page was already unpoisoned %#lx\n", pfn);
+		unpoison_pr_info("MCE: Page was already unpoisoned %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
 	if (page_count(page) > 1) {
-		pr_info("MCE: Someone grabs the hwpoison page %#lx\n", pfn);
+		unpoison_pr_info("MCE: Someone grabs the hwpoison page %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
 	if (page_mapped(page)) {
-		pr_info("MCE: Someone maps the hwpoison page %#lx\n", pfn);
+		unpoison_pr_info("MCE: Someone maps the hwpoison page %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
 	if (page_mapping(page)) {
-		pr_info("MCE: the hwpoison page has non-NULL mapping %#lx\n",
-			pfn);
+		unpoison_pr_info("MCE: the hwpoison page has non-NULL mapping %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
@@ -1455,7 +1467,8 @@ int unpoison_memory(unsigned long pfn)
 	 * In such case, we yield to memory_failure() and make unpoison fail.
 	 */
 	if (!PageHuge(page) && PageTransHuge(page)) {
-		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
+		unpoison_pr_info("MCE: Memory failure is now running on %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
@@ -1469,12 +1482,14 @@ int unpoison_memory(unsigned long pfn)
 		 * to the end.
 		 */
 		if (PageHuge(page)) {
-			pr_info("MCE: Memory failure is now running on free hugepage %#lx\n", p=
fn);
+			unpoison_pr_info("MCE: Memory failure is now running on free hugepage %=
#lx\n",
+					 pfn, &unpoison_rs);
 			return 0;
 		}
 		if (TestClearPageHWPoison(p))
 			num_poisoned_pages_dec();
-		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
+		unpoison_pr_info("MCE: Software-unpoisoned free page %#lx\n",
+				 pfn, &unpoison_rs);
 		return 0;
 	}
=20
@@ -1486,7 +1501,8 @@ int unpoison_memory(unsigned long pfn)
 	 * the free buddy page pool.
 	 */
 	if (TestClearPageHWPoison(page)) {
-		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
+		unpoison_pr_info("MCE: Software-unpoisoned page %#lx\n",
+				 pfn, &unpoison_rs);
 		num_poisoned_pages_sub(nr_pages);
 		freeit =3D 1;
 		if (PageHuge(page))
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
