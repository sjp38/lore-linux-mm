Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2PKhwoK003081
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 15:43:58 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2PKhwgv091900
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 15:43:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2PKhwiF015775
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 15:43:58 -0500
Subject: resubmit - [PATCH 1/4] sparsemem base: early_pfn_to_nid() (works before sparse is initialized)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 25 Mar 2005 12:43:56 -0800
Message-Id: <E1DEvev-0004Pa-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

We _know_ which node pages in general belong to, at least at a
very gross level in node_{start,end}_pfn[].  Use those to target
the allocations of pages.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/discontig.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+)

diff -puN arch/i386/mm/discontig.c~FROM-MM-add-early_pfn_to_nid arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~FROM-MM-add-early_pfn_to_nid	2005-03-25 08:17:12.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2005-03-25 08:17:12.000000000 -0800
@@ -149,6 +149,21 @@ static void __init find_max_pfn_node(int
 		BUG();
 }
 
+/* Find the owning node for a pfn. */
+int early_pfn_to_nid(unsigned long pfn)
+{
+	int nid;
+
+	for_each_node(nid) {
+		if (node_end_pfn[nid] == 0)
+			break;
+		if (node_start_pfn[nid] <= pfn && node_end_pfn[nid] >= pfn)
+			return nid;
+	}
+
+	return 0;
+}
+
 /* 
  * Allocate memory for the pg_data_t for this node via a crude pre-bootmem
  * method.  For node zero take this from the bottom of memory, for
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
