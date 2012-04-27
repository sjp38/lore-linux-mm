Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D365C6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 23:41:50 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 27 Apr 2012 03:23:09 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3R3Z2q91622174
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:35:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3R3fkUf010695
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:41:46 +1000
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/2] MM: fixup on addition to bootmem data list
Date: Fri, 27 Apr 2012 11:41:43 +0800
Message-Id: <1335498104-31900-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: shangw@linux.vnet.ibm.com

The objects of "struct bootmem_data_t" are being linked together
to form double-linked list sequentially based on its minimal page
frame number. Current implementation implicitly supports the
following cases, which means the inserting point for current bootmem
data depends on how "list_for_each" works. That makes the code a
little hard to read. Besides, "list_for_each" and "list_entry" can
be replaced with "list_for_each_entry".

	- The linked list is empty.
	- There has no entry in the linked list, whose minimal page
	  frame number is bigger than current one.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/bootmem.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0131170..5a04536 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -77,16 +77,16 @@ unsigned long __init bootmem_bootmap_pages(unsigned long pages)
  */
 static void __init link_bootmem(bootmem_data_t *bdata)
 {
-	struct list_head *iter;
+	bootmem_data_t *ent;
 
-	list_for_each(iter, &bdata_list) {
-		bootmem_data_t *ent;
-
-		ent = list_entry(iter, bootmem_data_t, list);
-		if (bdata->node_min_pfn < ent->node_min_pfn)
-			break;
+	list_for_each_entry(ent, &bdata_list, list) {
+		if (bdata->node_min_pfn < ent->node_min_pfn) {
+			list_add_tail(&bdata->list, &ent->list);
+			return;
+		}
 	}
-	list_add_tail(&bdata->list, iter);
+
+	list_add_tail(&bdata->list, &bdata_list);
 }
 
 /*
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
