Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4BD936B00E7
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:19:47 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so8171596bkc.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 00:19:45 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] mm: fix NULL ptr deref when walking hugepages
Date: Wed, 23 May 2012 09:20:43 +0200
Message-Id: <1337757643-18302-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>

A missing vlidation of the value returned by find_vma() could cause a NULL ptr
dereference when walking the pagetable.

This is triggerable from usermode by a simple user by trying to read a
page info out of /proc/pid/pagemap which doesn't exist.

Introduced by commit 025c5b24 ("thp: optimize away unnecessary page table
locking").

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 fs/proc/task_mmu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e564f0..885830b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -820,7 +820,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset;
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
