Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6F4D6B0022
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:13:25 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w9-v6so10294125plp.0
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:13:25 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 1-v6si3247451plz.279.2018.04.10.13.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 13:13:24 -0700 (PDT)
Subject: [PATCH] x86, boot: initialize __default_kernel_pte_mask in KASLR code
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 10 Apr 2018 13:10:11 -0700
Message-Id: <20180410201011.F823E22B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, thomas.lendacky@amd.com, efault@gmx.de, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de, linux-mm@kvack.org


The somewhat discrete arch/x86/boot/compressed code shares headers with
the main kernel, but needs its own copies of some variables.  The copy
of __default_kernel_pte_mask did not get initialized correctly and has
been reported to cause boot failures when KASLR is in use by Tom
Lendacky and Mike Galibrath.

I've oddly been unable to reproduce these, but the fix is simple and
confirmed to work by Tom and Mike.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 64c80759408f ("x86/mm: Do not auto-massage page protections")
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Mike Galbraith <efault@gmx.de>
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

 b/arch/x86/boot/compressed/kaslr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/x86/boot/compressed/kaslr.c~x86-boot-initialize-__default_kernel_pte_mask arch/x86/boot/compressed/kaslr.c
--- a/arch/x86/boot/compressed/kaslr.c~x86-boot-initialize-__default_kernel_pte_mask	2018-04-10 13:02:22.359914088 -0700
+++ b/arch/x86/boot/compressed/kaslr.c	2018-04-10 13:02:40.389914043 -0700
@@ -54,8 +54,8 @@ unsigned int ptrs_per_p4d __ro_after_ini
 
 extern unsigned long get_cmd_line_ptr(void);
 
-/* Used by PAGE_KERN* macros: */
-pteval_t __default_kernel_pte_mask __read_mostly;
+/* Used by PAGE_KERN* macros, do not mask off any bits by default: */
+pteval_t __default_kernel_pte_mask __read_mostly = ~0;
 
 /* Simplified build-specific string for starting entropy. */
 static const char build_str[] = UTS_RELEASE " (" LINUX_COMPILE_BY "@"
_
