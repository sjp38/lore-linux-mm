Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA10A6B0035
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:38 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so4064157eak.2
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r3si2749751eep.355.2013.11.20.09.51.37
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:37 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/8] mm: hugetlb: use get_page_foll in follow_hugetlb_page
Date: Wed, 20 Nov 2013 18:51:10 +0100
Message-Id: <1384969876-6374-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
References: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

get_page_foll is more optimal and is always safe to use under the PT
lock. More so for hugetlbfs as there's no risk of race conditions with
split_huge_page regardless of the PT lock.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 14737f8e..f03e068 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3113,7 +3113,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
-			get_page(pages[i]);
+			get_page_foll(pages[i]);
 		}
 
 		if (vmas)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
