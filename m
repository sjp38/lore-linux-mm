Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 143826B0035
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 18:12:34 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id x3so12713329qcv.29
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
Received: from mail-qg0-x249.google.com (mail-qg0-x249.google.com [2607:f8b0:400d:c04::249])
        by mx.google.com with ESMTPS id e10si46977529qaf.23.2014.08.23.15.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
Received: by mail-qg0-f73.google.com with SMTP id i50so954765qgf.2
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v2 2/3] mm: mprotect: preserve special page protection bits
Date: Sat, 23 Aug 2014 18:12:00 -0400
Message-Id: <1408831921-10168-3-git-send-email-pfeiner@google.com>
In-Reply-To: <1408831921-10168-1-git-send-email-pfeiner@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

We don't want to zap special page protection bits on mprotect.
Analogous to the bug fixed in c9d0bf241451a3ab7d02e1652c22b80cd7d93e8f
where vm_page_prot bits set by drivers were zapped when write
notifications were enabled on new VMAs.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 mm/mprotect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557..1c1afd4 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -324,7 +324,7 @@ success:
 					  vm_get_page_prot(newflags));
 
 	if (vma_wants_writenotify(vma)) {
-		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
+		vma_enable_writenotify(vma);
 		dirty_accountable = 1;
 	}
 
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
