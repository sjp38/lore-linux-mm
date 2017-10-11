Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B07026B0270
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m6so5268569qtc.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:53:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g13si962058qtc.18.2017.10.11.06.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:53:29 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BDqoB9034735
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:29 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dhh9wnwpm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:28 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Oct 2017 14:53:25 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 10/22] mm: Protect SPF handler against anon_vma changes
Date: Wed, 11 Oct 2017 15:52:34 +0200
In-Reply-To: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507729966-10660-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

The speculative page fault handler must be protected against anon_vma
changes. This is because page_add_new_anon_rmap() is called during the
speculative path.

In addition, don't try speculative page fault if the VMA don't have an
anon_vma structure allocated because its allocation should be
protected by the mmap_sem.

In __vma_adjust() when importer->anon_vma is set, there is no need to
protect against speculative page faults since speculative page fault
is aborted if the vma->anon_vma is not set.

When calling page_add_new_anon_rmap() vma->anon_vma is necessarily
valid since we checked for it when locking the pte and the anon_vma is
removed once the pte is unlocked. So even if the speculative page
fault handler is running concurrently with do_unmap(), as the pte is
locked in unmap_region() - through unmap_vmas() - and the anon_vma
unlinked later, because we check for the vma sequence counter which is
updated in unmap_page_range() before locking the pte, and then in
free_pgtables() so when locking the pte the change will be detected.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index b2a2c2ef6e0e..681a04f843f0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -618,7 +618,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 * Hide vma from rmap and truncate_pagecache before freeing
 		 * pgtables
 		 */
+		vm_write_begin(vma);
 		unlink_anon_vmas(vma);
+		vm_write_end(vma);
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
@@ -632,7 +634,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
+				vm_write_begin(vma);
 				unlink_anon_vmas(vma);
+				vm_write_end(vma);
 				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
