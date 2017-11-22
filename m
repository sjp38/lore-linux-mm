Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29B756B026F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:19:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 199so10054059pgg.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:19:34 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p13si13158402plo.133.2017.11.22.04.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 04:19:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm/hugetlb: Fix NULL-pointer dereference on 5-level paging machine
Date: Wed, 22 Nov 2017 15:19:21 +0300
Message-Id: <20171122121921.64822-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

I've made mistake during converting hugetlb code to 5-level paging:
in huge_pte_alloc() we have to use p4d_alloc(), not p4d_offset().
Otherwise it leads to crash -- NULL-pointer dereference in pud_alloc()
if p4d table is not yet allocated.

It only can happen in 5-level paging mode. In 4-level paging mode
p4d_offset() always returns pgd, so we are fine.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")
Cc: <stable@vger.kernel.org> # v4.11+
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2d2ff5e8bf2b..94a4c0b63580 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4617,7 +4617,9 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	p4d = p4d_offset(pgd, addr);
+	p4d = p4d_alloc(mm, pgd, addr);
+	if (!p4d)
+		return NULL;
 	pud = pud_alloc(mm, p4d, addr);
 	if (pud) {
 		if (sz == PUD_SIZE) {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
