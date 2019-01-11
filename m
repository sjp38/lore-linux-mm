Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0658E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 22:40:40 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id y86so253446ita.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:40:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor484861jaa.13.2019.01.10.19.40.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 19:40:39 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] mm/gup: fix gup_pmd_range() for dax
Date: Thu, 10 Jan 2019 20:40:33 -0700
Message-Id: <20190111034033.601-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Keith Busch <keith.busch@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Wei Yang <richard.weiyang@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Yu Zhao <yuzhao@google.com>

For dax pmd, pmd_trans_huge() returns false but pmd_huge() returns
true on x86. So the function works as long as hugetlb is configured.
However, dax doesn't depend on hugetlb.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e2eb22..75029649baca 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1674,7 +1674,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (!pmd_present(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.20.1.97.g81188d93c3-goog
