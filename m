Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 630B06B0047
	for <linux-mm@kvack.org>; Sat, 16 Jan 2010 13:46:45 -0500 (EST)
Date: Sat, 16 Jan 2010 19:46:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] register MADV_HUGEPAGE
Message-ID: <20100116184642.GA5687@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

In order to allow early shipping transparent hugepage feature enabled
only inside MADV_HUGEPAGE and not globally to diminish the risk of
unexpected performance regressions on non-hypervisor related usages
I'd need this little define registered. This is also to avoid things
like this:

#define MADV_DOFORK	11	    	 /* do inherit across fork */
#define MADV_HWPOISON	100		    /* poison a page for testing */

Picking random number not so nice... and with my proof of concept
patch posted working and boosting performance equally to hugetlbfs but
without its limitations, I think it is a given that eventually KVM
will run inside MADV_HUGEPAGE madvise regions only, so I see a
negligeable risk to pollute the kernel in including this as first bit
of the full patchset.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

The rest of the transparent hugepage patchset is very ready for
inclusion too with all cleanups requested and after full handling of
all review on linux-mm so far, with the only exception of khugepaged
that is about to be finished, expect a new submit on linux-mm in a few
days. Then we'll have to plug Mel memory compaction on top of it.

(in addition to the below, /sys/kernel/mm/transparent_hugepage also
has been moved to some other distro specific location to avoid any
possible risk of clashes or confusion with future mainline behavior)

Thanks,
Andrea

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -45,6 +45,8 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
