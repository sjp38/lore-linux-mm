Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 1575A6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 08:45:53 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so10420823wgb.26
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 05:45:51 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 20 Dec 2011 21:45:51 +0800
Message-ID: <CAJd=RBDC9hxAFbbTvSWVa=t1kuyBH8=UoTYxRDtDm6iXLGkQWg@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: fix pgoff computation when unmapping page from vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The computation for pgoff is incorrect, at least with

	(vma->vm_pgoff >> PAGE_SHIFT)

involved. It is fixed with the available method if HPAGE_SIZE is concerned in
page cache lookup.

Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
+++ b/mm/hugetlb.c	Tue Dec 20 21:40:44 2011
@@ -2315,8 +2315,7 @@ static int unmap_ref_private(struct mm_s
 	 * from page cache lookup which is in HPAGE_SIZE units.
 	 */
 	address = address & huge_page_mask(h);
-	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT)
-		+ (vma->vm_pgoff >> PAGE_SHIFT);
+	pgoff = linear_hugepage_index(vma, address);
 	mapping = (struct address_space *)page_private(page);

 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
