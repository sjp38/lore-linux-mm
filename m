Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 311FF6B005D
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:27:24 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 03/10] ksm: define MADV_MERGEABLE and MADV_UNMERGEABLE
Date: Fri, 17 Jul 2009 20:30:43 +0300
Message-Id: <1247851850-4298-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-3-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Chris Zankel <chris@zankel.net>
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

The out-of-tree KSM used ioctls on fds cloned from /dev/ksm to register
a memory area for merging: we prefer now to use an madvise(2) interface.

This patch just defines MADV_MERGEABLE (to tell KSM it may merge pages
in this area found identical to pages in other mergeable areas) and
MADV_UNMERGEABLE (to undo that).

Most architectures use asm-generic, but alpha, mips, parisc, xtensa
need their own definitions: included here for mmotm convenience, but
we'll probably want to split this and feed pieces to arch maintainers.

Based upon earlier patches by Chris Wright and Izik Eidus.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Cc: Helge Deller <deller@gmx.de>
Cc: Chris Zankel <chris@zankel.net>
---
 arch/alpha/include/asm/mman.h     |    3 +++
 arch/mips/include/asm/mman.h      |    3 +++
 arch/parisc/include/asm/mman.h    |    3 +++
 arch/xtensa/include/asm/mman.h    |    3 +++
 include/asm-generic/mman-common.h |    3 +++
 5 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/mman.h b/arch/alpha/include/asm/mman.h
index 90d7c35..c77c557 100644
--- a/arch/alpha/include/asm/mman.h
+++ b/arch/alpha/include/asm/mman.h
@@ -48,6 +48,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/mips/include/asm/mman.h b/arch/mips/include/asm/mman.h
index e4d6f1f..f15554d 100644
--- a/arch/mips/include/asm/mman.h
+++ b/arch/mips/include/asm/mman.h
@@ -71,6 +71,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/arch/parisc/include/asm/mman.h b/arch/parisc/include/asm/mman.h
index defe752..a12d9d4 100644
--- a/arch/parisc/include/asm/mman.h
+++ b/arch/parisc/include/asm/mman.h
@@ -54,6 +54,9 @@
 #define MADV_16M_PAGES  24              /* Use 16 Megabyte pages */
 #define MADV_64M_PAGES  26              /* Use 64 Megabyte pages */
 
+#define MADV_MERGEABLE   65		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 66		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
diff --git a/arch/xtensa/include/asm/mman.h b/arch/xtensa/include/asm/mman.h
index 9b92620..6e55b4d 100644
--- a/arch/xtensa/include/asm/mman.h
+++ b/arch/xtensa/include/asm/mman.h
@@ -78,6 +78,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index 3b69ad3..dd63bd3 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -35,6 +35,9 @@
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
 
+#define MADV_MERGEABLE   12		/* KSM may merge identical pages */
+#define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
