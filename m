Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 80B95680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 22:10:54 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id n128so54901494pfn.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:54 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id b22si32767161pfj.52.2016.01.11.19.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 19:10:53 -0800 (PST)
Received: by mail-pa0-x244.google.com with SMTP id pv5so26274990pac.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:10:53 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 2/2] mm: soft-offline: exit with failure for non anonymous thp
Date: Tue, 12 Jan 2016 12:10:45 +0900
Message-Id: <1452568245-10412-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20160108123300.843d370916d3248be297d831@linux-foundation.org>
 <1452568245-10412-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

Currently memory_failure() doesn't handle non anonymous thp case, because we
can hardly expect the error handling to be successful, and it can just hit
some corner case which results in BUG_ON or something severe like that.
This is also the case for soft offline code, so let's make it in the same way.

Orignal code has a MF_COUNT_INCREASED check before put_hwpoison_page(), but
it's unnecessary because get_any_page() is already called when running on
this code, which takes a refcount of the target page regardress of the flag.
So this patch also removes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- rebased to next-20160111
---
 mm/memory-failure.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git next-20160111/mm/memory-failure.c next-20160111_patched/mm/memory-failure.c
index 2015c9a..6a2f290 100644
--- next-20160111/mm/memory-failure.c
+++ next-20160111_patched/mm/memory-failure.c
@@ -1691,16 +1691,16 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
 		lock_page(hpage);
-		ret = split_huge_page(hpage);
-		unlock_page(hpage);
-		if (unlikely(ret || PageTransCompound(page) ||
-			     !PageAnon(page))) {
-			pr_info("soft offline: %#lx: failed to split THP\n",
-				page_to_pfn(page));
-			if (flags & MF_COUNT_INCREASED)
-				put_hwpoison_page(hpage);
+		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
+			unlock_page(hpage);
+			if (!PageAnon(hpage))
+				pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
+			else
+				pr_info("soft offline: %#lx: thp split failed\n", pfn);
+			put_hwpoison_page(hpage);
 			return -EBUSY;
 		}
+		unlock_page(hpage);
 		get_hwpoison_page(page);
 		put_hwpoison_page(hpage);
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
