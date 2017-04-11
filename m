Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 341646B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 08:51:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p197so366wmg.6
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 05:51:11 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id z45si25969745wrc.42.2017.04.11.05.51.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 05:51:10 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/migrate: check for null vma before dereferencing it
Date: Tue, 11 Apr 2017 13:51:02 +0100
Message-Id: <20170411125102.19497-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

check if vma is null before dereferencing it, this avoiding any
potential null pointer dereferences on vma via the is_vm_hugetlb_page
call or the direct vma->vm_flags reference.

Detected with CoverityScan, CID#1427995 ("Dereference before null check")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/migrate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7958dfa01b16..039f7bc3b9ee 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2757,10 +2757,10 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	/* Sanity check the arguments */
 	start &= PAGE_MASK;
 	end &= PAGE_MASK;
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
-		return -EINVAL;
 	if (!vma || !ops || !src || !dst || start >= end)
 		return -EINVAL;
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
+		return -EINVAL;
 	if (start < vma->vm_start || start >= vma->vm_end)
 		return -EINVAL;
 	if (end <= vma->vm_start || end > vma->vm_end)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
