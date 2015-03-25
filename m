Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B8F576B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:41:50 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so42418324pdb.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:41:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rs11si5520466pab.141.2015.03.25.15.41.49
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 15:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: avoid tail page refcounting on non-THP compound pages
Date: Thu, 26 Mar 2015 00:41:15 +0200
Message-Id: <1427323275-114866-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

THP uses tail page refcounting to be able to split huge page at any
time. Tail page refcounting is not needed for rest users of compound
pages and it's harmful because of overhead.

We try to exclude non-THP pages from tail page refcounting using
__compound_tail_refcounted() check. It excludes most common non-THP
compound pages: SL*B and hugetlb, but it doesn't catch rest of
__GFP_COMP users -- drivers.

And it's not only about overhead.

Drivers might want to use compound pages to get refcounting semantics
suitable for mapping high-order pages to userspace. But tail page
refcounting breaks it.

Tail page refcounting uses ->_mapcount in tail pages to store GUP pins
on them. It means GUP pins would affect page_mapcount() for tail pages.
It's not a problem for THP, because it never maps tail pages. But unlike
THP, drivers map parts of compound pages with PTEs and it makes
page_mapcount() be called for tail pages.

In particular, GUP pins would shift PSS up and affect /proc/kpagecount
for such pages. But, I'm not aware about anything which can lead to
crash or other serious misbehaviour.

Since currently all THP pages are anonymous and all drivers pages are
not, we can fix the __compound_tail_refcounted() check by requiring
PageAnon() to enable tail page refcounting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4a3a38522ab4..16fe322b66ea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -456,7 +456,7 @@ static inline int page_count(struct page *page)
 
 static inline bool __compound_tail_refcounted(struct page *page)
 {
-	return !PageSlab(page) && !PageHeadHuge(page);
+	return PageAnon(page) && !PageSlab(page) && !PageHeadHuge(page);
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
