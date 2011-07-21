Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEDAF6B0083
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:53:38 -0400 (EDT)
Received: by eyg7 with SMTP id 7so2049498eyg.41
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:53:35 -0700 (PDT)
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v3 1/5] introduce config RUNTIME_USER_COPY_CHECK
Date: Thu, 21 Jul 2011 16:53:30 +0400
Message-Id: <1311252810-6686-1-git-send-email-segoon@openwall.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Randy Dunlap <randy.dunlap@oracle.com>, Josh Triplett <josh@joshtriplett.org>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>

RUNTIME_USER_COPY_CHECK defines a set of checks length parameter of
usercopy functions.  Currently there are some very simple and cheap
comparisons of supplied size and the size of a copied object known at
the compile time in copy_* functions.  This patch enhances these checks
to check against stack frame boundaries and against SL*B object sizes.
The option does nothing with other memory areas like vmalloc'ed areas,
modules' data and code sections, etc.  It can be an area for
improvements.

The slowdown is negligible - for most cases it is reduced to integer
comparison (in fstat, getrlimit, ipc) for some cases the whole syscall
time and the time of a check are not comparable (in write, path
traversal functions - openat, stat), for programs with not intensive
syscalls usage.  One of the most significant slowdowns is gethostname(),
the penalty is 0,9%.  For 'find /usr', 'git log -Sredirect' in kernel
tree, kernel compilation the slowdown is less than 0,1% (couldn't
measure it more precisely).  However, as a buffer overflow may be not a
threat and/or even such slowdown may be not acceptable, the check can be
disabled via config option.

The option is a forward-port of the PAX_USERCOPY feature from the PaX
patch.  Most code was copied from the PaX patch with minor cosmetic
changes.  Also PaX' version of the patch has additional restrictions:

a) some slab caches has SLAB_USERCOPY flag set and copies to/from the
slab caches without the flag are denied.  Rare cases where some bytes
needed from the caches missing in the white list are handled by copying
the bytes into temporary area on the stack/heap.

b) if a malformed copy request is spotted, the event is logged and
SIGKILL signal is sent to the current task.

Examples of overflows, which become non-exploitable with RUNTIME_USER_COPY_CHECK:
DCCP getsockopt copy_to_user() overflow (fixed in 39ebc0276bada),
L2TP memcpy_fromiovec() overflow (fixed in 253eacc070b),
64kb iwconfig infoleak (fixed in 42da2f948d, was found by PAX_USERCOPY).

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 lib/Kconfig.debug |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index dd373c8..ed266b6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -679,6 +679,28 @@ config DEBUG_STACK_USAGE
 
 	  This option will slow down process creation somewhat.
 
+config DEBUG_RUNTIME_USER_COPY_CHECKS
+	bool "Runtime usercopy size checks"
+	default n
+	depends on DEBUG_KERNEL && X86
+	---help---
+	  Enabling this option adds additional runtime checks into copy_from_user()
+	  and similar functions.
+
+	  Specifically, if the data touches the stack, it checks whether a copied
+	  memory chunk fully fits in the stack. If CONFIG_FRAME_POINTER=y, also
+	  checks whether it fully fits in a single stack frame. It limits
+	  infoleaks/overwrites to a single frame and local variables
+	  only, and prevents saved return instruction pointer overwriting.
+
+	  If the data is from the SL*B cache, checks whether it fully fits in a
+	  slab page and whether it overflows a slab object.  E.g. if the memory
+	  was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
+	  bytes, the copy would fail.
+
+	  The option has a minimal performance drawback (up to 1% on tiny syscalls
+	  like gethostname).
+
 config DEBUG_KOBJECT
 	bool "kobject debugging"
 	depends on DEBUG_KERNEL
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
