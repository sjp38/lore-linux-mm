Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01D3D6B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:07:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so17574622pga.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:07:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x66si2178554pfa.407.2017.10.31.11.07.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 11:07:57 -0700 (PDT)
Subject: [PATCH] x86, mm: make alternatives code do stronger TLB flush
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 11:07:57 -0700
Message-Id: <20171031180757.8B5DA496@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, luto@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

local_flush_tlb() does a CR3 write.  But, that kind of TLB flush is
not guaranteed to invalidate global pages.  The entire kernel is
mapped with global pages.

Also, now that we have PCIDs, local_flush_tlb() will only flush the
*current* PCID.  It would not flush the entries for all PCIDs.
At the moment, this is a moot point because all kernel pages are
_PAGE_GLOBAL which do not really *have* a particular PCID.

Use the stronger __flush_tlb_all() which does flush global pages.

This was found because of a warning I added to __native_flush_tlb()
to look for calls to it when PCIDs are enabled.  This patch does
not fix any bug known to be hit in practice.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: x86@kernel.org
Cc: Andy Lutomirski <luto@kernel.org>
---

 b/arch/x86/kernel/alternative.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN arch/x86/kernel/alternative.c~x86-mm-text-poke-misses-global-pages arch/x86/kernel/alternative.c
--- a/arch/x86/kernel/alternative.c~x86-mm-text-poke-misses-global-pages	2017-10-31 10:28:44.306557256 -0700
+++ b/arch/x86/kernel/alternative.c	2017-10-31 10:28:44.309557393 -0700
@@ -722,7 +722,8 @@ void *text_poke(void *addr, const void *
 	clear_fixmap(FIX_TEXT_POKE0);
 	if (pages[1])
 		clear_fixmap(FIX_TEXT_POKE1);
-	local_flush_tlb();
+	/* Make sure to flush Global pages: */
+	__flush_tlb_all();
 	sync_core();
 	/* Could also do a CLFLUSH here to speed up CPU recovery; but
 	   that causes hangs on some VIA CPUs. */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
