Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 108256B0089
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:18:56 -0400 (EDT)
Received: from localhost.localdomain ([127.0.0.1]:32878 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6822972Ab3EVKSyeeABq (ORCPT <rfc822;linux-mm@kvack.org>);
        Wed, 22 May 2013 12:18:54 +0200
Date: Wed, 22 May 2013 12:18:47 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] mm: Fix warning
Message-ID: <20130522101847.GB10769@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, Eunbong Song <eunb.song@samsung.com>

virt_to_page() is typically implemented as a macro containing a cast so
it'll accept both pointers and unsigned long without causing a warning.
MIPS virt_to_page() uses virt_to_phys which is a function so passing an
unsigned long will cause a warning:

  CC      mm/page_alloc.o
/home/ralf/src/linux/linux-mips/mm/page_alloc.c: In function a??free_reserved_areaa??:
/home/ralf/src/linux/linux-mips/mm/page_alloc.c:5161:3: warning: passing argument 1 of a??virt_to_physa?? makes pointer from integer without a cast [enabled by default]
In file included from /home/ralf/src/linux/linux-mips/arch/mips/include/asm/page.h:153:0,
                 from /home/ralf/src/linux/linux-mips/include/linux/mmzone.h:20,
                 from /home/ralf/src/linux/linux-mips/include/linux/gfp.h:4,
                 from /home/ralf/src/linux/linux-mips/include/linux/mm.h:8,
                 from /home/ralf/src/linux/linux-mips/mm/page_alloc.c:18:
/home/ralf/src/linux/linux-mips/arch/mips/include/asm/io.h:119:100: note: expected a??const volatile void *a?? but argument is of type a??long unsigned inta??

All others users of virt_to_page() in mm/ are passing a void *.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Reported-by: Eunbong Song <eunb.song@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-mips@linux-mips.org
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 98cbdf6..378a15b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5158,7 +5158,7 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
 		if (poison)
 			memset((void *)pos, poison, PAGE_SIZE);
-		free_reserved_page(virt_to_page(pos));
+		free_reserved_page(virt_to_page((void *)pos));
 	}
 
 	if (pages && s)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
