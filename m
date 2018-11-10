Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E11A6B077A
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 03:50:57 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id a188-v6so2483139oih.0
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 00:50:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t20sor5854402oti.184.2018.11.10.00.50.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 00:50:56 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v2 1/6] mm/gup: finish consolidating error handling
Date: Sat, 10 Nov 2018 00:50:36 -0800
Message-Id: <20181110085041.10071-2-jhubbard@nvidia.com>
In-Reply-To: <20181110085041.10071-1-jhubbard@nvidia.com>
References: <20181110085041.10071-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

From: John Hubbard <jhubbard@nvidia.com>

An upcoming patch wants to be able to operate on each page that
get_user_pages has retrieved. In order to do that, it's best to
have a common exit point from the routine. Most of this has been
taken care of by commit df06b37ffe5a4 ("mm/gup: cache dev_pagemap while
pinning pages"), but there was one case remaining.

Also, there was still an unnecessary shadow declaration (with a
different type) of the "ret" variable, which this commit removes.

Cc: Keith Busch <keith.busch@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f76e77a2d34b..55a41dee0340 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -696,12 +696,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
