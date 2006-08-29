Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJZ12023561
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:35 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJZqs295100
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:35 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJZqF011643
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:35 -0400
Subject: [RFC][PATCH 00/10] generic PAGE_SIZE infrastructure (v3)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:34 -0700
Message-Id: <20060829201934.47E63D1F@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Changes from last version
- included get_order() code to make it safe to include
  generic/page.h everywhere (using ARCH_HAS_GET_ORDER)
- updated mm/Kconfig text to make it more fitting for ia64
- added patch to consolidate _ALIGN with kernel.h's ALIGN()
  The assembly one has been left alone, but I guess we could
  put it here.  However, the meaning of the two is quite different.

---

All architectures currently explicitly define their page size.  In some
cases (ppc, parisc, ia64, sparc64, mips) this size is somewhat
configurable.

There several reimplementations of ways to make sure that PAGE_SIZE
is usable in assembly code, yet still somewhat type safe for use in
C code (as a UL type).  These are all very similar.  There are also a
number of macros based off of PAGE_SIZE/SHIFT which are duplicated
across architectures.

This patch unifies all of those definitions.  It defines PAGE_SIZE in
a single header which gets its definitions from Kconfig.  The new
Kconfig options mirror what used to be done with #ifdefs and
arch-specific Kconfig options.  The new Kconfig menu eliminates
the need for parisc, ia64, and sparc64 to have their own "choice"
menus for selecting page size.  The help text has been adapted from
these three architectures, but is now more generic.

Why am I doing this?  The OpenVZ beancounter patch hooks into the
alloc_thread_info() path, but only in two architectures.  It is silly
to patch each and every architecture when they all just do the same
thing.  This is the first step to have a single place in which to
do alloc_thread_info().  Oh, and this series removes about 300 lines
of code.

 46 files changed, 178 insertions(+), 514 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
