Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF208D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 04:09:06 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p2E88xSp011487
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 01:08:59 -0700
Received: from iyf13 (iyf13.prod.google.com [10.241.50.77])
	by kpbe12.cbf.corp.google.com with ESMTP id p2E88uD8019323
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 01:08:58 -0700
Received: by iyf13 with SMTP id 13so6086582iyf.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 01:08:56 -0700 (PDT)
Date: Mon, 14 Mar 2011 01:08:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
Message-ID: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

THP's collapse_huge_page() has an understandable but ugly difference
in when its huge page is allocated: inside if NUMA but outside if not.
It's hardly surprising that the memcg failure path forgot that, freeing
the page in the non-NUMA case, then hitting a VM_BUG_ON in get_page()
(or even worse, using the freed page).

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- 2.6.38-rc8/mm/huge_memory.c	2011-03-08 09:27:16.000000000 -0800
+++ linux/mm/huge_memory.c	2011-03-13 18:26:21.000000000 -0700
@@ -1762,6 +1762,10 @@ static void collapse_huge_page(struct mm
 #ifndef CONFIG_NUMA
 	VM_BUG_ON(!*hpage);
 	new_page = *hpage;
+	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
+		up_read(&mm->mmap_sem);
+		return;
+	}
 #else
 	VM_BUG_ON(*hpage);
 	/*
@@ -1781,12 +1785,12 @@ static void collapse_huge_page(struct mm
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
-#endif
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		up_read(&mm->mmap_sem);
 		put_page(new_page);
 		return;
 	}
+#endif
 
 	/* after allocating the hugepage upgrade to mmap_sem write mode */
 	up_read(&mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
