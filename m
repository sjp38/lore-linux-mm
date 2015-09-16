Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EDE0E6B0254
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:50:47 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so215124926pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:50:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lg2si42353578pbc.60.2015.09.16.10.50.46
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:50:47 -0700 (PDT)
Subject: [PATCH 01/26] x86, fpu: add placeholder for Processor Trace XSAVE state
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:04 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174904.E002DB09@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


There is an XSAVE state component for Intel Processor Trace.  But,
we do not use it and do not expect to ever use it.

We add a placeholder in the code for it so it is not a mystery and
also so we do not need an explicit enum initialization for Protection
Keys in a moment.

Why will we never use it?  According to Andi Kleen:

The XSAVE support assumes that there is a single buffer for each
thread. But perf generally doesn't work this way, it usually has
only a single perf event per CPU per user, and when tracing
multiple threads on that CPU it inherits perf event buffers between
different threads. So XSAVE per thread cannot handle this inheritance
case directly.

Using multiple XSAVE areas (another one per perf event) would defeat
some of the state caching that the CPUs do.


---

 b/arch/x86/include/asm/fpu/types.h |    1 +
 b/arch/x86/kernel/fpu/xstate.c     |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/fpu/types.h~pt-xstate-bit arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pt-xstate-bit	2015-09-16 10:48:11.570979927 -0700
+++ b/arch/x86/include/asm/fpu/types.h	2015-09-16 10:48:11.574980109 -0700
@@ -108,6 +108,7 @@ enum xfeature {
 	XFEATURE_OPMASK,
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
+	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 
 	XFEATURE_MAX,
 };
diff -puN arch/x86/kernel/fpu/xstate.c~pt-xstate-bit arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pt-xstate-bit	2015-09-16 10:48:11.571979973 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2015-09-16 10:48:11.575980154 -0700
@@ -469,7 +469,8 @@ static void check_xstate_against_struct(
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
