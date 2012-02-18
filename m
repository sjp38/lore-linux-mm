Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DA47D6B0137
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 01:19:14 -0500 (EST)
Received: by vcbf13 with SMTP id f13so3935053vcb.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 22:19:13 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 18 Feb 2012 14:19:13 +0800
Message-ID: <CAJd=RBBY8yzH6wk7GFttvukLq0Pxzw_ExCO+F5N5ChQwk1Q94A@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: break COW earlier for resv owner
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>

When a process owning a MAP_PRIVATE mapping fails to COW, due to references
held by a child and insufficient huge page pool, page is unmapped from the
child process to guarantee the original mappers reliability, and the child
may get SIGKILLed if it later faults.

With that guarantee, COW is broken earlier on behalf of owners, and they will
go less page faults.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Feb 14 20:10:46 2012
+++ b/mm/hugetlb.c	Sat Feb 18 13:29:58 2012
@@ -2145,10 +2145,12 @@ int copy_hugetlb_page_range(struct mm_st
 	struct page *ptepage;
 	unsigned long addr;
 	int cow;
+	int owner;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);

 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+	owner = is_vma_resv_set(vma, HPAGE_RESV_OWNER);

 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		src_pte = huge_pte_offset(src, addr);
@@ -2164,10 +2166,19 @@ int copy_hugetlb_page_range(struct mm_st

 		spin_lock(&dst->page_table_lock);
 		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
-		if (!huge_pte_none(huge_ptep_get(src_pte))) {
+		entry = huge_ptep_get(src_pte);
+		if (!huge_pte_none(entry)) {
 			if (cow)
-				huge_ptep_set_wrprotect(src, addr, src_pte);
-			entry = huge_ptep_get(src_pte);
+				if (owner) {
+					/*
+					 * Break COW for resv owner to go less
+					 * page faults later
+					 */
+					entry = huge_pte_wrprotect(entry);
+				} else {
+					huge_ptep_set_wrprotect(src, addr, src_pte);
+					entry = huge_ptep_get(src_pte);
+				}
 			ptepage = pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
