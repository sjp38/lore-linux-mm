Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7562802C2
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 21:42:57 -0400 (EDT)
Received: by obnw1 with SMTP id w1so38161370obn.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:42:57 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id k2si5049588oem.62.2015.07.15.18.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 18:42:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 4/4] mm/memory-failure: check __PG_HWPOISON separately
 from PAGE_FLAGS_CHECK_AT_*
Date: Thu, 16 Jul 2015 01:41:56 +0000
Message-ID: <1437010894-10262-5-git-send-email-n-horiguchi@ah.jp.nec.com>
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
defined to prevent the page from being reused and setting it outside the
page's alloc-free cycle is a designed behavior (not a bug.)

And the patch reverts most of the changes from commit add05cecef80 about
the new refcounting rule of soft-offlined pages, which is no longer necessa=
ry.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/page-flags.h | 10 +++++++---
 mm/huge_memory.c           |  7 +------
 mm/memory-failure.c        |  6 +++++-
 mm/migrate.c               |  9 +++------
 mm/page_alloc.c            |  4 ++++
 5 files changed, 20 insertions(+), 16 deletions(-)

diff --git v4.2-rc2.orig/include/linux/page-flags.h v4.2-rc2/include/linux/=
page-flags.h
index f34e040b34e9..53400f101f2d 100644
--- v4.2-rc2.orig/include/linux/page-flags.h
+++ v4.2-rc2/include/linux/page-flags.h
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
+ * __PG_HWPOISON is exceptional because it need to be kept beyond page's
+ * alloc-free cycle to prevent from reusing the page.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_CHECK_AT_PREP	\
+	(((1 << NR_PAGEFLAGS) - 1) & ~__PG_HWPOISON)
=20
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
diff --git v4.2-rc2.orig/mm/huge_memory.c v4.2-rc2/mm/huge_memory.c
index c107094f79ba..097c7a4bfbd9 100644
--- v4.2-rc2.orig/mm/huge_memory.c
+++ v4.2-rc2/mm/huge_memory.c
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
diff --git v4.2-rc2.orig/mm/memory-failure.c v4.2-rc2/mm/memory-failure.c
index 421d7c9b30f4..755f87e4ec64 100644
--- v4.2-rc2.orig/mm/memory-failure.c
+++ v4.2-rc2/mm/memory-failure.c
@@ -1723,6 +1723,9 @@ int soft_offline_page(struct page *page, int flags)
=20
 	get_online_mems();
=20
+	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
+		set_migratetype_isolate(page, true);
+
 	ret =3D get_any_page(page, pfn, flags);
 	put_online_mems();
 	if (ret > 0) { /* for in-use pages */
@@ -1730,7 +1733,7 @@ int soft_offline_page(struct page *page, int flags)
 			ret =3D soft_offline_huge_page(page, flags);
 		else
 			ret =3D __soft_offline_page(page, flags);
-	} else if (ret =3D=3D 0) { /* for free pages */
+	} else if (ret =3D=3D 0) {
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
 			if (!dequeue_hwpoisoned_huge_page(hpage))
@@ -1741,5 +1744,6 @@ int soft_offline_page(struct page *page, int flags)
 				atomic_long_inc(&num_poisoned_pages);
 		}
 	}
+	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
diff --git v4.2-rc2.orig/mm/migrate.c v4.2-rc2/mm/migrate.c
index ee401e4e5ef1..c37d5772767b 100644
--- v4.2-rc2.orig/mm/migrate.c
+++ v4.2-rc2/mm/migrate.c
@@ -918,8 +918,7 @@ static int __unmap_and_move(struct page *page, struct p=
age *newpage,
 static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				   free_page_t put_new_page,
 				   unsigned long private, struct page *page,
-				   int force, enum migrate_mode mode,
-				   enum migrate_reason reason)
+				   int force, enum migrate_mode mode)
 {
 	int rc =3D 0;
 	int *result =3D NULL;
@@ -950,8 +949,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_n=
ew_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (reason !=3D MR_MEMORY_FAILURE)
-			putback_lru_page(page);
+		putback_lru_page(page);
 	}
=20
 	/*
@@ -1124,8 +1122,7 @@ int migrate_pages(struct list_head *from, new_page_t =
get_new_page,
 						pass > 2, mode);
 			else
 				rc =3D unmap_and_move(get_new_page, put_new_page,
-						private, page, pass > 2, mode,
-						reason);
+						private, page, pass > 2, mode);
=20
 			switch(rc) {
 			case -ENOMEM:
diff --git v4.2-rc2.orig/mm/page_alloc.c v4.2-rc2/mm/page_alloc.c
index 506eac8b38af..e32d58ce5d2f 100644
--- v4.2-rc2.orig/mm/page_alloc.c
+++ v4.2-rc2/mm/page_alloc.c
@@ -1287,6 +1287,10 @@ static inline int check_new_page(struct page *page)
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
