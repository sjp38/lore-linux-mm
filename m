Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 687A4828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:06:42 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so243315348pac.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:06:42 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ro6si53808668pab.190.2016.01.06.16.01.22
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:22 -0800 (PST)
Subject: [PATCH 12/31] signals, pkeys: notify userspace about protection key faults
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:22 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000122.6E6FDC66@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

A protection key fault is very similar to any other access error.
There must be a VMA, etc...  We even want to take the same action
(SIGSEGV) that we do with a normal access fault.

However, we do need to let userspace know that something is
different.  We do this the same way what we did with SEGV_BNDERR
with Memory Protection eXtensions (MPX): define a new SEGV code:
SEGV_PKUERR.

We add a siginfo field: si_pkey that reveals to userspace which
protection key was set on the PTE that we faulted on.  There is
no other easy way for userspace to figure this out.  They could
parse smaps but that would be a bit cruel.

We share space with in siginfo with _addr_bnd.  #BR faults from
MPX are completely separate from page faults (#PF) that trigger
from protection key violations, so we never need both at the same
time.

Note that _pkey is a 64-bit value.  The current hardware only
supports 4-bit protection keys.  We do this because there is
_plenty_ of space in _sigfault and it is possible that future
processors would support more than 4 bits of protection keys.

The x86 code to actually fill in the siginfo is in the next
patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/include/uapi/asm-generic/siginfo.h |   17 ++++++++++++-----
 b/kernel/signal.c                    |    4 ++++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff -puN include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo-core include/uapi/asm-generic/siginfo.h
--- a/include/uapi/asm-generic/siginfo.h~pkeys-09-siginfo-core	2016-01-06 15:50:07.838256440 -0800
+++ b/include/uapi/asm-generic/siginfo.h	2016-01-06 15:50:07.843256665 -0800
@@ -91,10 +91,15 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb; /* LSB of the reported address */
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
@@ -137,6 +142,7 @@ typedef struct siginfo {
 #define si_addr_lsb	_sifields._sigfault._addr_lsb
 #define si_lower	_sifields._sigfault._addr_bnd._lower
 #define si_upper	_sifields._sigfault._addr_bnd._upper
+#define si_pkey		_sifields._sigfault._pkey
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 #ifdef __ARCH_SIGSYS
@@ -206,7 +212,8 @@ typedef struct siginfo {
 #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
 #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
 #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
-#define NSIGSEGV	3
+#define SEGV_PKUERR	(__SI_FAULT|4)  /* failed protection key checks */
+#define NSIGSEGV	4
 
 /*
  * SIGBUS si_codes
diff -puN kernel/signal.c~pkeys-09-siginfo-core kernel/signal.c
--- a/kernel/signal.c~pkeys-09-siginfo-core	2016-01-06 15:50:07.840256530 -0800
+++ b/kernel/signal.c	2016-01-06 15:50:07.844256710 -0800
@@ -2709,6 +2709,10 @@ int copy_siginfo_to_user(siginfo_t __use
 			err |= __put_user(from->si_upper, &to->si_upper);
 		}
 #endif
+#ifdef SEGV_PKUERR
+		if (from->si_signo == SIGSEGV && from->si_code == SEGV_PKUERR)
+			err |= __put_user(from->si_pkey, &to->si_pkey);
+#endif
 		break;
 	case __SI_CHLD:
 		err |= __put_user(from->si_pid, &to->si_pid);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
