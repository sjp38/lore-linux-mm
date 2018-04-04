Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 466066B000E
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:12:53 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 61-v6so8675361plz.20
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:12:53 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 33-v6si4237535pla.452.2018.04.03.18.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 18:12:52 -0700 (PDT)
Subject: [PATCH 08/11] x86/mm: do not forbid _PAGE_RW before init for __ro_after_init
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 03 Apr 2018 18:10:05 -0700
References: <20180404010946.6186729B@viggo.jf.intel.com>
In-Reply-To: <20180404010946.6186729B@viggo.jf.intel.com>
Message-Id: <20180404011005.F6B62E51@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, keescook@chromium.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

__ro_after_init data gets stuck in the .rodata section.  That's normally
fine because the kernel itself manages the R/W properties.

But, if we run __change_page_attr() on an area which is __ro_after_init,
the .rodata checks will trigger and force the area to be immediately
read-only, even if it is early-ish in boot.  This caused problems when
trying to clear the _PAGE_GLOBAL bit for these area in the PTI code:
it cleared _PAGE_GLOBAL like I asked, but also took it up on itself
to clear _PAGE_RW.  The kernel then oopses the next time it wrote to
a __ro_after_init data structure.

To fix this, add the kernel_set_to_readonly check, just like we have
for kernel text, just a few lines below in this function.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
---

 b/arch/x86/mm/pageattr.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/pageattr.c~check-kernel_set_to_readonly arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~check-kernel_set_to_readonly	2018-04-02 16:41:16.620605169 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-02 16:41:16.624605169 -0700
@@ -298,9 +298,11 @@ static inline pgprot_t static_protection
 
 	/*
 	 * The .rodata section needs to be read-only. Using the pfn
-	 * catches all aliases.
+	 * catches all aliases.  This also includes __ro_after_init,
+	 * so do not enforce until kernel_set_to_readonly is true.
 	 */
-	if (within(pfn, __pa_symbol(__start_rodata) >> PAGE_SHIFT,
+	if (kernel_set_to_readonly &&
+	    within(pfn, __pa_symbol(__start_rodata) >> PAGE_SHIFT,
 		   __pa_symbol(__end_rodata) >> PAGE_SHIFT))
 		pgprot_val(forbidden) |= _PAGE_RW;
 
_
