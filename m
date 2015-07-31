Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB8F6B0258
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:49:23 -0400 (EDT)
Received: by obre1 with SMTP id e1so47637631obr.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:49:23 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id r64si3045772oia.119.2015.07.30.23.49.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 23:49:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 5/5] mm/memory-failure: set PageHWPoison before
 migrate_pages()
Date: Fri, 31 Jul 2015 06:46:14 +0000
Message-ID: <1438325105-10059-6-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1438325105-10059-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Now page freeing code doesn't consider PageHWPoison as a bad page, so by
setting it before completing the page containment, we can prevent the error
page from being reused just after successful page migration.

I added TTU_IGNORE_HWPOISON for try_to_unmap() to make sure that the page
table entry is transformed into migration entry, not to hwpoison entry.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 7 ++++---
 mm/migrate.c        | 3 ++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git v4.2-rc4.orig/mm/memory-failure.c v4.2-rc4/mm/memory-failure.c
index cd985530f102..ea5a93659488 100644
--- v4.2-rc4.orig/mm/memory-failure.c
+++ v4.2-rc4/mm/memory-failure.c
@@ -1659,6 +1659,8 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
+		if (!TestSetPageHWPoison(page))
+			atomic_long_inc(&num_poisoned_pages);
 		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
@@ -1673,9 +1675,8 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret =3D -EIO;
-		} else {
-			if (!TestSetPageHWPoison(page))
-				atomic_long_inc(&num_poisoned_pages);
+			if (TestClearPageHWPoison(page))
+				atomic_long_dec(&num_poisoned_pages);
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %=
lx\n",
diff --git v4.2-rc4.orig/mm/migrate.c v4.2-rc4/mm/migrate.c
index f2415be7d93b..eb4267107d1f 100644
--- v4.2-rc4.orig/mm/migrate.c
+++ v4.2-rc4/mm/migrate.c
@@ -880,7 +880,8 @@ static int __unmap_and_move(struct page *page, struct p=
age *newpage,
 	/* Establish migration ptes or remove ptes */
 	if (page_mapped(page)) {
 		try_to_unmap(page,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
+			TTU_IGNORE_HWPOISON);
 		page_was_mapped =3D 1;
 	}
=20
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
