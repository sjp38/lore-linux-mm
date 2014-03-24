Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA106B00C4
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 08:59:37 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id p9so3619915lbv.18
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:37 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id h4si10190616lae.4.2014.03.24.05.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 05:59:36 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id u14so3574412lbd.19
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:35 -0700 (PDT)
Message-Id: <20140324125926.204897920@openvz.org>
Date: Mon, 24 Mar 2014 16:28:42 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 4/4] mm: Clear VM_SOFTDIRTY flag inside clear_refs_write instead of clear_soft_dirty
References: <20140324122838.490106581@openvz.org>
Content-Disposition: inline; filename=mm-vma-softdirty-clean-vma-softdirty-bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com, xemul@parallels.com, akpm@linux-foundation.org, gorcunov@openvz.org

The clear_refs_write is called earlier than clear_soft_dirty and it is
more natural to clear VM_SOFTDIRTY (which belongs to VMA entry but not
PTEs) that early instead of clearing it a way deeper inside call chain.

CC: Pavel Emelyanov <xemul@parallels.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/task_mmu.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux-2.6.git/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.git.orig/fs/proc/task_mmu.c
+++ linux-2.6.git/fs/proc/task_mmu.c
@@ -736,9 +736,6 @@ static inline void clear_soft_dirty(stru
 		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
-	if (vma->vm_flags & VM_SOFTDIRTY)
-		vma->vm_flags &= ~VM_SOFTDIRTY;
-
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
 #endif
 }
@@ -843,6 +840,10 @@ static ssize_t clear_refs_write(struct f
 				continue;
 			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
 				continue;
+			if (type == CLEAR_REFS_SOFT_DIRTY) {
+				if (vma->vm_flags & VM_SOFTDIRTY)
+					vma->vm_flags &= ~VM_SOFTDIRTY;
+			}
 			walk_page_range(vma->vm_start, vma->vm_end,
 					&clear_refs_walk);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
