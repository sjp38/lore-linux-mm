Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A74D6B0032
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 00:20:34 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so229261497pdb.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 21:20:34 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id nz1si1058209pbb.33.2015.04.20.21.20.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 21:20:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: soft-offline: fix num_poisoned_pages counting on
 concurrent events
Date: Tue, 21 Apr 2015 04:18:28 +0000
Message-ID: <1429589902-2765-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

If multiple soft offline events hit one free page/hugepage concurrently,
soft_offline_page() can handle the free page/hugepage multiple times,
which makes num_poisoned_pages counter increased more than once.
This patch fixes this wrong counting by checking TestSetPageHWPoison for
normal papes and by checking the return value of dequeue_hwpoisoned_huge_pa=
ge()
for hugepages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org  # v3.14+
---
# This problem might happen before 3.14, but it's rare and non-critical,
# so I want this patch to be backported to stable trees only if the patch
# cleanly applies (i.e. v3.14+).
---
 mm/memory-failure.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git v4.0.orig/mm/memory-failure.c v4.0/mm/memory-failure.c
index 2cc1d578144b..72a5224c8084 100644
--- v4.0.orig/mm/memory-failure.c
+++ v4.0/mm/memory-failure.c
@@ -1721,12 +1721,12 @@ int soft_offline_page(struct page *page, int flags)
 	} else if (ret =3D=3D 0) { /* for free pages */
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
-			dequeue_hwpoisoned_huge_page(hpage);
-			atomic_long_add(1 << compound_order(hpage),
+			if (!dequeue_hwpoisoned_huge_page(hpage))
+				atomic_long_add(1 << compound_order(hpage),
 					&num_poisoned_pages);
 		} else {
-			SetPageHWPoison(page);
-			atomic_long_inc(&num_poisoned_pages);
+			if (!TestSetPageHWPoison(page))
+				atomic_long_inc(&num_poisoned_pages);
 		}
 	}
 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
