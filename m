Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2DF6B03AE
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 12:56:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t3so30030772wme.9
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:56:16 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e7si16363792wrd.354.2017.07.05.09.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 09:56:15 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id j85so33734887wmj.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:56:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes in the stack
Date: Wed,  5 Jul 2017 18:56:02 +0200
Message-Id: <20170705165602.15005-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

"mm: enlarge stack guard gap" has introduced a regression in some rust
and Java environments which are trying to implement their own stack
guard page.  They are punching a new MAP_FIXED mapping inside the
existing stack Vma.

This will confuse expand_{downwards,upwards} into thinking that the stack
expansion would in fact get us too close to an existing non-stack vma
which is a correct behavior wrt. safety. It is a real regression on
the other hand. Let's work around the problem by considering PROT_NONE
mapping as a part of the stack. This is a gros hack but overflowing to
such a mapping would trap anyway an we only can hope that usespace
knows what it is doing and handle it propely.

Fixes: d4d2d35e6ef9 ("mm: larger stack guard gap, between vmas")
Debugged-by: Vlastimil Babka <vbabka@suse.cz>
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
the original thread [1] has grown quite large and also a bit confusing.
At least the rust part should be fixed by this patch. 32b java will
probably need something more on top of this. Btw. JNI environments rely
on MAP_FIXED PROT_NONE as well they were just lucky to not hit the issue
yet I guess.

[1] http://lkml.kernel.org/r/1499126133.2707.20.camel@decadent.org.uk
 mm/mmap.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f60a8bc2869c..2e996cbf4ff3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2244,7 +2244,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		gap_addr = TASK_SIZE;
 
 	next = vma->vm_next;
-	if (next && next->vm_start < gap_addr) {
+	if (next && next->vm_start < gap_addr &&
+			(next->vm_flags & (VM_WRITE|VM_READ|VM_EXEC))) {
 		if (!(next->vm_flags & VM_GROWSUP))
 			return -ENOMEM;
 		/* Check that both stack segments have the same anon_vma? */
@@ -2325,7 +2326,8 @@ int expand_downwards(struct vm_area_struct *vma,
 	/* Enforce stack_guard_gap */
 	prev = vma->vm_prev;
 	/* Check that both stack segments have the same anon_vma? */
-	if (prev && !(prev->vm_flags & VM_GROWSDOWN)) {
+	if (prev && !(prev->vm_flags & VM_GROWSDOWN) &&
+			(prev->vm_flags & (VM_WRITE|VM_READ|VM_EXEC))) {
 		if (address - prev->vm_end < stack_guard_gap)
 			return -ENOMEM;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
