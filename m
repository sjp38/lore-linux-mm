From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/22] HWPOISON: Add new SIGBUS error codes for hardware poison signals
Date: Mon, 15 Jun 2009 10:45:24 +0800
Message-ID: <20090615031252.821591566@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 952686B007E
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:28 -0400 (EDT)
Content-Disposition: inline; filename=poison-signal
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

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

--- sound-2.6.orig/include/asm-generic/siginfo.h
+++ sound-2.6/include/asm-generic/siginfo.h
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
