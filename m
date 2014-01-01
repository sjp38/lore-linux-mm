Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C1B316B0031
	for <linux-mm@kvack.org>; Wed,  1 Jan 2014 04:54:09 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so13081431pdj.40
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 01:54:09 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id ng9si10038815pbc.256.2014.01.01.01.54.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jan 2014 01:54:08 -0800 (PST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 1 Jan 2014 19:54:04 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id ADBB12CE8040
	for <linux-mm@kvack.org>; Wed,  1 Jan 2014 20:54:00 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s019ZMot52428812
	for <linux-mm@kvack.org>; Wed, 1 Jan 2014 20:35:23 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s019rxt5008162
	for <linux-mm@kvack.org>; Wed, 1 Jan 2014 20:53:59 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] powerpc: thp: Fix crash on mremap
Date: Wed,  1 Jan 2014 15:23:47 +0530
Message-Id: <1388570027-22933-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch fix the below crash

NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
LR [c0000000000439ac] .hash_page+0x18c/0x5e0
...
Call Trace:
[c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
[437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
[437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58

On ppc64 we use the pgtable for storing the hpte slot information and
store address to the pgtable at a constant offset (PTRS_PER_PMD) from
pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
from new pmd.

We also want to move the withdraw and deposit before the set_pmd so
that, when page fault find the pmd as trans huge we can be sure that
pgtable can be located at the offset.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
NOTE:
For other archs we would just be removing the pgtable from the list and adding it back.
I didn't find an easy way to make it not do that without lots of #ifdef around. Any
suggestion around that is welcome.

 mm/huge_memory.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7de1bf85f683..eb2e60d9ba45 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1500,24 +1500,23 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	 */
 	ret = __pmd_trans_huge_lock(old_pmd, vma, &old_ptl);
 	if (ret == 1) {
+		pgtable_t pgtable;
+
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
+		/*
+		 * Archs like ppc64 use pgtable to store per pmd
+		 * specific information. So when we switch the pmd,
+		 * we should also withdraw and deposit the pgtable
+		 */
+		pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
+		pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
 		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
-		if (new_ptl != old_ptl) {
-			pgtable_t pgtable;
-
-			/*
-			 * Move preallocated PTE page table if new_pmd is on
-			 * different PMD page table.
-			 */
-			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
-			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
-
+		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
-		}
 		spin_unlock(old_ptl);
 	}
 out:
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
