Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CC1406B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 14:30:47 -0400 (EDT)
Date: Fri, 21 Aug 2009 19:30:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH mmotm] ksm: antidote to MADV_MERGEABLE HWPOISON
Message-ID: <Pine.LNX.4.64.0908211912330.14259@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Chris Zankel <chris@zankel.net>, Rik van RIel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Avi Kivity <avi@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

linux-next is now sporting MADV_HWPOISON at 12, which would have a very
nasty effect on KSM if you had CONFIG_MEMORY_FAILURE=y with CONFIG_KSM=y.
Shift MADV_MERGEABLE and MADV_UNMERGEABLE down two - two to reduce the
confusion if old and new userspace and kernel are mismatched.

Personally I'd prefer the MADV_HWPOISON testing feature to shift; but
linux-next comes first in the mmotm lineup, and I can't be sure that
madvise KSM already has more users than there are HWPOISON testers:
so unless Andi is happy to shift MADV_HWPOISON, mmotm needs this.
---
Fix to ksm-define-madv_mergeable-and-madv_unmergeable.patch
parisc unaffected because its MADVs are displaced.

 arch/alpha/include/asm/mman.h     |    4 ++--
 arch/mips/include/asm/mman.h      |    4 ++--
 arch/xtensa/include/asm/mman.h    |    4 ++--
 include/asm-generic/mman-common.h |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

--- mmotm/arch/alpha/include/asm/mman.h	2009-08-21 12:08:18.000000000 +0100
+++ linux/arch/alpha/include/asm/mman.h	2009-08-21 18:28:14.000000000 +0100
@@ -48,8 +48,8 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
-#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
-#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+#define MADV_MERGEABLE   14		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 15		/* KSM may not merge identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
--- mmotm/arch/mips/include/asm/mman.h	2009-08-21 12:08:18.000000000 +0100
+++ linux/arch/mips/include/asm/mman.h	2009-08-21 18:28:24.000000000 +0100
@@ -71,8 +71,8 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
-#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
-#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+#define MADV_MERGEABLE   14		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 15		/* KSM may not merge identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
--- mmotm/arch/xtensa/include/asm/mman.h	2009-08-21 12:08:18.000000000 +0100
+++ linux/arch/xtensa/include/asm/mman.h	2009-08-21 18:28:52.000000000 +0100
@@ -78,8 +78,8 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
-#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
-#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+#define MADV_MERGEABLE   14		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 15		/* KSM may not merge identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
--- mmotm/include/asm-generic/mman-common.h	2009-08-21 12:08:18.000000000 +0100
+++ linux/include/asm-generic/mman-common.h	2009-08-21 18:29:01.000000000 +0100
@@ -36,8 +36,8 @@
 #define MADV_DOFORK	11		/* do inherit across fork */
 #define MADV_HWPOISON	12		/* poison a page for testing */
 
-#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
-#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+#define MADV_MERGEABLE   14		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 15		/* KSM may not merge identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
