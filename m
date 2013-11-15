Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 375A46B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 12:48:11 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so3966889pab.28
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 09:48:10 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id hk1si2642766pbb.71.2013.11.15.09.48.09
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 09:48:09 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] mm: hugetlb: use get_page_foll in follow_hugetlb_page
Date: Fri, 15 Nov 2013 18:47:47 +0100
Message-Id: <1384537668-10283-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

get_page_foll is more optimal and is always safe to use under the PT
lock. More so for hugetlbfs as there's no risk of race conditions with
split_huge_page regardless of the PT lock.

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
