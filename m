Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A76BC6B0343
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p22so62132095pgn.3
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y9si9748415pli.57.2017.06.06.04.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 13/14] x86: Enable 5-level paging support
Date: Tue,  6 Jun 2017 14:31:32 +0300
Message-Id: <20170606113133.22974-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of things are in place and we can enable support of 5-level paging.

The patch makes XEN_PV dependent on !X86_5LEVEL. XEN_PV is not ready to
work with 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/Kconfig     | 5 +++++
 arch/x86/xen/Kconfig | 1 +
 2 files changed, 6 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index de71b6aca0be..881fbbe8296b 100644
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
index 027987638e98..1be9667bd476 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -17,6 +17,7 @@ config XEN_PV
 	bool "Xen PV guest support"
 	default y
 	depends on XEN
+	depends on !X86_5LEVEL
 	select XEN_HAVE_PVMMU
 	select XEN_HAVE_VPMU
 	help
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
