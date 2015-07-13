Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D6BE26B0255
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:54:19 -0400 (EDT)
Received: by pacan13 with SMTP id an13so14165828pac.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:54:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dn2si27870766pdb.54.2015.07.13.03.54.16
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:54:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/5] mm, madvise: use vma_is_anonymous() to check for anon VMA
Date: Mon, 13 Jul 2015 13:54:11 +0300
Message-Id: <1436784852-144369-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>

!vma->vm_file is not reliable to detect anon VMA, because not all
drivers bother set it. Let's use vma_is_anonymous() instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 70ce0d425d72..a4fae076f61d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -393,7 +393,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* MADV_FREE works for only anon vma at the moment */
-	if (vma->vm_file)
+	if (!vma_is_anonymous(vma))
 		return -EINVAL;
 
 	start = max(vma->vm_start, start_addr);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
