Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id CB38A2802C2
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 21:43:00 -0400 (EDT)
Received: by obbgp5 with SMTP id gp5so38207358obb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:43:00 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id w12si5068821oiw.66.2015.07.15.18.42.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 18:43:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 3/4] mm/memory-failure: give up error handling for
 non-tail-refcounted thp
Date: Thu, 16 Jul 2015 01:41:56 +0000
Message-ID: <1437010894-10262-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

"non anonymous thp" case is still racy with freeing thp, which causes panic
due to put_page() for refcount-0 page. It seems that closing up this race
might be hard (and/or not worth doing,) so let's give up the error handling
for this case.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git v4.2-rc2.orig/mm/memory-failure.c v4.2-rc2/mm/memory-failure.c
index f72d2fad0b90..421d7c9b30f4 100644
--- v4.2-rc2.orig/mm/memory-failure.c
+++ v4.2-rc2/mm/memory-failure.c
@@ -909,6 +909,15 @@ int get_hwpoison_page(struct page *page)
 	 * directly for tail pages.
 	 */
 	if (PageTransHuge(head)) {
+		/*
+		 * Non anonymous thp exists only in allocation/free time. We
+		 * can't handle such a case correctly, so let's give it up.
+		 * This should be better than triggering BUG_ON when kernel
+		 * tries to touch a "partially handled" page.
+		 */
+		if (!PageAnon(head))
+			return 0;
+
 		if (get_page_unless_zero(head)) {
 			if (PageTail(page))
 				get_page(page);
@@ -1134,15 +1143,6 @@ int memory_failure(unsigned long pfn, int trapno, in=
t flags)
 	}
=20
 	if (!PageHuge(p) && PageTransHuge(hpage)) {
-		if (!PageAnon(hpage)) {
-			pr_err("MCE: %#lx: non anonymous thp\n", pfn);
-			if (TestClearPageHWPoison(p))
-				atomic_long_sub(nr_pages, &num_poisoned_pages);
-			put_page(p);
-			if (p !=3D hpage)
-				put_page(hpage);
-			return -EBUSY;
-		}
 		if (unlikely(split_huge_page(hpage))) {
 			pr_err("MCE: %#lx: thp split failed\n", pfn);
 			if (TestClearPageHWPoison(p))
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
