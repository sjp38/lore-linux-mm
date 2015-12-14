Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 95CC16B0256
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:05:47 -0500 (EST)
Received: by pabur14 with SMTP id ur14so108603324pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:05:47 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v76si18785919pfa.183.2015.12.14.11.05.46
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:05:46 -0800 (PST)
Subject: [PATCH 02/32] x86, fpu: add placeholder for Processor Trace XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:46 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190546.D798BF32@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, yu-cheng.yu@intel.com, fenghua.yu@intel.com, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

x86 Maintainers,

I submitted this independently, but it must be applied before adding
subsequent patches.  Please drop this if it has already been applied.

---

From: Dave Hansen <dave.hansen@linux.intel.com>

There is an XSAVE state component for Intel Processor Trace.  But,
we do not use it and do not expect to ever use it.

We add a placeholder in the code for it so it is not a mystery and
also so we do not need an explicit enum initialization for Protection
Keys in a moment.

Why will we never use it?  According to Andi Kleen:

	The XSAVE support assumes that there is a single buffer
	for each thread. But perf generally doesn't work this
	way, it usually has only a single perf event per CPU per
	user, and when tracing multiple threads on that CPU it
	inherits perf event buffers between different threads. So
	XSAVE per thread cannot handle this inheritance case
	directly.

	Using multiple XSAVE areas (another one per perf event)
	would defeat some of the state caching that the CPUs do.

Cc: yu-cheng.yu@intel.com
Cc: fenghua.yu@intel.com
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/fpu/types.h |    1 +
 b/arch/x86/kernel/fpu/xstate.c     |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pt-xstate-bit arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pt-xstate-bit	2015-12-14 10:42:39.661662240 -0800
+++ b/arch/x86/include/asm/fpu/types.h	2015-12-14 10:42:39.666662464 -0800
@@ -108,6 +108,7 @@ enum xfeature {
 	XFEATURE_OPMASK,
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
+	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 
 	XFEATURE_MAX,
 };
diff -puN arch/x86/kernel/fpu/xstate.c~pt-xstate-bit arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pt-xstate-bit	2015-12-14 10:42:39.663662329 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2015-12-14 10:42:39.667662509 -0800
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
