Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id 087966B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 04:25:52 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id jy17so6010567qeb.16
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 01:25:52 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id u9si13918676qap.186.2014.01.12.01.25.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 01:25:52 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id fb1so4950715pad.0
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 01:25:50 -0800 (PST)
Date: Sun, 12 Jan 2014 01:25:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] thp: fix copy_page_rep GPF by testing is_huge_zero_pmd once
 only
Message-ID: <alpine.LSU.2.11.1401120112500.4070@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We see General Protection Fault on RSI in copy_page_rep:
that RSI is what you get from a NULL struct page pointer.

RIP: 0010:[<ffffffff81154955>]  [<ffffffff81154955>] copy_page_rep+0x5/0x10
RSP: 0000:ffff880136e15c00  EFLAGS: 00010286
RAX: ffff880000000000 RBX: ffff880136e14000 RCX: 0000000000000200
RDX: 6db6db6db6db6db7 RSI: db73880000000000 RDI: ffff880dd0c00000
RBP: ffff880136e15c18 R08: 0000000000000200 R09: 000000000005987c
R10: 000000000005987c R11: 0000000000000200 R12: 0000000000000001
R13: ffffea00305aa000 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f195752f700(0000) GS:ffff880c7fc20000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000093010000 CR3: 00000001458e1000 CR4: 00000000000027e0
Call Trace:
 [<ffffffff810f2835>] ? copy_user_highpage.isra.43+0x65/0x80
 [<ffffffff812654b2>] copy_user_huge_page+0x93/0xab
 [<ffffffff8127cc76>] do_huge_pmd_wp_page+0x710/0x815
 [<ffffffff81055ab8>] handle_mm_fault+0x15d8/0x1d70
 [<ffffffff814f909d>] __do_page_fault+0x14d/0x840
 [<ffffffff810a13ad>] ? SYSC_recvfrom+0x10d/0x210
 [<ffffffff814f97bf>] do_page_fault+0x2f/0x90
 [<ffffffff814f6032>] page_fault+0x22/0x30

do_huge_pmd_wp_page() tests is_huge_zero_pmd(orig_pmd) four times:
but since shrink_huge_zero_page() can free the huge_zero_page, and
we have no hold of our own on it here (except where the fourth test
holds page_table_lock and has checked pmd_same), it's possible for
it to answer yes the first time, but no to the second or third test.
Change all those last three to tests for NULL page.

(Note: this is not the same issue as trinity's DEBUG_PAGEALLOC BUG
in copy_page_rep with RSI: ffff88009c422000, reported by Sasha Levin
in https://lkml.org/lkml/2013/3/29/103.  I believe that one is due
to the source page being split, and a tail page freed, while copy
is in progress; and not a problem without DEBUG_PAGEALLOC, since
the pmd_same check will prevent a miscopy from being made visible.)

Fixes: 97ae17497e99 ("thp: implement refcounting for huge zero page")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # v3.10 v3.11 v3.12
---

 mm/huge_memory.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- 3.13-rc7/mm/huge_memory.c	2014-01-04 22:30:56.388815704 -0800
+++ linux/mm/huge_memory.c	2014-01-12 00:54:09.292491631 -0800
@@ -1154,7 +1154,7 @@ alloc:
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
-		if (is_huge_zero_pmd(orig_pmd)) {
+		if (!page) {
 			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
 					address, pmd, orig_pmd, haddr);
 		} else {
@@ -1181,7 +1181,7 @@ alloc:
 
 	count_vm_event(THP_FAULT_ALLOC);
 
-	if (is_huge_zero_pmd(orig_pmd))
+	if (!page)
 		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
 	else
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
@@ -1207,7 +1207,7 @@ alloc:
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache_pmd(vma, address, pmd);
-		if (is_huge_zero_pmd(orig_pmd)) {
+		if (!page) {
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
