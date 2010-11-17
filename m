Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 819228D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 07:24:42 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oAHCOPuG022004
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:26 -0800
Received: from gyh4 (gyh4.prod.google.com [10.243.50.196])
	by hpaq1.eem.corp.google.com with ESMTP id oAHCONwH001686
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:24 -0800
Received: by gyh4 with SMTP id 4so1112901gyh.33
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:24:23 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
Date: Wed, 17 Nov 2010 04:23:58 -0800
Message-Id: <1289996638-21439-4-git-send-email-walken@google.com>
In-Reply-To: <1289996638-21439-1-git-send-email-walken@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

When faulting in pages for mlock(), we want to break COW for anonymous
or file pages within VM_WRITABLE, non-VM_SHARED vmas. However, there is
no need to write-fault into VM_SHARED vmas since shared file pages can
be mlocked first and dirtied later, when/if they actually get written to.
Skipping the write fault is desirable, as we don't want to unnecessarily
cause these pages to be dirtied and queued for writeback.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/memory.c |    7 ++++++-
 mm/mlock.c  |    7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d4c0c2e..7f45085 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3291,7 +3291,12 @@ int make_pages_present(unsigned long addr, unsigned long end)
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		return -ENOMEM;
-	write = (vma->vm_flags & VM_WRITE) != 0;
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	write = (vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE;
 	BUG_ON(addr >= end);
 	BUG_ON(end > vma->vm_end);
 	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
diff --git a/mm/mlock.c b/mm/mlock.c
index b70919c..4f31864 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -171,7 +171,12 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
 	gup_flags = FOLL_TOUCH | FOLL_GET;
-	if (vma->vm_flags & VM_WRITE)
+	/*
+	 * We want to touch writable mappings with a write fault in order
+	 * to break COW, except for shared mappings because these don't COW
+	 * and we would not want to dirty them for nothing.
+	 */
+	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
 	/* We don't try to access the guard page of a stack vma */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
