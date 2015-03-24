Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 21BCA6B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:58:00 -0400 (EDT)
Received: by wibg7 with SMTP id g7so73999476wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 05:57:59 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id ct6si16054853wib.33.2015.03.24.05.57.57
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 05:57:58 -0700 (PDT)
Date: Tue, 24 Mar 2015 14:57:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 11/24] huge tmpfs: shrinker to migrate and free underused
 holes
Message-ID: <20150324125752.GA4642@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
 <alpine.LSU.2.11.1502202008010.14414@eggly.anvils>
 <550AFFD5.40607@yandex-team.ru>
 <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 22, 2015 at 09:40:02PM -0700, Hugh Dickins wrote:
> (I think Kirill has a problem of that kind in his page_remove_rmap scan).
> 
> It will be interesting to see what Kirill does to maintain the stats
> for huge pagecache: but he will have no difficulty in finding fields
> to store counts, because he's got lots of spare fields in those 511
> tail pages - that's a useful benefit of the compound page, but does
> prevent the tails from being used in ordinary ways.  (I did try using
> team_head[1].team_usage for more, but atomicity needs prevented it.)

The patch below should address the race you pointed, if I've got all
right. Not hugely happy with the change though.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 435c90f59227..a3e6b35520f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -423,8 +423,17 @@ static inline void page_mapcount_reset(struct page *page)
 
 static inline int page_mapcount(struct page *page)
 {
+	int ret;
 	VM_BUG_ON_PAGE(PageSlab(page), page);
-	return atomic_read(&page->_mapcount) + compound_mapcount(page) + 1;
+	ret = atomic_read(&page->_mapcount) + 1;
+	if (compound_mapcount(page)) {
+		/*
+		 * positive compound_mapcount() offsets ->_mapcount by one --
+		 * substract here.
+		*/
+	       ret += compound_mapcount(page) - 1;
+	}
+	return ret;
 }
 
 static inline int page_count(struct page *page)
diff --git a/mm/rmap.c b/mm/rmap.c
index fc6eee4ed476..f4ab976276e7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1066,9 +1066,17 @@ void do_page_add_anon_rmap(struct page *page,
 		 * disabled.
 		 */
 		if (compound) {
+			int i;
 			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+			/*
+			 * While compound_mapcount() is positive we keep *one*
+			 * mapcount reference in all subpages. It's required
+			 * for atomic removal from rmap.
+			 */
+			for (i = 0; i < nr; i++)
+				atomic_set(&page[i]._mapcount, 0);
 		}
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
@@ -1103,10 +1111,19 @@ void page_add_new_anon_rmap(struct page *page,
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
 	if (compound) {
+		int i;
+
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		/*
+		 * While compound_mapcount() is positive we keep *one* mapcount
+		 * reference in all subpages. It's required for atomic removal
+		 * from rmap.
+		 */
+		for (i = 0; i < nr; i++)
+			atomic_set(&page[i]._mapcount, 0);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1174,9 +1191,6 @@ out:
  */
 void page_remove_rmap(struct page *page, bool compound)
 {
-	int nr = compound ? hpage_nr_pages(page) : 1;
-	bool partial_thp_unmap;
-
 	if (!PageAnon(page)) {
 		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
 		page_remove_file_rmap(page);
@@ -1184,10 +1198,20 @@ void page_remove_rmap(struct page *page, bool compound)
 	}
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, compound ?
-			       compound_mapcount_ptr(page) :
-			       &page->_mapcount))
+	if (compound) {
+		int i;
+
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+			return;
+		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		for (i = 0; i < hpage_nr_pages(page); i++)
+			page_remove_rmap(page + i, false);
 		return;
+	} else {
+		if (!atomic_add_negative(-1, &page->_mapcount))
+			return;
+	}
 
 	/* Hugepages are not counted in NR_ANON_PAGES for now. */
 	if (unlikely(PageHuge(page)))
@@ -1198,26 +1222,12 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	if (compound) {
-		int i;
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-		/* The page can be mapped with ptes */
-		for (i = 0; i < hpage_nr_pages(page); i++)
-			if (page_mapcount(page + i))
-				nr--;
-		partial_thp_unmap = nr != hpage_nr_pages(page);
-	} else if (PageTransCompound(page)) {
-		partial_thp_unmap = !compound_mapcount(page);
-	} else
-		partial_thp_unmap = false;
-
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+	__dec_zone_page_state(page, NR_ANON_PAGES);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
-	if (partial_thp_unmap)
+	if (PageTransCompound(page))
 		deferred_split_huge_page(compound_head(page));
 
 	/*
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
