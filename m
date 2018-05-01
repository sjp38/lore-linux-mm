Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D590B6B0006
	for <linux-mm@kvack.org>; Tue,  1 May 2018 18:36:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q15so11392257pff.15
        for <linux-mm@kvack.org>; Tue, 01 May 2018 15:36:44 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w12-v6si8598947pge.165.2018.05.01.15.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 15:36:43 -0700 (PDT)
Subject: Patch "x86/pgtable: Don't set huge PUD/PMD on non-leaf entries" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Tue, 01 May 2018 15:33:11 -0700
Message-ID: <152521399136247@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180411152437.GC15462@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, alexander.levin@microsoft.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, gregkh@linuxfoundation.org, hughd@google.com, jgross@suse.com, jkosina@suse.cz, joro@8bytes.org, jpoimboe@redhat.com, jroedel@suse.de, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, mingo@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pgtable: Don't set huge PUD/PMD on non-leaf entries

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pgtable-don-t-set-huge-pud-pmd-on-non-leaf-entries.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Tue May  1 14:59:17 PDT 2018
From: Joerg Roedel <joro@8bytes.org>
Date: Wed, 11 Apr 2018 17:24:38 +0200
Subject: x86/pgtable: Don't set huge PUD/PMD on non-leaf entries

From: Joerg Roedel <joro@8bytes.org>

[ Upstream commit e3e288121408c3abeed5af60b87b95c847143845 ]

The pmd_set_huge() and pud_set_huge() functions are used from
the generic ioremap() code to establish large mappings where this
is possible.

But the generic ioremap() code does not check whether the
PMD/PUD entries are already populated with a non-leaf entry,
so that any page-table pages these entries point to will be
lost.

Further, on x86-32 with SHARED_KERNEL_PMD=0, this causes a
BUG_ON() in vmalloc_sync_one() when PMD entries are synced
from swapper_pg_dir to the current page-table. This happens
because the PMD entry from swapper_pg_dir was promoted to a
huge-page entry while the current PGD still contains the
non-leaf entry. Because both entries are present and point
to a different page, the BUG_ON() triggers.

This was actually triggered with pti-x32 enabled in a KVM
virtual machine by the graphics driver.

A real and better fix for that would be to improve the
page-table handling in the generic ioremap() code. But that is
out-of-scope for this patch-set and left for later work.

Reported-by: David H. Gutteridge <dhgutteridge@sympatico.ca>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <llong@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180411152437.GC15462@8bytes.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/mm/pgtable.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -1,6 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/mm.h>
 #include <linux/gfp.h>
+#include <linux/hugetlb.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 #include <asm/tlb.h>
@@ -636,6 +637,10 @@ int pud_set_huge(pud_t *pud, phys_addr_t
 	    (mtrr != MTRR_TYPE_WRBACK))
 		return 0;
 
+	/* Bail out if we are we on a populated non-leaf entry: */
+	if (pud_present(*pud) && !pud_huge(*pud))
+		return 0;
+
 	prot = pgprot_4k_2_large(prot);
 
 	set_pte((pte_t *)pud, pfn_pte(
@@ -664,6 +669,10 @@ int pmd_set_huge(pmd_t *pmd, phys_addr_t
 		return 0;
 	}
 
+	/* Bail out if we are we on a populated non-leaf entry: */
+	if (pmd_present(*pmd) && !pmd_huge(*pmd))
+		return 0;
+
 	prot = pgprot_4k_2_large(prot);
 
 	set_pte((pte_t *)pmd, pfn_pte(


Patches currently in stable-queue which might be from joro@8bytes.org are

queue-4.16/x86-apic-set-up-through-local-apic-mode-on-the-boot-cpu-if-noapic-specified.patch
queue-4.16/x86-pgtable-don-t-set-huge-pud-pmd-on-non-leaf-entries.patch
