Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CA1E16B005D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:44:21 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id uo1so1599905pbc.3
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 17:44:21 -0800 (PST)
Date: Wed, 19 Dec 2012 17:44:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] ksm: make rmap walks more scalable
In-Reply-To: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1212191742440.25409@eggly.anvils>
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The rmap walks in ksm.c are like those in rmap.c:
they can safely be done with anon_vma_lock_read().

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/ksm.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- 3.7+git/mm/ksm.c	2012-12-16 16:35:08.752441527 -0800
+++ linux/mm/ksm.c	2012-12-19 16:58:05.292145790 -0800
@@ -1624,7 +1624,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock_write(anon_vma);
+		anon_vma_lock_read(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
@@ -1648,7 +1648,7 @@ again:
 			if (!search_new_forks || !mapcount)
 				break;
 		}
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 		if (!mapcount)
 			goto out;
 	}
@@ -1678,7 +1678,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock_write(anon_vma);
+		anon_vma_lock_read(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
@@ -1697,11 +1697,11 @@ again:
 			ret = try_to_unmap_one(page, vma,
 					rmap_item->address, flags);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
-				anon_vma_unlock(anon_vma);
+				anon_vma_unlock_read(anon_vma);
 				goto out;
 			}
 		}
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 	}
 	if (!search_new_forks++)
 		goto again;
@@ -1731,7 +1731,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock_write(anon_vma);
+		anon_vma_lock_read(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
@@ -1749,11 +1749,11 @@ again:
 
 			ret = rmap_one(page, vma, rmap_item->address, arg);
 			if (ret != SWAP_AGAIN) {
-				anon_vma_unlock(anon_vma);
+				anon_vma_unlock_read(anon_vma);
 				goto out;
 			}
 		}
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 	}
 	if (!search_new_forks++)
 		goto again;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
