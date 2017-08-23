Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4F16B04D5
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:04:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o82so12510599pfj.11
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:04:03 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u91si986989plb.1010.2017.08.23.05.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:03:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 16/19] x86/mm: Allow to boot without la57 if CONFIG_X86_5LEVEL=y
Date: Wed, 23 Aug 2017 15:03:29 +0300
Message-Id: <20170823120332.2288-17-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
References: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

All pieces of the puzzle are in place and we can now allow to boot with
CONFIG_X86_5LEVEL=y on a machine without la57 support.

Kernel will detect that la57 is missing and fold p4d at runtime.

Update documentation and Kconfig option description to reflect the
change.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/x86_64/5level-paging.txt | 9 +++------
 arch/x86/Kconfig                           | 4 ++--
 arch/x86/include/asm/required-features.h   | 8 +-------
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/Documentation/x86/x86_64/5level-paging.txt b/Documentation/x86/x86_64/5level-paging.txt
index 087251a0d99c..2432a5ef86d9 100644
--- a/Documentation/x86/x86_64/5level-paging.txt
+++ b/Documentation/x86/x86_64/5level-paging.txt
@@ -20,12 +20,9 @@ Documentation/x86/x86_64/mm.txt
 
 CONFIG_X86_5LEVEL=y enables the feature.
 
-So far, a kernel compiled with the option enabled will be able to boot
-only on machines that supports the feature -- see for 'la57' flag in
-/proc/cpuinfo.
-
-The plan is to implement boot-time switching between 4- and 5-level paging
-in the future.
+Kernel with CONFIG_X86_5LEVEL=y still able to boot on 4-level hardware.
+In this case additional page table level -- p4d -- will be folded at
+runtime.
 
 == User-space and large virtual address space ==
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 1e48d2fd8db9..c88db538f3b3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1411,8 +1411,8 @@ config X86_5LEVEL
 
 	  It will be supported by future Intel CPUs.
 
-	  Note: a kernel with this option enabled can only be booted
-	  on machines that support the feature.
+	  A kernel with the option enabled can be booted on machines that
+	  support 4- or 5-level paging.
 
 	  See Documentation/x86/x86_64/5level-paging.txt for more
 	  information.
diff --git a/arch/x86/include/asm/required-features.h b/arch/x86/include/asm/required-features.h
index d91ba04dd007..fac9a5c0abe9 100644
--- a/arch/x86/include/asm/required-features.h
+++ b/arch/x86/include/asm/required-features.h
@@ -53,12 +53,6 @@
 # define NEED_MOVBE	0
 #endif
 
-#ifdef CONFIG_X86_5LEVEL
-# define NEED_LA57	(1<<(X86_FEATURE_LA57 & 31))
-#else
-# define NEED_LA57	0
-#endif
-
 #ifdef CONFIG_X86_64
 #ifdef CONFIG_PARAVIRT
 /* Paravirtualized systems may not have PSE or PGE available */
@@ -104,7 +98,7 @@
 #define REQUIRED_MASK13	0
 #define REQUIRED_MASK14	0
 #define REQUIRED_MASK15	0
-#define REQUIRED_MASK16	(NEED_LA57)
+#define REQUIRED_MASK16	0
 #define REQUIRED_MASK17	0
 #define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
