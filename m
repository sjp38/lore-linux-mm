Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id DEC766B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 01:57:10 -0400 (EDT)
From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] bootmem: Make ___alloc_bootmem_node_nopanic() to be real nopanic
Date: Wed, 11 Jul 2012 22:56:59 -0700
Message-Id: <1342072619-13357-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <20120711210254.AFF6D20004E@hpza10.eem.corp.google.com>
References: <20120711210254.AFF6D20004E@hpza10.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, stable@vger.kernel.org

after
| From 99ab7b19440a72ebdf225f99b20f8ef40decee86 Mon Sep 17 00:00:00 2001
| Date: Wed, 11 Jul 2012 14:02:53 -0700
| Subject: [PATCH] mm: sparse: fix usemap allocation above node descriptor
 section

Johannes said:
| while backporting the below patch, I realised that your fix busted
| f5bf18fa22f8 again.  The problem was not a panicking version on
| allocation failure but when the usemap size was too large such that
| goal + size > limit triggers the BUG_ON in the bootmem allocator.  So
| we need a version that passes limit ONLY if the usemap is smaller than
| the section.

after checking the code, the name of ___alloc_bootmem_node_nopanic() does not
reflect the fact.

Make bootmem really not panic.

Hope will kill bootmem sooner.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@vger.kernel.org

---
 mm/bootmem.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -710,6 +710,10 @@ again:
 	if (ptr)
 		return ptr;
 
+	/* do not panic in alloc_bootmem_bdata() */
+	if (limit && goal + size > limit)
+		limit = 0;
+
 	ptr = alloc_bootmem_bdata(pgdat->bdata, size, align, goal, limit);
 	if (ptr)
 		return ptr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
