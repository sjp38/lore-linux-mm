Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D421E6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:22:24 -0400 (EDT)
Date: Fri, 27 May 2011 00:22:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
Message-ID: <20110526222218.GS19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

Subject: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n

From: Andrea Arcangeli <aarcange@redhat.com>

Johannes noticed the vmstat update is already taken care of by
khugepaged_alloc_hugepage() internally. The only places that are
required to update the vmstat are the callers of alloc_hugepage
(callers of khugepaged_alloc_hugepage aren't).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/huge_memory.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2233,11 +2233,8 @@ static void khugepaged_loop(void)
 	while (likely(khugepaged_enabled())) {
 #ifndef CONFIG_NUMA
 		hpage = khugepaged_alloc_hugepage();
-		if (unlikely(!hpage)) {
-			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
+		if (unlikely(!hpage))
 			break;
-		}
-		count_vm_event(THP_COLLAPSE_ALLOC);
 #else
 		if (IS_ERR(hpage)) {
 			khugepaged_alloc_sleep();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
