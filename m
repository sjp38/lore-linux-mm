Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 813C86B0078
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 09:48:26 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2986275pbc.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 06:48:23 -0800 (PST)
Date: Tue, 4 Dec 2012 06:48:20 -0800
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH] mm: protect against concurrent vma expansion
Message-ID: <20121204144820.GA13916@google.com>
References: <1354344987-28203-1-git-send-email-walken@google.com>
 <20121203150110.39c204ff.akpm@linux-foundation.org>
 <CANN689FfWVV4MyTUPKZQgQAWW9Dfdw9f0fqx98kc+USKj9g7TA@mail.gmail.com>
 <20121203164322.b967d461.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121203164322.b967d461.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

expand_stack() runs with a shared mmap_sem lock. Because of this, there
could be multiple concurrent stack expansions in the same mm, which may
cause problems in the vma gap update code.

I propose to solve this by taking the mm->page_table_lock around such vma
expansions, in order to avoid the concurrency issue. We only have to worry
about concurrent expand_stack() calls here, since we hold a shared mmap_sem
lock and all vma modificaitons other than expand_stack() are done under
an exclusive mmap_sem lock.

I previously tried to achieve the same effect by making sure all
growable vmas in a given mm would share the same anon_vma, which we
already lock here. However this turned out to be difficult - all of the
schemes I tried for refcounting the growable anon_vma and clearing
turned out ugly. So, I'm now proposing only the minimal fix.

The overhead of taking the page table lock during stack expansion is
expected to be small: glibc doesn't use expandable stacks for the
threads it creates, so having multiple growable stacks is actually
uncommon and we don't expect the page table lock to get bounced
between threads.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 9ed3a06242a0..2b7d9e78a569 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2069,6 +2069,18 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		if (vma->vm_pgoff + (size >> PAGE_SHIFT) >= vma->vm_pgoff) {
 			error = acct_stack_growth(vma, size, grow);
 			if (!error) {
+				/*
+				 * vma_gap_update() doesn't support concurrent
+				 * updates, but we only hold a shared mmap_sem
+				 * lock here, so we need to protect against
+				 * concurrent vma expansions.
+				 * vma_lock_anon_vma() doesn't help here, as
+				 * we don't guarantee that all growable vmas
+				 * in a mm share the same root anon vma.
+				 * So, we reuse mm->page_table_lock to guard
+				 * against concurrent vma expansions.
+				 */
+				spin_lock(&vma->vm_mm->page_table_lock);
 				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_end = address;
 				anon_vma_interval_tree_post_update_vma(vma);
@@ -2076,6 +2088,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 					vma_gap_update(vma->vm_next);
 				else
 					vma->vm_mm->highest_vm_end = address;
+				spin_unlock(&vma->vm_mm->page_table_lock);
+
 				perf_event_mmap(vma);
 			}
 		}
@@ -2126,11 +2140,25 @@ int expand_downwards(struct vm_area_struct *vma,
 		if (grow <= vma->vm_pgoff) {
 			error = acct_stack_growth(vma, size, grow);
 			if (!error) {
+				/*
+				 * vma_gap_update() doesn't support concurrent
+				 * updates, but we only hold a shared mmap_sem
+				 * lock here, so we need to protect against
+				 * concurrent vma expansions.
+				 * vma_lock_anon_vma() doesn't help here, as
+				 * we don't guarantee that all growable vmas
+				 * in a mm share the same root anon vma.
+				 * So, we reuse mm->page_table_lock to guard
+				 * against concurrent vma expansions.
+				 */
+				spin_lock(&vma->vm_mm->page_table_lock);
 				anon_vma_interval_tree_pre_update_vma(vma);
 				vma->vm_start = address;
 				vma->vm_pgoff -= grow;
 				anon_vma_interval_tree_post_update_vma(vma);
 				vma_gap_update(vma);
+				spin_unlock(&vma->vm_mm->page_table_lock);
+
 				perf_event_mmap(vma);
 			}
 		}
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
