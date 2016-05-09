Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 288D26B007E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 18:26:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 4so403753782pfw.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 15:26:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i1si39913798pfb.54.2016.05.09.15.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 15:26:30 -0700 (PDT)
Date: Mon, 9 May 2016 15:26:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: thp: calculate the mapcount correctly for THP
 pages during WP faults
Message-Id: <20160509152628.391e6845336f0eb05bd213b4@linux-foundation.org>
In-Reply-To: <1462547040-1737-2-git-send-email-aarcange@redhat.com>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
	<1462547040-1737-2-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri,  6 May 2016 17:03:58 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This will provide fully accuracy to the mapcount calculation in the
> write protect faults, so page pinning will not get broken by false
> positive copy-on-writes.
> 
> total_mapcount() isn't the right calculation needed in
> reuse_swap_page(), so this introduces a page_trans_huge_mapcount()
> that is effectively the full accurate return value for page_mapcount()
> if dealing with Transparent Hugepages, however we only use the
> page_trans_huge_mapcount() during COW faults where it strictly needed,
> due to its higher runtime cost.
> 
> This also provide at practical zero cost the total_mapcount
> information which is needed to know if we can still relocate the page
> anon_vma to the local vma. If page_trans_huge_mapcount() returns 1 we
> can reuse the page no matter if it's a pte or a pmd_trans_huge
> triggering the fault, but we can only relocate the page anon_vma to
> the local vma->anon_vma if we're sure it's only this "vma" mapping the
> whole THP physical range.
> 
> Kirill A. Shutemov discovered the problem with moving the page
> anon_vma to the local vma->anon_vma in a previous version of this
> patch and another problem in the way page_move_anon_rmap() was called.

x86_64 allnoconfig:

include/linux/swap.h: In function 'reuse_swap_page':
include/linux/swap.h:518: error: implicit declaration of function 'page_trans_huge_mapcount'
In file included from include/linux/suspend.h:8,
                 from arch/x86/kernel/asm-offsets.c:12:
include/linux/mm.h: At top level:
include/linux/mm.h:509: error: static declaration of 'page_trans_huge_mapcount' follows non-static declaration
include/linux/swap.h:518: note: previous implicit declaration of 'page_trans_huge_mapcount' was here

include ordering I assume.  mm.h vs swap.h.


I did the below (whcih is a bit dumb) but got


mm/built-in.o: In function `do_wp_page':
memory.c:(.text+0x194b3): undefined reference to `page_trans_huge_mapcount'

and gave up.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-thp-calculate-the-mapcount-correctly-for-thp-pages-during-wp-faults-fix

Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: <stable@vger.kernel.org>	[4.5]
Cc: Alex Williamson <alex.williamson@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm.h   |   10 +---------
 include/linux/swap.h |    2 ++
 mm/huge_memory.c     |   12 ++++++++++++
 3 files changed, 15 insertions(+), 9 deletions(-)

--- a/include/linux/mm.h~mm-thp-calculate-the-mapcount-correctly-for-thp-pages-during-wp-faults-fix
+++ a/include/linux/mm.h
@@ -500,21 +500,13 @@ static inline int page_mapcount(struct p
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int total_mapcount(struct page *page);
-int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
 #else
 static inline int total_mapcount(struct page *page)
 {
 	return page_mapcount(page);
 }
-static inline int page_trans_huge_mapcount(struct page *page,
-					   int *total_mapcount)
-{
-	int mapcount = page_mapcount(page);
-	if (total_mapcount)
-		*total_mapcount = mapcount;
-	return mapcount;
-}
 #endif
+int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
 
 static inline struct page *virt_to_head_page(const void *x)
 {
--- a/include/linux/swap.h~mm-thp-calculate-the-mapcount-correctly-for-thp-pages-during-wp-faults-fix
+++ a/include/linux/swap.h
@@ -248,6 +248,8 @@ struct swap_info_struct {
 	struct swap_cluster_info discard_cluster_tail; /* list tail of discard clusters */
 };
 
+int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
+
 /* linux/mm/workingset.c */
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
--- a/mm/huge_memory.c~mm-thp-calculate-the-mapcount-correctly-for-thp-pages-during-wp-faults-fix
+++ a/mm/huge_memory.c
@@ -3217,6 +3217,7 @@ int total_mapcount(struct page *page)
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
  * This calculates accurately how many mappings a transparent hugepage
  * has (unlike page_mapcount() which isn't fully accurate). This full
@@ -3271,6 +3272,17 @@ int page_trans_huge_mapcount(struct page
 	return ret;
 }
 
+#else
+
+int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
+{
+	int mapcount = page_mapcount(page);
+	if (total_mapcount)
+		*total_mapcount = mapcount;
+	return mapcount;
+}
+#endif
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
