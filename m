From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/7] proc: kpagecount/kpageflags code cleanup
Date: Thu, 07 May 2009 09:21:20 +0800
Message-ID: <20090507014914.244032831@intel.com>
References: <20090507012116.996644836@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F10656B004F
	for <linux-mm@kvack.org>; Wed,  6 May 2009 21:49:54 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-fix-out.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Move increments of pfn/out to bottom of the loop.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

--- linux.orig/fs/proc/page.c
+++ linux/fs/proc/page.c
@@ -11,6 +11,7 @@
 
 #define KPMSIZE sizeof(u64)
 #define KPMMASK (KPMSIZE - 1)
+
 /* /proc/kpagecount - an array exposing page counts
  *
  * Each entry is a u64 representing the corresponding
@@ -32,20 +33,22 @@ static ssize_t kpagecount_read(struct fi
 		return -EINVAL;
 
 	while (count > 0) {
-		ppage = NULL;
 		if (pfn_valid(pfn))
 			ppage = pfn_to_page(pfn);
-		pfn++;
+		else
+			ppage = NULL;
 		if (!ppage)
 			pcount = 0;
 		else
 			pcount = page_mapcount(ppage);
 
-		if (put_user(pcount, out++)) {
+		if (put_user(pcount, out)) {
 			ret = -EFAULT;
 			break;
 		}
 
+		pfn++;
+		out++;
 		count -= KPMSIZE;
 	}
 
@@ -98,10 +101,10 @@ static ssize_t kpageflags_read(struct fi
 		return -EINVAL;
 
 	while (count > 0) {
-		ppage = NULL;
 		if (pfn_valid(pfn))
 			ppage = pfn_to_page(pfn);
-		pfn++;
+		else
+			ppage = NULL;
 		if (!ppage)
 			kflags = 0;
 		else
@@ -119,11 +122,13 @@ static ssize_t kpageflags_read(struct fi
 			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
 			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
 
-		if (put_user(uflags, out++)) {
+		if (put_user(uflags, out)) {
 			ret = -EFAULT;
 			break;
 		}
 
+		pfn++;
+		out++;
 		count -= KPMSIZE;
 	}
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
