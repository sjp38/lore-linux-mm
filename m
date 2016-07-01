Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C77146B0253
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so203833137pfa.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p7si967228pfp.244.2016.06.30.17.12.11
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:11 -0700 (PDT)
Subject: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:10 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001210.AA77B917@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, luto@kernel.org, stable@vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

epufeatures.h currently defines X86_BUG(9) twice on 32-bit:

	#define X86_BUG_NULL_SEG        X86_BUG(9) /* Nulling a selector preserves the base */
	...
	#ifdef CONFIG_X86_32
	#define X86_BUG_ESPFIX          X86_BUG(9) /* "" IRET to 16-bit SS corrupts ESP/RSP high bits */
	#endif

I think what happened was that this added the X86_BUG_ESPFIX, but
in an #ifdef below most of the bugs:

	[58a5aac5] x86/entry/32: Introduce and use X86_BUG_ESPFIX instead of paravirt_enabled

Then this came along and added X86_BUG_NULL_SEG, but collided
with the earlier one that did the bug below the main block
defining all the X86_BUG()s.

	[7a5d6704] x86/cpu: Probe the behavior of nulling out a segment at boot time

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
Cc: stable@vger.kernel.org
---

 b/arch/x86/include/asm/cpufeatures.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros arch/x86/include/asm/cpufeatures.h
--- a/arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros	2016-06-30 17:10:41.215185869 -0700
+++ b/arch/x86/include/asm/cpufeatures.h	2016-06-30 17:10:41.218186005 -0700
@@ -301,10 +301,6 @@
 #define X86_BUG_FXSAVE_LEAK	X86_BUG(6) /* FXSAVE leaks FOP/FIP/FOP */
 #define X86_BUG_CLFLUSH_MONITOR	X86_BUG(7) /* AAI65, CLFLUSH required before MONITOR */
 #define X86_BUG_SYSRET_SS_ATTRS	X86_BUG(8) /* SYSRET doesn't fix up SS attrs */
-#define X86_BUG_NULL_SEG	X86_BUG(9) /* Nulling a selector preserves the base */
-#define X86_BUG_SWAPGS_FENCE	X86_BUG(10) /* SWAPGS without input dep on GS */
-
-
 #ifdef CONFIG_X86_32
 /*
  * 64-bit kernels don't use X86_BUG_ESPFIX.  Make the define conditional
@@ -312,5 +308,7 @@
  */
 #define X86_BUG_ESPFIX		X86_BUG(9) /* "" IRET to 16-bit SS corrupts ESP/RSP high bits */
 #endif
+#define X86_BUG_NULL_SEG	X86_BUG(10) /* Nulling a selector preserves the base */
+#define X86_BUG_SWAPGS_FENCE	X86_BUG(11) /* SWAPGS without input dep on GS */
 
 #endif /* _ASM_X86_CPUFEATURES_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
