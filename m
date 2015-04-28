Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB246B0087
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:25:39 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so29091pdb.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:25:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id la15si35362872pab.99.2015.04.28.09.25.38
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 09:25:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: avoid tail page refcounting on non-THP compound pages
Date: Tue, 28 Apr 2015 19:24:58 +0300
Message-Id: <1430238298-80442-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[ kirill.shutemov: re-introduce 8d63d99a5dfb after removing bogus
  VM_BUG_ON_PAGE() in put_unrefcounted_compound_page() ]

THP uses tail page refcounting to be able to split huge pages at any time.
 Tail page refcounting is not needed for other users of compound pages and
it's harmful because of overhead.

We try to exclude non-THP pages from tail page refcounting using
__compound_tail_refcounted() check.  It excludes most common non-THP
compound pages: SL*B and hugetlb, but it doesn't catch rest of __GFP_COMP
users -- drivers.

And it's not only about overhead.

Drivers might want to use compound pages to get refcounting semantics
suitable for mapping high-order pages to userspace.  But tail page
refcounting breaks it.

Tail page refcounting uses ->_mapcount in tail pages to store GUP pins on
them.  It means GUP pins would affect page_mapcount() for tail pages.
It's not a problem for THP, because it never maps tail pages.  But unlike
THP, drivers map parts of compound pages with PTEs and it makes
page_mapcount() be called for tail pages.

In particular, GUP pins would shift PSS up and affect /proc/kpagecount for
such pages.  But, I'm not aware about anything which can lead to crash or
other serious misbehaviour.

Since currently all THP pages are anonymous and all drivers pages are not,
we can fix the __compound_tail_refcounted() check by requiring PageAnon()
to enable tail page refcounting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0755b9fd03a7..8b086070c3a5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -499,7 +499,7 @@ static inline int page_count(struct page *page)
 
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
