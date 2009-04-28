From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/5] proc: kpagecount/kpageflags code cleanup
Date: Tue, 28 Apr 2009 09:09:11 +0800
Message-ID: <20090428014920.630861760@intel.com>
References: <20090428010907.912554629@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 378416B00DF
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:50:31 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-fix-out.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Move increments of pfn/out to bottom of the loop.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

--- mm.orig/fs/proc/page.c
+++ mm/fs/proc/page.c
@@ -32,20 +32,22 @@ static ssize_t kpagecount_read(struct fi
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
 
@@ -98,10 +100,10 @@ static ssize_t kpageflags_read(struct fi
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
@@ -119,11 +121,13 @@ static ssize_t kpageflags_read(struct fi
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
