Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBD96B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:44:24 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so51213pbc.6
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 01:44:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.129])
        by mx.google.com with SMTP id yj7si2975977pab.141.2013.11.18.01.44.21
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 01:44:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] sparc64: fix build regession
Date: Mon, 18 Nov 2013 11:44:09 +0200
Message-Id: <1384767850-2574-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Commit ea1e7ed33708 triggers build regression on sparc64.

include/linux/mm.h:1391:2: error: implicit declaration of function 'pgtable_cache_init' [-Werror=implicit-function-declaration]
arch/sparc/include/asm/pgtable_64.h:978:13: error: conflicting types for 'pgtable_cache_init' [-Werror]

It happens due headers include loop:

<linux/mm.h> -> <asm/pgtable.h> -> <asm/pgtable_64.h> ->
	<asm/tlbflush.h> -> <asm/tlbflush_64.h> -> <linux/mm.h>

Let's drop <linux/mm.h> include from asm/tlbflush_64.h.
Build tested with allmodconfig.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/sparc/include/asm/tlbflush_64.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/sparc/include/asm/tlbflush_64.h b/arch/sparc/include/asm/tlbflush_64.h
index f0d6a9700f4c..3c3c89f52643 100644
--- a/arch/sparc/include/asm/tlbflush_64.h
+++ b/arch/sparc/include/asm/tlbflush_64.h
@@ -1,7 +1,6 @@
 #ifndef _SPARC64_TLBFLUSH_H
 #define _SPARC64_TLBFLUSH_H
 
-#include <linux/mm.h>
 #include <asm/mmu_context.h>
 
 /* TSB flush operations. */
-- 
1.8.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
