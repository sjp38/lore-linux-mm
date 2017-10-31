Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 430276B0260
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p9so455641pgc.6
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 67si2587700pgg.733.2017.10.31.15.31.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:53 -0700 (PDT)
Subject: [PATCH 03/23] x86, kaiser: disable global pages
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:52 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223152.B5D241B2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


Global pages stay in the TLB across context switches.  Since all
contexts share the same kernel mapping, we use global pages to
allow kernel entries in the TLB to survive when we context
switch.

But, even having these entries in the TLB opens up something that
an attacker can use [1].

Disable global pages so that kernel TLB entries are flushed when
we run userspace.  This way, all accesses to kernel memory result
in a TLB miss whether there is good data there or not.  Without
this, even when KAISER switches pages tables, the kernel entries
might remain in the TLB.

1. The double-page-fault attack:
   http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/Kconfig                     |    4 ++++
 b/arch/x86/include/asm/pgtable_types.h |    5 +++++
 2 files changed, 9 insertions(+)

diff -puN arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages	2017-10-31 15:03:49.314064402 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2017-10-31 15:03:49.323064827 -0700
@@ -47,7 +47,12 @@
 #define _PAGE_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_ACCESSED)
 #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
 #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
+#ifdef CONFIG_X86_GLOBAL_PAGES
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
+#else
+/* We must ensure that kernel TLBs are unusable while in userspace */
+#define _PAGE_GLOBAL	(_AT(pteval_t, 0))
+#endif
 #define _PAGE_SOFTW1	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW1)
 #define _PAGE_SOFTW2	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW2)
 #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
diff -puN arch/x86/Kconfig~kaiser-prep-disable-global-pages arch/x86/Kconfig
--- a/arch/x86/Kconfig~kaiser-prep-disable-global-pages	2017-10-31 15:03:49.318064591 -0700
+++ b/arch/x86/Kconfig	2017-10-31 15:03:49.325064922 -0700
@@ -327,6 +327,10 @@ config ARCH_SUPPORTS_UPROBES
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config X86_GLOBAL_PAGES
+	def_bool y
+	depends on ! KAISER
+
 config PGTABLE_LEVELS
 	int
 	default 5 if X86_5LEVEL
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
