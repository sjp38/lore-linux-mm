Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 64CA56B01E8
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:28:59 -0400 (EDT)
Date: Wed, 26 May 2010 11:25:05 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 1/5] rename anon_vma_lock to vma_lock_anon_vma
Message-ID: <20100526112505.1bddf24d@annuminas.surriel.com>
In-Reply-To: <20100526112403.635be0ed@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com>
	<20100513140919.0a037845.akpm@linux-foundation.org>
	<4BFC9CCF.6000809@redhat.com>
	<20100526112403.635be0ed@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Subject: rename anon_vma_lock to vma_lock_anon_vma

Rename anon_vma_lock to vma_lock_anon_vma.  This matches the
naming style used in page_lock_anon_vma and will come in really
handy further down in this patch series.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h |    4 ++--
 mm/mmap.c            |   14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6.34/include/linux/rmap.h
===================================================================
--- linux-2.6.34.orig/include/linux/rmap.h
+++ linux-2.6.34/include/linux/rmap.h
@@ -99,14 +99,14 @@ static inline struct anon_vma *page_anon
 	return page_rmapping(page);
 }
 
-static inline void anon_vma_lock(struct vm_area_struct *vma)
+static inline void vma_lock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
 		spin_lock(&anon_vma->lock);
 }
 
-static inline void anon_vma_unlock(struct vm_area_struct *vma)
+static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
Index: linux-2.6.34/mm/mmap.c
===================================================================
--- linux-2.6.34.orig/mm/mmap.c
+++ linux-2.6.34/mm/mmap.c
@@ -452,12 +452,12 @@ static void vma_link(struct mm_struct *m
 		spin_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
-	anon_vma_lock(vma);
+	vma_lock_anon_vma(vma);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
 
-	anon_vma_unlock(vma);
+	vma_unlock_anon_vma(vma);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
@@ -1710,7 +1710,7 @@ int expand_upwards(struct vm_area_struct
 	 */
 	if (unlikely(anon_vma_prepare(vma)))
 		return -ENOMEM;
-	anon_vma_lock(vma);
+	vma_lock_anon_vma(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1721,7 +1721,7 @@ int expand_upwards(struct vm_area_struct
 	if (address < PAGE_ALIGN(address+4))
 		address = PAGE_ALIGN(address+4);
 	else {
-		anon_vma_unlock(vma);
+		vma_unlock_anon_vma(vma);
 		return -ENOMEM;
 	}
 	error = 0;
@@ -1737,7 +1737,7 @@ int expand_upwards(struct vm_area_struct
 		if (!error)
 			vma->vm_end = address;
 	}
-	anon_vma_unlock(vma);
+	vma_unlock_anon_vma(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1762,7 +1762,7 @@ static int expand_downwards(struct vm_ar
 	if (error)
 		return error;
 
-	anon_vma_lock(vma);
+	vma_lock_anon_vma(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1783,7 +1783,7 @@ static int expand_downwards(struct vm_ar
 			vma->vm_pgoff -= grow;
 		}
 	}
-	anon_vma_unlock(vma);
+	vma_unlock_anon_vma(vma);
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
