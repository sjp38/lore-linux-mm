Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD779003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:37:04 -0400 (EDT)
Received: by igr7 with SMTP id 7so539697igr.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:37:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p2si36596igh.37.2015.07.23.13.37.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 13:37:03 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:37:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 4/4] mm/memory-failure: check __PG_HWPOISON
 separately from PAGE_FLAGS_CHECK_AT_*
Message-Id: <20150723133702.81a9dacc997b25260c44f42d@linux-foundation.org>
In-Reply-To: <1437010894-10262-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1437010894-10262-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 16 Jul 2015 01:41:56 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> The race condition addressed in commit add05cecef80 ("mm: soft-offline: don't
> free target page in successful page migration") was not closed completely,
> because that can happen not only for soft-offline, but also for hard-offline.
> Consider that a slab page is about to be freed into buddy pool, and then an
> uncorrected memory error hits the page just after entering __free_one_page(),
> then VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP) is triggered,
> despite the fact that it's not necessary because the data on the affected
> page is not consumed.
> 
> To solve it, this patch drops __PG_HWPOISON from page flag checks at
> allocation/free time. I think it's justified because __PG_HWPOISON flags is
> defined to prevent the page from being reused and setting it outside the
> page's alloc-free cycle is a designed behavior (not a bug.)
> 
> And the patch reverts most of the changes from commit add05cecef80 about
> the new refcounting rule of soft-offlined pages, which is no longer necessary.
> 
> ...
>
> --- v4.2-rc2.orig/mm/memory-failure.c
> +++ v4.2-rc2/mm/memory-failure.c
> @@ -1723,6 +1723,9 @@ int soft_offline_page(struct page *page, int flags)
>  
>  	get_online_mems();
>  
> +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		set_migratetype_isolate(page, true);
> +
>  	ret = get_any_page(page, pfn, flags);
>  	put_online_mems();
>  	if (ret > 0) { /* for in-use pages */

This patch gets build-broken by your
mm-page_isolation-make-set-unset_migratetype_isolate-file-local.patch,
which I shall drop.

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: mm, page_isolation: make set/unset_migratetype_isolate() file-local

Nowaday, set/unset_migratetype_isolate() is defined and used only in
mm/page_isolation, so let's limit the scope within the file.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/page-isolation.h |    5 -----
 mm/page_isolation.c            |    5 +++--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff -puN include/linux/page-isolation.h~mm-page_isolation-make-set-unset_migratetype_isolate-file-local include/linux/page-isolation.h
--- a/include/linux/page-isolation.h~mm-page_isolation-make-set-unset_migratetype_isolate-file-local
+++ a/include/linux/page-isolation.h
@@ -65,11 +65,6 @@ undo_isolate_page_range(unsigned long st
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
-/*
- * Internal functions. Changes pageblock's migrate type.
- */
-int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages);
-void unset_migratetype_isolate(struct page *page, unsigned migratetype);
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				int **resultp);
 
diff -puN mm/page_isolation.c~mm-page_isolation-make-set-unset_migratetype_isolate-file-local mm/page_isolation.c
--- a/mm/page_isolation.c~mm-page_isolation-make-set-unset_migratetype_isolate-file-local
+++ a/mm/page_isolation.c
@@ -9,7 +9,8 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 
-int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
+static int set_migratetype_isolate(struct page *page,
+				bool skip_hwpoisoned_pages)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -72,7 +73,7 @@ out:
 	return ret;
 }
 
-void unset_migratetype_isolate(struct page *page, unsigned migratetype)
+static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
