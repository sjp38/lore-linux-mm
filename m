Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 75B7F6B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:49:19 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so37390188pdb.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:49:19 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id u3si8109500pde.161.2015.07.30.23.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 23:49:18 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 4/5] mm: check __PG_HWPOISON separately from
 PAGE_FLAGS_CHECK_AT_*
Date: Fri, 31 Jul 2015 06:46:13 +0000
Message-ID: <1438325105-10059-5-git-send-email-n-horiguchi@ah.jp.nec.com>
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

The race condition addressed in commit add05cecef80 ("mm: soft-offline: don=
't
free target page in successful page migration") was not closed completely,
because that can happen not only for soft-offline, but also for hard-offlin=
e.
Consider that a slab page is about to be freed into buddy pool, and then an
uncorrected memory error hits the page just after entering __free_one_page(=
),
then VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP) is triggered,
despite the fact that it's not necessary because the data on the affected
page is not consumed.

To solve it, this patch drops __PG_HWPOISON from page flag checks at
allocation/free time. I think it's justified because __PG_HWPOISON flags is
defined to prevent the page from being reused, and setting it outside the
page's alloc-free cycle is a designed behavior (not a bug.)

For recent months, I was annoyed about BUG_ON when soft-offlined page remai=
ns
on lru cache list for a while, which is avoided by calling put_page() inste=
ad
of putback_lru_page() in page migration's success path. This means that thi=
s
patch reverts a major change from commit add05cecef80 about the new refcoun=
ting
rule of soft-offlined pages, so "reuse window" revives. This will be closed
by a subsequent patch.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
v1 -> v2:
- call put_page() when migration succeeded in reason =3D=3D MR_MEMORY_FAILU=
RE
- refrain from reviving "reuse prevention" by MIGRATE_ISOLATE flag
---
 include/linux/page-flags.h | 10 +++++++---
 mm/huge_memory.c           |  7 +------
 mm/migrate.c               |  5 ++++-
 mm/page_alloc.c            |  4 ++++
 4 files changed, 16 insertions(+), 10 deletions(-)

diff --git v4.2-rc4.orig/include/linux/page-flags.h v4.2-rc4/include/linux/=
page-flags.h
index f34e040b34e9..41c93844fb1d 100644
--- v4.2-rc4.orig/include/linux/page-flags.h
+++ v4.2-rc4/include/linux/page-flags.h
@@ -631,15 +631,19 @@ static inline void ClearPageSlabPfmemalloc(struct pag=
e *page)
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 1 << PG_unevictable | __PG_MLOCKED | \
 	 __PG_COMPOUND_LOCK)
=20
 /*
  * Flags checked when a page is prepped for return by the page allocator.
- * Pages being prepped should not have any flags set.  It they are set,
+ * Pages being prepped should not have these flags set.  It they are set,
  * there has been a kernel bug or struct page corruption.
+ *
+ * __PG_HWPOISON is exceptional because it needs to be kept beyond page's
+ * alloc-free cycle to prevent from reusing the page.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_CHECK_AT_PREP	\
+	(((1 << NR_PAGEFLAGS) - 1) & ~__PG_HWPOISON)
=20
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
diff --git v4.2-rc4.orig/mm/huge_memory.c v4.2-rc4/mm/huge_memory.c
index c107094f79ba..097c7a4bfbd9 100644
--- v4.2-rc4.orig/mm/huge_memory.c
+++ v4.2-rc4/mm/huge_memory.c
@@ -1676,12 +1676,7 @@ static void __split_huge_page_refcount(struct page *=
page,
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb__after_atomic();
=20
-		/*
-		 * retain hwpoison flag of the poisoned tail page:
-		 *   fix for the unsuitable process killed on Guest Machine(KVM)
-		 *   by the memory-failure.
-		 */
-		page_tail->flags &=3D ~PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON;
+		page_tail->flags &=3D ~PAGE_FLAGS_CHECK_AT_PREP;
 		page_tail->flags |=3D (page->flags &
 				     ((1L << PG_referenced) |
 				      (1L << PG_swapbacked) |
diff --git v4.2-rc4.orig/mm/migrate.c v4.2-rc4/mm/migrate.c
index ee401e4e5ef1..f2415be7d93b 100644
--- v4.2-rc4.orig/mm/migrate.c
+++ v4.2-rc4/mm/migrate.c
@@ -950,7 +950,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_=
new_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (reason !=3D MR_MEMORY_FAILURE)
+		/* Soft-offlined page shouldn't go through lru cache list */
+		if (reason =3D=3D MR_MEMORY_FAILURE)
+			put_page(page);
+		else
 			putback_lru_page(page);
 	}
=20
diff --git v4.2-rc4.orig/mm/page_alloc.c v4.2-rc4/mm/page_alloc.c
index ef19f22b2b7d..775c254648f7 100644
--- v4.2-rc4.orig/mm/page_alloc.c
+++ v4.2-rc4/mm/page_alloc.c
@@ -1285,6 +1285,10 @@ static inline int check_new_page(struct page *page)
 		bad_reason =3D "non-NULL mapping";
 	if (unlikely(atomic_read(&page->_count) !=3D 0))
 		bad_reason =3D "nonzero _count";
+	if (unlikely(page->flags & __PG_HWPOISON)) {
+		bad_reason =3D "HWPoisoned (hardware-corrupted)";
+		bad_flags =3D __PG_HWPOISON;
+	}
 	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
 		bad_reason =3D "PAGE_FLAGS_CHECK_AT_PREP flag set";
 		bad_flags =3D PAGE_FLAGS_CHECK_AT_PREP;
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
