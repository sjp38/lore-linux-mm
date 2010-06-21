Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5F18E6B01C7
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:39:53 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:33:37 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 1/6] mmap: remove unnecessary lock from __vma_link
Message-ID: <20100621163337.5781bbc2@annuminas.surriel.com>
In-Reply-To: <20100621163146.4e4e30cb@annuminas.surriel.com>
References: <20100621163146.4e4e30cb@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>
Subject: remove unnecessary lock from __vma_link

There's no anon-vma related mangling happening inside __vma_link anymore so no
need of anon_vma locking there.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -469,12 +469,10 @@ static void vma_link(struct mm_struct *m
 		spin_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
-	vma_lock_anon_vma(vma);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
 
-	vma_unlock_anon_vma(vma);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
