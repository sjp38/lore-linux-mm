Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5AB6B025F
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:17:07 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x65so15527916pfb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:17:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wg10si3385570pac.23.2016.02.17.10.17.04
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 10:17:04 -0800 (PST)
Subject: [PATCH] signals, ia64, mips: update arch-specific siginfos with pkeys field
From: Dave Hansen <dave@sr71.net>
Date: Wed, 17 Feb 2016 10:17:03 -0800
Message-Id: <20160217181703.E99B6656@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org


This fixes a compile error that Ingo was hitting with MIPS when the
x86 pkeys patch set is applied.

ia64 and mips have separate definitions for siginfo from the
generic one.  Patch them to have the pkey fields.

Note that this is exactly what we did for MPX as well.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mips@linux-mips.org
Cc: linux-ia64@vger.kernel.org
---

 b/arch/ia64/include/uapi/asm/siginfo.h |   13 +++++++++----
 b/arch/mips/include/uapi/asm/siginfo.h |   13 +++++++++----
 2 files changed, 18 insertions(+), 8 deletions(-)

diff -puN arch/ia64/include/uapi/asm/siginfo.h~pkeys-09-1-siginfo-for-mips-ia64 arch/ia64/include/uapi/asm/siginfo.h
--- a/arch/ia64/include/uapi/asm/siginfo.h~pkeys-09-1-siginfo-for-mips-ia64	2016-02-17 09:32:06.001815266 -0800
+++ b/arch/ia64/include/uapi/asm/siginfo.h	2016-02-17 09:32:06.010815672 -0800
@@ -63,10 +63,15 @@ typedef struct siginfo {
 			unsigned int _flags;	/* see below */
 			unsigned long _isr;	/* isr */
 			short _addr_lsb;	/* lsb of faulting address */
-			struct {
-				void __user *_lower;
-				void __user *_upper;
-			} _addr_bnd;
+			union {
+				/* used when si_code=SEGV_BNDERR */
+				struct {
+					void __user *_lower;
+					void __user *_upper;
+				} _addr_bnd;
+				/* used when si_code=SEGV_PKUERR */
+				u64 _pkey;
+			};
 		} _sigfault;
 
 		/* SIGPOLL */
diff -puN arch/mips/include/uapi/asm/siginfo.h~pkeys-09-1-siginfo-for-mips-ia64 arch/mips/include/uapi/asm/siginfo.h
--- a/arch/mips/include/uapi/asm/siginfo.h~pkeys-09-1-siginfo-for-mips-ia64	2016-02-17 09:32:06.003815357 -0800
+++ b/arch/mips/include/uapi/asm/siginfo.h	2016-02-17 09:32:06.010815672 -0800
@@ -86,10 +86,15 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb;
-			struct {
-				void __user *_lower;
-				void __user *_upper;
-			} _addr_bnd;
+			union {
+				/* used when si_code=SEGV_BNDERR */
+				struct {
+					void __user *_lower;
+					void __user *_upper;
+				} _addr_bnd;
+				/* used when si_code=SEGV_PKUERR */
+				u64 _pkey;
+			};
 		} _sigfault;
 
 		/* SIGPOLL, SIGXFSZ (To do ...)	 */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
