Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E69A6B0139
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 01:03:30 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p5653SAZ007625
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 22:03:28 -0700
Received: from iwl42 (iwl42.prod.google.com [10.241.67.234])
	by kpbe19.cbf.corp.google.com with ESMTP id p5653O9T025011
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 22:03:26 -0700
Received: by iwl42 with SMTP id 42so3904347iwl.4
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 22:03:24 -0700 (PDT)
Date: Sun, 5 Jun 2011 22:03:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix ENOSPC returned by handle_mm_fault()
In-Reply-To: <20110605221344.GJ11521@ZenIV.linux.org.uk>
Message-ID: <alpine.LSU.2.00.1106052145370.17285@sister.anvils>
References: <20110605134317.GF11521@ZenIV.linux.org.uk> <alpine.LSU.2.00.1106051141570.5792@sister.anvils> <20110605195025.GH11521@ZenIV.linux.org.uk> <alpine.LSU.2.00.1106051339001.8317@sister.anvils> <20110605221344.GJ11521@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Al Viro observes that in the hugetlb case, handle_mm_fault() may return
a value of the kind ENOSPC when its caller is expecting a value of the
kind VM_FAULT_SIGBUS: fix alloc_huge_page()'s failure returns.

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
Cc: stable@kernel.org
---

 mm/hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 3.0-rc1/mm/hugetlb.c	2011-05-29 18:42:37.425882575 -0700
+++ linux/mm/hugetlb.c	2011-06-05 13:33:22.795341004 -0700
@@ -1033,10 +1033,10 @@ static struct page *alloc_huge_page(stru
 	 */
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
-		return ERR_PTR(chg);
+		return ERR_PTR(-VM_FAULT_OOM);
 	if (chg)
 		if (hugetlb_get_quota(inode->i_mapping, chg))
-			return ERR_PTR(-ENOSPC);
+			return ERR_PTR(-VM_FAULT_SIGBUS);
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
