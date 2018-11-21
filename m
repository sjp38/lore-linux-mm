Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4E96B2513
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:14:09 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m13so6910456pls.15
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 00:14:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor6741833pgo.78.2018.11.21.00.14.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 00:14:08 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH] mm/gup: finish consolidating error handling
Date: Wed, 21 Nov 2018 00:14:02 -0800
Message-Id: <20181121081402.29641-2-jhubbard@nvidia.com>
In-Reply-To: <20181121081402.29641-1-jhubbard@nvidia.com>
References: <20181121081402.29641-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

From: John Hubbard <jhubbard@nvidia.com>

Commit df06b37ffe5a4 ("mm/gup: cache dev_pagemap while pinning pages")
attempted to operate on each page that get_user_pages had retrieved. In
order to do that, it created a common exit point from the routine.
However, one case was missed, which this patch fixes up.

Also, there was still an unnecessary shadow declaration (with a
different type) of the "ret" variable, which this patch removes.

Fixes: df06b37ffe5a4 ("mm/gup: cache dev_pagemap while pinning pages")

Reviewed-by: Keith Busch <keith.busch@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index aa43620a3270..8cb68a50dbdf 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -702,12 +702,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (!vma || start >= vma->vm_end) {
 			vma = find_extend_vma(mm, start);
 			if (!vma && in_gate_area(mm, start)) {
-				int ret;
 				ret = get_gate_page(mm, start & PAGE_MASK,
 						gup_flags, &vma,
 						pages ? &pages[i] : NULL);
 				if (ret)
-					return i ? : ret;
+					goto out;
 				ctx.page_mask = 0;
 				goto next_page;
 			}
-- 
2.19.1
