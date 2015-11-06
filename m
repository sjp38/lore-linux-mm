Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B23182F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 05:29:24 -0500 (EST)
Received: by wmll128 with SMTP id l128so36874121wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:29:23 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id s127si2981338wmb.88.2015.11.06.02.29.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 02:29:22 -0800 (PST)
Received: by wmec201 with SMTP id c201so13993735wme.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:29:22 -0800 (PST)
Date: Fri, 6 Nov 2015 12:29:21 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151106102921.GA6463@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105163211.608eec970de21a95faf6e156@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105163211.608eec970de21a95faf6e156@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>

On Thu, Nov 05, 2015 at 04:32:11PM -0800, Andrew Morton wrote:
> On Tue,  3 Nov 2015 17:26:15 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > I've missed two simlar codepath which need some preparation to work well
> > with reworked THP refcounting.
> > 
> > Both page_referenced() and page_idle_clear_pte_refs_one() assume that
> > THP can only be mapped with PMD, so there's no reason to look on PTEs
> > for PageTransHuge() pages. That's no true anymore: THP can be mapped
> > with PTEs too.
> > 
> > The patch removes PageTransHuge() test from the functions and opencode
> > page table check.
> 
> x86_64 allnoconfig:
> 
> In file included from mm/rmap.c:47:
> include/linux/mm.h: In function 'page_referenced':
> include/linux/mm.h:448: error: call to '__compiletime_assert_448' declared with attribute error: BUILD_BUG failed
> make[1]: *** [mm/rmap.o] Error 1
> make: *** [mm/rmap.o] Error 2
> 
> because
> 
> #else /* CONFIG_TRANSPARENT_HUGEPAGE */
> #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> 
> 
> btw, total_mapcount() is far too large to be inlined and

The patch below is my propsal to fix this.

> page_mapcount() is getting pretty bad too.

Do you want me to uninline slow path (PageCompound())?

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a36f9fa4e4cd..f874d2a1d1a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -432,24 +432,14 @@ static inline int page_mapcount(struct page *page)
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int total_mapcount(struct page *page);
+#else
 static inline int total_mapcount(struct page *page)
 {
-	int i, ret;
-
-	VM_BUG_ON_PAGE(PageTail(page), page);
-
-	if (likely(!PageCompound(page)))
-		return atomic_read(&page->_mapcount) + 1;
-
-	ret = compound_mapcount(page);
-	if (PageHuge(page))
-		return ret;
-	for (i = 0; i < HPAGE_PMD_NR; i++)
-		ret += atomic_read(&page[i]._mapcount) + 1;
-	if (PageDoubleMap(page))
-		ret -= HPAGE_PMD_NR;
-	return ret;
+	return page_mapcount(page);
 }
+#endif
 
 static inline int page_count(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 14cbbad54a3e..287bc009bc10 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3236,6 +3236,25 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	}
 }
 
+int total_mapcount(struct page *page)
+{
+	int i, ret;
+
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	if (likely(!PageCompound(page)))
+		return atomic_read(&page->_mapcount) + 1;
+
+	ret = compound_mapcount(page);
+	if (PageHuge(page))
+		return ret;
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		ret += atomic_read(&page[i]._mapcount) + 1;
+	if (PageDoubleMap(page))
+		ret -= HPAGE_PMD_NR;
+	return ret;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
