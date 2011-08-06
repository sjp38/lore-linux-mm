Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 541316B016A
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 14:18:43 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 1 of 3] mremap: check for overflow using deltas
Message-Id: <d244e0b6060fdeac2ab6.1312649883@localhost>
In-Reply-To: <patchbomb.1312649882@localhost>
References: <patchbomb.1312649882@localhost>
Date: Sat, 06 Aug 2011 18:58:03 +0200
From: aarcange@redhat.com
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

From: Andrea Arcangeli <aarcange@redhat.com>

Using "- 1" relies on the old_end to be page aligned and PAGE_SIZE > 1, those
are reasonable requirements but the check remains obscure and it looks more
like an off by one error than an overflow check. This I feel will improve
readibility.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -141,9 +141,10 @@ unsigned long move_page_tables(struct vm
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
-		if (next - 1 > old_end)
-			next = old_end;
+		/* even if next overflowed, extent below will be ok */
 		extent = next - old_addr;
+		if (extent > old_end - old_addr)
+			extent = old_end - old_addr;
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
