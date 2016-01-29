Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 10000828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:16:52 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so44973969pab.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:16:52 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r72si25639057pfb.1.2016.01.29.10.16.46
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:46 -0800 (PST)
Subject: [PATCH 02/31] x86, fpu: add placeholder for Processor Trace XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:45 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181645.A240F14D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, ak@linux.intel.com, yu-cheng.yu@intel.com, fenghua.yu@intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

There is an XSAVE state component for Intel Processor Trace (PT).
But, we do not currently use it.

We add a placeholder in the code for it so it is not a mystery and
also so we do not need an explicit enum initialization for Protection
Keys in a moment.

Why don't we use it?

We might end up using this at _some_ point in the future.  But,
this is a "system" state which requires using the currently
unsupported XSAVES feature.  Unlike all the other XSAVE states,
PT state is also not directly tied to a thread.  You might
context-switch between threads, but not want to change any of the
PT state.  Or, you might switch between threads, and *do* want to
change PT state, all depending on what is being traced.

We currently just manually set some MSRs to do this PT context
switching, and it is unclear whether replacing our direct MSR use
with XSAVE will be a net win or loss, both in code complexity and
performance.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: yu-cheng.yu@intel.com
Cc: fenghua.yu@intel.com
---

 b/arch/x86/include/asm/fpu/types.h |    1 +
 b/arch/x86/kernel/fpu/xstate.c     |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pt-xstate-bit arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pt-xstate-bit	2016-01-28 15:52:17.216259779 -0800
+++ b/arch/x86/include/asm/fpu/types.h	2016-01-28 15:52:17.220259963 -0800
@@ -108,6 +108,7 @@ enum xfeature {
 	XFEATURE_OPMASK,
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
+	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 
 	XFEATURE_MAX,
 };
diff -puN arch/x86/kernel/fpu/xstate.c~pt-xstate-bit arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pt-xstate-bit	2016-01-28 15:52:17.217259825 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-01-28 15:52:17.221260009 -0800
@@ -13,6 +13,11 @@
 
 #include <asm/tlbflush.h>
 
+/*
+ * Although we spell it out in here, the Processor Trace
+ * xfeature is completely unused.  We use other mechanisms
+ * to save/restore PT state in Linux.
+ */
 static const char *xfeature_names[] =
 {
 	"x87 floating point registers"	,
@@ -23,7 +28,7 @@ static const char *xfeature_names[] =
 	"AVX-512 opmask"		,
 	"AVX-512 Hi256"			,
 	"AVX-512 ZMM_Hi256"		,
-	"unknown xstate feature"	,
+	"Processor Trace (unused)"	,
 };
 
 /*
@@ -470,7 +475,8 @@ static void check_xstate_against_struct(
 	 * numbers.
 	 */
 	if ((nr < XFEATURE_YMM) ||
-	    (nr >= XFEATURE_MAX)) {
+	    (nr >= XFEATURE_MAX) ||
+	    (nr == XFEATURE_PT_UNIMPLEMENTED_SO_FAR)) {
 		WARN_ONCE(1, "no structure for xstate: %d\n", nr);
 		XSTATE_WARN_ON(1);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
