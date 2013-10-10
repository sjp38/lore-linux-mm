Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ADE416B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:12:49 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so2837761pdj.3
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:12:49 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: hugetlb: initialize PG_reserved for tail pages of gigantig compound pages
Date: Thu, 10 Oct 2013 18:12:41 +0200
Message-Id: <1381421561-10203-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1381421561-10203-1-git-send-email-aarcange@redhat.com>
References: <1381421561-10203-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gleb Natapov <gleb@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

11feeb498086a3a5907b8148bdf1786a9b18fc55 introduced a memory leak when
KVM is run on gigantic compound pages.

11feeb498086a3a5907b8148bdf1786a9b18fc55 depends on the assumption
that PG_reserved is identical for all head and tail pages of a
compound page. So that if get_user_pages returns a tail page, we don't
need to check the head page in order to know if we deal with a
reserved page that requires different refcounting.

The assumption that PG_reserved is the same for head and tail pages is
certainly correct for THP and regular hugepages, but gigantic
hugepages allocated through bootmem don't clear the PG_reserved on the
tail pages (the clearing of PG_reserved is done later only if the
gigantic hugepage is freed).

This patch corrects the gigantic compound page initialization so that
we can retain the optimization in
11feeb498086a3a5907b8148bdf1786a9b18fc55. The cacheline was already
modified in order to set PG_tail so this won't affect the boot time of
large memory systems.

Reported-by: andy123 <ajs124.ajs124@gmail.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b49579c..315450e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -695,8 +695,24 @@ static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 	/* we rely on prep_new_huge_page to set the destructor */
 	set_compound_order(page, order);
 	__SetPageHead(page);
+	__ClearPageReserved(page);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
 		__SetPageTail(p);
+		/*
+		 * For gigantic hugepages allocated through bootmem at
+		 * boot, it's safer to be consistent with the
+		 * not-gigantic hugepages and to clear the PG_reserved
+		 * bit from all tail pages too. Otherwse drivers using
+		 * get_user_pages() to access tail pages, may get the
+		 * reference counting wrong if they see the
+		 * PG_reserved bitflag set on a tail page (despite the
+		 * head page didn't have PG_reserved set). Enforcing
+		 * this consistency between head and tail pages,
+		 * allows drivers to optimize away a check on the head
+		 * page when they need know if put_page is needed after
+		 * get_user_pages() or not.
+		 */
+		__ClearPageReserved(p);
 		set_page_count(p, 0);
 		p->first_page = page;
 	}
@@ -1329,9 +1345,9 @@ static void __init gather_bootmem_prealloc(void)
 #else
 		page = virt_to_page(m);
 #endif
-		__ClearPageReserved(page);
 		WARN_ON(page_count(page) != 1);
 		prep_compound_huge_page(page, h->order);
+		WARN_ON(PageReserved(page));
 		prep_new_huge_page(h, page, page_to_nid(page));
 		/*
 		 * If we had gigantic hugepages allocated at boot time, we need

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
