Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 21F8F6B0038
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 04:03:11 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id a141so1733101oig.25
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 01:03:10 -0700 (PDT)
Received: from mail-ob0-x249.google.com (mail-ob0-x249.google.com [2607:f8b0:4003:c01::249])
        by mx.google.com with ESMTPS id ds2si5585093oeb.14.2014.09.20.01.03.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 20 Sep 2014 01:03:10 -0700 (PDT)
Received: by mail-ob0-f201.google.com with SMTP id wm4so685177obc.4
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 01:03:10 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH] mm: softdirty: keep bit when zapping file pte
Date: Sat, 20 Sep 2014 01:03:07 -0700
Message-Id: <1411200187-40896-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 and
9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value of
pte_*mksoft_dirty was being ignored.

To be sure that no other pte/pmd "mk" function return values were
being ignored, I annotated the functions in
arch/x86/include/asm/pgtable.h with __must_check and rebuilt.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index adeac30..fc46934 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1125,7 +1125,7 @@ again:
 						addr) != page->index) {
 				pte_t ptfile = pgoff_to_pte(page->index);
 				if (pte_soft_dirty(ptent))
-					pte_file_mksoft_dirty(ptfile);
+					ptfile = pte_file_mksoft_dirty(ptfile);
 				set_pte_at(mm, addr, pte, ptfile);
 			}
 			if (PageAnon(page))
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
