Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 65F0F82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:46 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so57699126igb.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:24:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id f9si13189516igg.102.2015.09.28.12.18.18
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:19 -0700 (PDT)
Subject: [PATCH 01/25] x86, fpu: add placeholder for Processor Trace XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:18 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191818.34AAC17E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


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

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/fpu/types.h |    1 +
 b/arch/x86/kernel/fpu/xstate.c     |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pt-xstate-bit arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pt-xstate-bit	2015-09-28 11:39:41.443977969 -0700
+++ b/arch/x86/include/asm/fpu/types.h	2015-09-28 11:39:41.448978197 -0700
@@ -108,6 +108,7 @@ enum xfeature {
 	XFEATURE_OPMASK,
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
+	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 
 	XFEATURE_MAX,
 };
diff -puN arch/x86/kernel/fpu/xstate.c~pt-xstate-bit arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pt-xstate-bit	2015-09-28 11:39:41.445978060 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2015-09-28 11:39:41.449978242 -0700
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
