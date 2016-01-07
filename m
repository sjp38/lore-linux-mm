Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0EACC6B0008
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:01:47 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id o62so298071587oif.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:01:47 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j9si2363688obw.29.2016.01.06.16.01.09
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:09 -0800 (PST)
Subject: [PATCH 02/31] x86, fpu: add placeholder for Processor Trace XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:08 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000108.7AFD3AF6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, ak@linux.intel.com, yu-cheng.yu@intel.com, fenghua.yu@intel.com


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
--- a/arch/x86/include/asm/fpu/types.h~pt-xstate-bit	2016-01-06 15:50:03.468059415 -0800
+++ b/arch/x86/include/asm/fpu/types.h	2016-01-06 15:50:03.473059640 -0800
@@ -108,6 +108,7 @@ enum xfeature {
 	XFEATURE_OPMASK,
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
+	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 
 	XFEATURE_MAX,
 };
diff -puN arch/x86/kernel/fpu/xstate.c~pt-xstate-bit arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pt-xstate-bit	2016-01-06 15:50:03.470059505 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-01-06 15:50:03.473059640 -0800
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
@@ -469,7 +474,8 @@ static void check_xstate_against_struct(
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
