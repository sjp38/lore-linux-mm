Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7386B029B
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 20:53:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l66so31362075pfl.7
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 17:53:02 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 1si27433648pgr.30.2016.10.31.17.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 17:53:01 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id a136so6653516pfa.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 17:53:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hwpoison: fix thp split handling in memory_failure()
Date: Tue,  1 Nov 2016 09:52:57 +0900
Message-Id: <1477961577-7183-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

When memory_failure() runs on a thp tail page after pmd is split, we trigger
the following VM_BUG_ON_PAGE():

  [  619.550520] page:ffffd7cd819b0040 count:0 mapcount:0 mapping:         (null) index:0x1
  [  619.555486] flags: 0x1fffc000400000(hwpoison)
  [  619.556408] page dumped because: VM_BUG_ON_PAGE(!page_count(p))
  [  619.558998] ------------[ cut here ]------------
  [  619.561388] kernel BUG at /src/linux-dev/mm/memory-failure.c:1132!

memory_failure() passed refcount and page lock from tail page to head page,
which is not needed because we can pass any subpage to split_huge_page().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Fixes: 61f5d698cc97 ("mm: re-enable THP")
Cc: stable@vger.kernel.org # 4.5+
---
 mm/memory-failure.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git v4.8-rc8-mmotm-2016-09-27-16-08/mm/memory-failure.c v4.8-rc8-mmotm-2016-09-27-16-08_patched/mm/memory-failure.c
index de88f33..19e796d 100644
--- v4.8-rc8-mmotm-2016-09-27-16-08/mm/memory-failure.c
+++ v4.8-rc8-mmotm-2016-09-27-16-08_patched/mm/memory-failure.c
@@ -1112,10 +1112,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 
 	if (!PageHuge(p) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
+		lock_page(p);
+		if (!PageAnon(p) || unlikely(split_huge_page(p))) {
+			unlock_page(p);
+			if (!PageAnon(p))
 				pr_err("Memory failure: %#lx: non anonymous thp\n",
 					pfn);
 			else
@@ -1126,9 +1126,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			put_hwpoison_page(p);
 			return -EBUSY;
 		}
-		unlock_page(hpage);
-		get_hwpoison_page(p);
-		put_hwpoison_page(hpage);
+		unlock_page(p);
 		VM_BUG_ON_PAGE(!page_count(p), p);
 		hpage = compound_head(p);
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
