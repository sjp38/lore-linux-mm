Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F21BD6B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:16:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g61-v6so13049221plb.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:16:43 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o128si12227098pga.653.2018.04.17.14.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 14:16:42 -0700 (PDT)
Subject: [PATCH 1/2] x86, pti: fix boot problems from Global-bit setting
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 17 Apr 2018 14:13:02 -0700
Message-Id: <20180417211302.421F6442@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, mceier@gmail.com, aaro.koskinen@nokia.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de


These are _very_ lightly tested.  I'm throwing them out there for
folks are looking for a fix.

---

From: Dave Hansen <dave.hansen@linux.intel.com>

Part of the global bit _setting_ patches also includes clearing the
Global bit when we do not want it.  That is done with
set_memory_nonglobal(), which uses change_page_attr_clear() in
pageattr.c under the covers.  However, it's pretty clear that
change_page_attr_clear() has not been heavily used early in boot, or
on kernel text.

It has checks like BUG_ON(irqs_disabled()), looking for interrupt
disabling but that also trip in early boot on certain preempt
configurations.  Just copy the existing BUG_ON() sequence to check for
early boot.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 39114b7a7 (x86/pti: Never implicitly clear _PAGE_GLOBAL for kernel image)
Reported-by: Mariusz Ceier <mceier@gmail.com>
Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
---

 b/arch/x86/mm/pageattr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/pageattr.c~pti-glb-boot-problem-fix arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~pti-glb-boot-problem-fix	2018-04-17 14:10:13.553395577 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-17 14:10:13.559395577 -0700
@@ -172,7 +172,7 @@ static void __cpa_flush_all(void *arg)
 
 static void cpa_flush_all(unsigned long cache)
 {
-	BUG_ON(irqs_disabled());
+	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
 
 	on_each_cpu(__cpa_flush_all, (void *) cache, 1);
 }
@@ -236,7 +236,7 @@ static void cpa_flush_array(unsigned lon
 	unsigned long do_wbinvd = cache && numpages >= 1024; /* 4M threshold */
 #endif
 
-	BUG_ON(irqs_disabled());
+	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
 
 	on_each_cpu(__cpa_flush_all, (void *) do_wbinvd, 1);
 
_
