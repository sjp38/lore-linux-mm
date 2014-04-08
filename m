Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 40C7D6B009F
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:09:41 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so672628eei.14
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:09:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si2764367eei.28.2014.04.08.06.09.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 06:09:39 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mm: Allow FOLL_NUMA on FOLL_FORCE
Date: Tue,  8 Apr 2014 14:09:28 +0100
Message-Id: <1396962570-18762-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

As _PAGE_NUMA is no longer aliased to _PAGE_PROTNONE there should be no
confusion between them. It should be possible to kick away the special
casing in __get_user_pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 22dfa61..b9c35a7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1714,18 +1714,6 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	vm_flags &= (gup_flags & FOLL_FORCE) ?
 			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 
-	/*
-	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
-	 * would be called on PROT_NONE ranges. We must never invoke
-	 * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
-	 * page faults would unprotect the PROT_NONE ranges if
-	 * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
-	 * bitflag. So to avoid that, don't set FOLL_NUMA if
-	 * FOLL_FORCE is set.
-	 */
-	if (!(gup_flags & FOLL_FORCE))
-		gup_flags |= FOLL_NUMA;
-
 	i = 0;
 
 	do {
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
