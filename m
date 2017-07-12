Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC556810BE
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 02:57:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o105so1533866wrc.5
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 23:57:45 -0700 (PDT)
Received: from xavier.telenet-ops.be (xavier.telenet-ops.be. [2a02:1800:120:4::f00:14])
        by mx.google.com with ESMTPS id q13si1390741eda.37.2017.07.11.23.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 23:57:44 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] mm: Mark create_huge_pmd() inline to prevent build failure
Date: Wed, 12 Jul 2017 08:57:40 +0200
Message-Id: <1499842660-10665-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

With gcc 4.1.2:

    mm/memory.o: In function `create_huge_pmd':
    memory.c:(.text+0x93e): undefined reference to `do_huge_pmd_anonymous_page'

Converting transparent_hugepage_enabled() from a macro to a static
inline function reduced the ability of the compiler to remove unused
code.

Fix this by marking create_huge_pmd() inline.

Fixes: 16981d763501c0e0 ("mm: improve readability of transparent_hugepage_enabled()")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Interestingly, create_huge_pmd() is emitted in the assembler output, but
never called.
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index cbb57194687e393a..0e517be91a89e162 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3591,7 +3591,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	return 0;
 }
 
-static int create_huge_pmd(struct vm_fault *vmf)
+static inline int create_huge_pmd(struct vm_fault *vmf)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
