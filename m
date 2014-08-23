Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9909D6B0039
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 18:12:35 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so8209440iec.11
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:35 -0700 (PDT)
Received: from mail-ie0-x249.google.com (mail-ie0-x249.google.com [2607:f8b0:4001:c03::249])
        by mx.google.com with ESMTPS id d7si12035676icj.53.2014.08.23.15.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
Received: by mail-ie0-f201.google.com with SMTP id tr6so1163212ieb.2
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v2 3/3] mm: mmap: cleanup code that preserves special vm_page_prot bits
Date: Sat, 23 Aug 2014 18:12:01 -0400
Message-Id: <1408831921-10168-4-git-send-email-pfeiner@google.com>
In-Reply-To: <1408831921-10168-1-git-send-email-pfeiner@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

Replace logic that has been factored out into a utility method.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 mm/mmap.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index abcac32..c18c49a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1618,20 +1618,8 @@ munmap_back:
 			goto free_vma;
 	}
 
-	if (vma_wants_writenotify(vma)) {
-		pgprot_t pprot = vma->vm_page_prot;
-
-		/* Can vma->vm_page_prot have changed??
-		 *
-		 * Answer: Yes, drivers may have changed it in their
-		 *         f_op->mmap method.
-		 *
-		 * Ensures that vmas marked as uncached stay that way.
-		 */
-		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
-		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
-			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	}
+	if (vma_wants_writenotify(vma))
+		vma_enable_writenotify(vma);
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	/* Once vma denies write, undo our temporary denial count */
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
