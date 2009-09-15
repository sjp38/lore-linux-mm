Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D16166B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:47:14 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8FAjIH8009728
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:45:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8FAlD8e201062
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:47:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8FAlD82013028
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:47:13 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH] Fix for hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch in -mm
Date: Tue, 15 Sep 2009 11:46:53 +0100
Message-Id: <1253011613-6429-1-git-send-email-ebmunson@us.ibm.com>
In-Reply-To: <1252487811-9205-1-git-send-email-ebmunson@us.ibm.com>
References: <1252487811-9205-1-git-send-email-ebmunson@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com> <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com> <1721a3e8bdf8f311d2388951ec65a24d37b513b1.1251282769.git.ebmunson@us.ibm.com> <Pine.LNX.4.64.0908312036410.16402@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, hugh.dickins@tiscali.co.uk, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Resending because this seems to have fallen between the cracks.

The patch
hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch
used the value 0x40 for MAP_HUGETLB which is the same value used for
various other flags on some architectures.  This collision causes
unexpected use of huge pages in the best case and mmap to fail with
ENOMEM or ENOSYS in the worst.  This patch changes the value for
MAP_HUGETLB to a value that is not currently used on any arch.

This patch should be considered a fix to
hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch.

Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 include/asm-generic/mman-common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
index 12f5982..e6adb68 100644
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -19,7 +19,7 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
-#define MAP_HUGETLB	0x40		/* create a huge page mapping */
+#define MAP_HUGETLB	0x080000	/* create a huge page mapping */
 
 #define MS_ASYNC	1		/* sync memory asynchronously */
 #define MS_INVALIDATE	2		/* invalidate the caches */
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
