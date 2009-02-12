Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E9776B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 02:25:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1C7Pecc028410
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Feb 2009 16:25:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0888345DD72
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:25:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32F4745DD78
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:25:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA305E08010
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:25:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A6F5E0800F
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:25:35 +0900 (JST)
Date: Thu, 12 Feb 2009 16:24:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] fix memmap init for handling memory hole
Message-Id: <20090212162421.65bb7aa2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, davem@davemlloft.net, heiko.carstens@de.ibm.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, early_pfn_in_nid(PFN, NID) may returns false if PFN is a hole.
and memmap initialization was not done. This was a trouble for
sparc boot.

To fix this, the PFN should be initialized and marked as PG_reserved.
This patch changes early_pfn_in_nid() return true if PFN is a hole.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/ia64/mm/numa.c    |    2 +-
 include/linux/mmzone.h |    2 +-
 mm/page_alloc.c        |   23 ++++++++++++++++++++---
 3 files changed, 22 insertions(+), 5 deletions(-)

Index: mmotm-2.6.29-Feb11/mm/page_alloc.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/mm/page_alloc.c
+++ mmotm-2.6.29-Feb11/mm/page_alloc.c
@@ -2985,16 +2985,33 @@ int __meminit __early_pfn_to_nid(unsigne
 		if (start_pfn <= pfn && pfn < end_pfn)
 			return early_node_map[i].nid;
 	}
-
-	return 0;
+	/* This is a memory hole */
+	return -1;
 }
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 
 int __meminit early_pfn_to_nid(unsigned long pfn)
 {
-	return __early_pfn_to_nid(pfn);
+	int nid;
+
+	nid = __early_pfn_to_nid(pfn);
+	if (nid >= 0)
+		return nid;
+	/* just returns 0 */
+	return 0;
 }
 
+#ifdef CONFIG_NODES_SPAN_OTHER_NODES
+bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
+{
+	int nid;
+
+	nid = __early_pfn_to_nid(pfn);
+	if (nid >= 0 && nid != node)
+		return false;
+	return true;
+}
+#endif
 
 /* Basic iterator support to walk early_node_map[] */
 #define for_each_active_range_index_in_nid(i, nid) \
Index: mmotm-2.6.29-Feb11/include/linux/mmzone.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/include/linux/mmzone.h
+++ mmotm-2.6.29-Feb11/include/linux/mmzone.h
@@ -1079,7 +1079,7 @@ void sparse_init(void);
 #endif /* CONFIG_SPARSEMEM */
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-#define early_pfn_in_nid(pfn, nid)	(early_pfn_to_nid(pfn) == (nid))
+bool early_pfn_in_nid(unsigned long pfn, int nid);
 #else
 #define early_pfn_in_nid(pfn, nid)	(1)
 #endif
Index: mmotm-2.6.29-Feb11/arch/ia64/mm/numa.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/arch/ia64/mm/numa.c
+++ mmotm-2.6.29-Feb11/arch/ia64/mm/numa.c
@@ -70,7 +70,7 @@ int __meminit __early_pfn_to_nid(unsigne
 			return node_memblk[i].nid;
 	}
 
-	return 0;
+	return -1;
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
