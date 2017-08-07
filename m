Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00CAC6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:15:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so5219144pge.7
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:15:08 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 136si4625309pgc.239.2017.08.07.07.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:15:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 11/13] x86/mm: Allow to boot without la57 if CONFIG_X86_5LEVEL=y
Date: Mon,  7 Aug 2017 17:14:49 +0300
Message-Id: <20170807141451.80934-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
References: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 2c9c4899d9ff..4a1a52f064dc 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1408,8 +1408,8 @@ config X86_5LEVEL
 
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
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
