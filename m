Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BA2656B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:57:32 -0400 (EDT)
Received: by iajr24 with SMTP id r24so241590iaj.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:57:32 -0700 (PDT)
Date: Thu, 26 Apr 2012 15:57:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: drop page_table_lock to uncharge memcg pages
Message-ID: <alpine.DEB.2.00.1204261556100.15785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

mm->page_table_lock is hotly contested for page fault tests and isn't
necessary to do mem_cgroup_uncharge_page() in do_huge_pmd_wp_page().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -968,8 +968,10 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_lock(&mm->page_table_lock);
 	put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
+		spin_unlock(&mm->page_table_lock);
 		mem_cgroup_uncharge_page(new_page);
 		put_page(new_page);
+		goto out;
 	} else {
 		pmd_t entry;
 		VM_BUG_ON(!PageHead(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
