Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C57376B0083
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:32 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [4/19] HWPOISON: Add new SIGBUS error codes for hardware poison signals
Message-Id: <20090805093631.C0BD6B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:31 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


Add new SIGBUS codes for reporting machine checks as signals. When 
the hardware detects an uncorrected ECC error it can trigger these
signals.

This is needed for telling KVM's qemu about machine checks that happen to
guests, so that it can inject them, but might be also useful for other programs.
I find it useful in my test programs.

This patch merely defines the new types.

- Define two new si_codes for SIGBUS.  BUS_MCEERR_AO and BUS_MCEERR_AR
* BUS_MCEERR_AO is for "Action Optional" machine checks, which means that some
corruption has been detected in the background, but nothing has been consumed
so far. The program can ignore those if it wants (but most programs would
already get killed)
* BUS_MCEERR_AR is for "Action Required" machine checks. This happens
when corrupted data is consumed or the application ran into an area
which has been known to be corrupted earlier. These require immediate
action and cannot just returned to. Most programs would kill themselves.
- They report the address of the corruption in the user address space
in si_addr.
- Define a new si_addr_lsb field that reports the extent of the corruption
to user space. That's currently always a (small) page. The user application
cannot tell where in this page the corruption happened.

AK: I plan to write a man page update before anyone asks.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/asm-generic/siginfo.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: linux/include/asm-generic/siginfo.h
===================================================================
--- linux.orig/include/asm-generic/siginfo.h
+++ linux/include/asm-generic/siginfo.h
@@ -82,6 +82,7 @@ typedef struct siginfo {
 #ifdef __ARCH_SI_TRAPNO
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
+			short _addr_lsb; /* LSB of the reported address */
 		} _sigfault;
 
 		/* SIGPOLL */
@@ -112,6 +113,7 @@ typedef struct siginfo {
 #ifdef __ARCH_SI_TRAPNO
 #define si_trapno	_sifields._sigfault._trapno
 #endif
+#define si_addr_lsb	_sifields._sigfault._addr_lsb
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 
@@ -192,7 +194,11 @@ typedef struct siginfo {
 #define BUS_ADRALN	(__SI_FAULT|1)	/* invalid address alignment */
 #define BUS_ADRERR	(__SI_FAULT|2)	/* non-existant physical address */
 #define BUS_OBJERR	(__SI_FAULT|3)	/* object specific hardware error */
-#define NSIGBUS		3
+/* hardware memory error consumed on a machine check: action required */
+#define BUS_MCEERR_AR	(__SI_FAULT|4)
+/* hardware memory error detected in process but not consumed: action optional*/
+#define BUS_MCEERR_AO	(__SI_FAULT|5)
+#define NSIGBUS		5
 
 /*
  * SIGTRAP si_codes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
