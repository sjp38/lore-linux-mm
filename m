Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 693F46B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 12:48:59 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 6 Feb 2013 12:47:54 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 930CF38C8027
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 12:47:50 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r16HlnXF314356
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 12:47:50 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r16HlnGf016159
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 12:47:49 -0500
Subject: [RFC][PATCH] PAGE_OWNER now depends on STACKTRACE_SUPPORT
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 06 Feb 2013 09:47:48 -0800
Message-Id: <20130206174748.467A1FFD@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>


One of the enhancements I made to the PAGE_OWNER code was to make
it use the generic stack trace support.  However, there are some
architectures that do not support it, like m68k.  So, make
PAGE_OWNER also depend on having STACKTRACE_SUPPORT.

This isn't ideal since it restricts the number of places
PAGE_OWNER runs now, but it at least hits all the major
architectures.

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   83b324c5ff5cca85bbeb2ba913d465f108afe472
commit: 2a561c9d47c295ed91984c2b916a4dd450ee0279 [484/499] debugging-keep-track-of-page-owners-fix
config: make ARCH=m68k allmodconfig

All warnings:

warning: (PAGE_OWNER && STACK_TRACER && BLK_DEV_IO_TRACE && KMEMCHECK) selects STACKTRACE which has unmet direct dependencies (STACKTRACE_SUPPORT)

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/lib/Kconfig.debug |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN lib/Kconfig.debug~now-depends-on-STACKTRACE_SUPPORT lib/Kconfig.debug
--- linux-2.6.git/lib/Kconfig.debug~now-depends-on-STACKTRACE_SUPPORT	2013-02-06 09:44:01.372619511 -0800
+++ linux-2.6.git-dave/lib/Kconfig.debug	2013-02-06 09:44:10.648711604 -0800
@@ -101,7 +101,7 @@ config UNUSED_SYMBOLS
 
 config PAGE_OWNER
 	bool "Track page owner"
-	depends on DEBUG_KERNEL
+	depends on DEBUG_KERNEL && STACKTRACE_SUPPORT
 	select DEBUG_FS
 	select STACKTRACE
 	help
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
