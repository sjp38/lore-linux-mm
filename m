Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4AC6B02F3
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:12:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 62so41013634pft.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:12:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a89si10570636pfg.237.2017.05.15.05.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 05:12:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5, REBASED 8/9] x86: Enable 5-level paging support
Date: Mon, 15 May 2017 15:12:17 +0300
Message-Id: <20170515121218.27610-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of things are in place and we can enable support of 5-level paging.

Enabling XEN with 5-level paging requires more work. The patch makes XEN
dependent on !X86_5LEVEL.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig     | 5 +++++
 arch/x86/xen/Kconfig | 1 +
 2 files changed, 6 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cd18994a9555..11bd0498f64c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -318,6 +318,7 @@ config FIX_EARLYCON_MEM
 
 config PGTABLE_LEVELS
 	int
+	default 5 if X86_5LEVEL
 	default 4 if X86_64
 	default 3 if X86_PAE
 	default 2
@@ -1390,6 +1391,10 @@ config X86_PAE
 	  has the cost of more pagetable lookup overhead, and also
 	  consumes more pagetable space per process.
 
+config X86_5LEVEL
+	bool "Enable 5-level page tables support"
+	depends on X86_64
+
 config ARCH_PHYS_ADDR_T_64BIT
 	def_bool y
 	depends on X86_64 || X86_PAE
diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 027987638e98..12205e6dfa59 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -5,6 +5,7 @@
 config XEN
 	bool "Xen guest support"
 	depends on PARAVIRT
+	depends on !X86_5LEVEL
 	select PARAVIRT_CLOCK
 	depends on X86_64 || (X86_32 && X86_PAE)
 	depends on X86_LOCAL_APIC && X86_TSC
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
