Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B33D9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 21:10:43 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] mm/huge_memory.c: quiet sparse noise
Date: Thu, 22 Sep 2011 18:10:05 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <201109221810.05542.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, kamezawa.hiroyu@jp.fujitsu.com

Quiet the sparse noise:

warning: symbol 'khugepaged_scan' was not declared. Should it be static?
warning: context imbalance in 'khugepaged_scan_mm_slot' - unexpected unlock

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6b072bd..44f5763 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -89,7 +89,8 @@ struct khugepaged_scan {
 	struct list_head mm_head;
 	struct mm_slot *mm_slot;
 	unsigned long address;
-} khugepaged_scan = {
+};
+static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
@@ -2069,6 +2070,8 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 
 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 					    struct page **hpage)
+	__releases(&khugepaged_mm_lock)
+	__acquires(&khugepaged_mm_lock)
 {
 	struct mm_slot *mm_slot;
 	struct mm_struct *mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
