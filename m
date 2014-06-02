Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE536B003C
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so3826085pdj.12
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xp2si17357178pbc.57.2014.06.02.14.36.54
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:54 -0700 (PDT)
Subject: [PATCH 07/10] mm: pagewalk: kill check for hugetlbfs inside /proc pagemap code
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:53 -0700
References: <20140602213644.925A26D0@viggo.jf.intel.com>
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
Message-Id: <20140602213653.4520DC58@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The page map code does not call the normal handlers for hugetlbfs
areas.  They are handled by ->hugetlb_entry exclusively, so
remove the check for it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/fs/proc/task_mmu.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~do-not-check-for-hugetlbfs-inside-pagemap-walker fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~do-not-check-for-hugetlbfs-inside-pagemap-walker	2014-06-02 14:20:20.693870160 -0700
+++ b/fs/proc/task_mmu.c	2014-06-02 14:20:20.697870340 -0700
@@ -1033,8 +1033,7 @@ static int pagemap_pte_range(pmd_t *pmd,
 
 		/* check that 'vma' actually covers this address,
 		 * and that it isn't a huge page vma */
-		if (vma && (vma->vm_start <= addr) &&
-		    !is_vm_hugetlb_page(vma)) {
+		if (vma && (vma->vm_start <= addr)) {
 			pte = pte_offset_map(pmd, addr);
 			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
 			/* unmap before userspace copy */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
