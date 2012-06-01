Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 01E456B0068
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:55:49 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Y004M271VASB0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:56:19 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Y00I0370XRT@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:55:46 +0100 (BST)
Date: Fri, 01 Jun 2012 18:54:05 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 1/2] proc: fix kpage[count,flags] interfaces to account for
 ARCH_PFN_OFFSET
Message-id: <201206011854.05372.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: fix kpage[count,flags] interfaces to account for ARCH_PFN_OFFSET

ARCH_PFN_OFFSET gives us the first PFN number (i.e. on ARM Exynos4
platform it is equal to 262144) while max_pfn is only the total
number of PFNs (i.e. on ARM Exynos4 Universal C210 board it is equal
to 131072) so currently it is impossible to read page count/flags
values on affected archs/platforms throught /proc/kpage[count,flags]
interfaces.  Fix it by making code aware of ARCH_PFN_OFFSET.

[ For x86 the resulting code remains unchanged as ARCH_PFN_OFFSET
  is eual to 0. ]

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 fs/proc/page.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c	2012-05-31 15:45:27.887110216 +0200
+++ b/fs/proc/page.c	2012-05-31 16:33:37.455109659 +0200
@@ -31,7 +31,8 @@ static ssize_t kpagecount_read(struct fi
 	u64 pcount;
 
 	pfn = src / KPMSIZE;
-	count = min_t(size_t, count, (max_pfn * KPMSIZE) - src);
+	count = min_t(size_t, count,
+		      ((ARCH_PFN_OFFSET + max_pfn) * KPMSIZE) - src);
 	if (src & KPMMASK || count & KPMMASK)
 		return -EINVAL;
 
@@ -174,7 +175,8 @@ static ssize_t kpageflags_read(struct fi
 	ssize_t ret = 0;
 
 	pfn = src / KPMSIZE;
-	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
+	count = min_t(unsigned long, count,
+		      ((ARCH_PFN_OFFSET + max_pfn) * KPMSIZE) - src);
 	if (src & KPMMASK || count & KPMMASK)
 		return -EINVAL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
