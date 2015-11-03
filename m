Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6566B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:26:40 -0500 (EST)
Received: by igpw7 with SMTP id w7so70540938igp.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:26:40 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w41si21060095ioi.169.2015.11.03.07.26.39
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 07:26:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] mm: duplicate rmap reference for hugetlb pages as compound
Date: Tue,  3 Nov 2015 17:26:13 +0200
Message-Id: <1446564375-72143-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Naoya noticed that I wrongly duplicate rmap reference for hugetlb pages
in remove_migration_pte() as non-compound. Let's fix this.

The patch can be folded into
	"mm: rework mapcount accounting to enable 4k mapping of THPs"

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 1ae0113559c9..b1034f9c77e7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -165,7 +165,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (PageAnon(new))
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
-			page_dup_rmap(new, false);
+			page_dup_rmap(new, true);
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
