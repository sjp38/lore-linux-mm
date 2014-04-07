Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id E4E066B0038
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:10:51 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t61so6805527wes.2
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:10:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt9si6341492wjc.180.2014.04.07.08.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:10:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: Allow FOLL_NUMA on FOLL_FORCE
Date: Mon,  7 Apr 2014 16:10:43 +0100
Message-Id: <1396883443-11696-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1396883443-11696-1-git-send-email-mgorman@suse.de>
References: <1396883443-11696-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

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
