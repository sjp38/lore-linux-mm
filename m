Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 37FAA6B007D
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 06:33:47 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so634462dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:33:46 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 6/6] mm: fix cache coloring on x86_64
Date: Wed, 31 Oct 2012 03:33:25 -0700
Message-Id: <1351679605-4816-7-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-1-git-send-email-walken@google.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@surriel.com>

From: Rik van Riel <riel@surriel.com>

Fix the x86-64 cache alignment code to take pgoff into account.
Use the x86 and MIPS cache alignment code as the basis for a generic
cache alignment function.

The old x86 code will always align the mmap to aliasing boundaries,
even if the program mmaps the file with a non-zero pgoff.

If program A mmaps the file with pgoff 0, and program B mmaps the
file with pgoff 1. The old code would align the mmaps, resulting in
misaligned pages:

A:  0123
B:  123

After this patch, they are aligned so the pages line up:

A: 0123
B:  123

Proposed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/x86/kernel/sys_x86_64.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index fa9227214753..5df5837ce6a3 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -136,7 +136,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.low_limit = begin;
 	info.high_limit = end;
 	info.align_mask = filp ? get_align_mask() : 0;
-	info.align_offset = 0;
+	info.align_offset = pgoff << PAGE_SHIFT;
 	return vm_unmapped_area(&info);
 }
 
@@ -175,7 +175,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.low_limit = 0;  // XXX could be PAGE_SIZE ???
 	info.high_limit = mm->mmap_base;
 	info.align_mask = filp ? get_align_mask() : 0;
-	info.align_offset = 0;
+	info.align_offset = pgoff << PAGE_SHIFT;
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
 		return addr;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
