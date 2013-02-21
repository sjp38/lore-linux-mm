Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id D22346B0024
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:26:21 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id hz1so4540641pad.38
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:26:21 -0800 (PST)
Date: Thu, 21 Feb 2013 00:25:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/7] mm,ksm: swapoff might need to copy
In-Reply-To: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1302210023350.17843@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Before establishing that KSM page migration was the cause of my
WARN_ON_ONCE(page_mapped(page))s, I suspected that they came from the
lack of a ksm_might_need_to_copy() in swapoff's unuse_pte() - which
in many respects is equivalent to faulting in a page.

In fact I've never caught that as the cause: but in theory it does
at least need the KSM_RUN_UNMERGE check in ksm_might_need_to_copy(),
to avoid bringing a KSM page back in when it's not supposed to be.

I intended to copy how it's done in do_swap_page(), but have a strong
aversion to how "swapcache" ends up being used there: rework it with
"page != swapcache".

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/swapfile.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

--- mmotm.orig/mm/swapfile.c	2013-02-20 22:28:09.076001048 -0800
+++ mmotm/mm/swapfile.c	2013-02-20 23:20:50.872076192 -0800
@@ -874,11 +874,17 @@ unsigned int count_swap_pages(int type,
 static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
+	struct page *swapcache;
 	struct mem_cgroup *memcg;
 	spinlock_t *ptl;
 	pte_t *pte;
 	int ret = 1;
 
+	swapcache = page;
+	page = ksm_might_need_to_copy(page, vma, addr);
+	if (unlikely(!page))
+		return -ENOMEM;
+
 	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
 					 GFP_KERNEL, &memcg)) {
 		ret = -ENOMEM;
@@ -897,7 +903,10 @@ static int unuse_pte(struct vm_area_stru
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_anon_rmap(page, vma, addr);
+	if (page == swapcache)
+		page_add_anon_rmap(page, vma, addr);
+	else /* ksm created a completely new copy */
+		page_add_new_anon_rmap(page, vma, addr);
 	mem_cgroup_commit_charge_swapin(page, memcg);
 	swap_free(entry);
 	/*
@@ -908,6 +917,10 @@ static int unuse_pte(struct vm_area_stru
 out:
 	pte_unmap_unlock(pte, ptl);
 out_nolock:
+	if (page != swapcache) {
+		unlock_page(page);
+		put_page(page);
+	}
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
