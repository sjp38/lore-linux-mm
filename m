Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D94136B025F
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 02:24:06 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so5929487pff.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 23:24:06 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ut6si18578566pab.68.2016.01.07.23.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 23:24:06 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id ho8so16976334pac.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 23:24:06 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: soft-offline: exit with failure for non anonymous thp
Date: Fri,  8 Jan 2016 16:24:02 +0900
Message-Id: <1452237842-11076-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently memory_failure() doesn't handle non anonymous thp case, because we
can hardly expect the error handling to be successful, and it can just hit
some corner case which results in BUG_ON or something severe like that.
This is also a case for soft offline code, so let's make it in the same way.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git v4.4-rc8/mm/memory-failure.c v4.4-rc8_patched/mm/memory-failure.c
index 750b789..30e9085 100644
--- v4.4-rc8/mm/memory-failure.c
+++ v4.4-rc8_patched/mm/memory-failure.c
@@ -1751,9 +1751,11 @@ int soft_offline_page(struct page *page, int flags)
 		return -EBUSY;
 	}
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
-			pr_info("soft offline: %#lx: failed to split THP\n",
-				pfn);
+		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
+			if (!PageAnon(hpage))
+				pr_info("soft offline: %#lx: non anonymous thp\n", pfn);
+			else
+				pr_info("soft offline: %#lx: thp split failed\n", pfn);
 			if (flags & MF_COUNT_INCREASED)
 				put_hwpoison_page(page);
 			return -EBUSY;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
