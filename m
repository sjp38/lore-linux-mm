Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 156186B005A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 23:09:53 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:10:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] HWPOISON: fix tasklist_lock/anon_vma locking order
Message-ID: <20090610031000.GD6597@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090609100922.GF14820@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609100922.GF14820@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 06:09:22PM +0800, Nick Piggin wrote:
> On Wed, Jun 03, 2009 at 08:46:47PM +0200, Andi Kleen wrote:
> 
> Why not have this in rmap.c and not export the locking?
> I don't know.. does Hugh care?

I don't know either :)

> > +/*
> > + * Collect processes when the error hit an anonymous page.
> > + */
> > +static void collect_procs_anon(struct page *page, struct list_head *to_kill,
> > +			      struct to_kill **tkc)
> > +{
> > +	struct vm_area_struct *vma;
> > +	struct task_struct *tsk;
> > +	struct anon_vma *av = page_lock_anon_vma(page);
> > +
> > +	if (av == NULL)	/* Not actually mapped anymore */
> > +		return;
> > +
> > +	read_lock(&tasklist_lock);
> > +	for_each_process (tsk) {
> > +		if (!tsk->mm)
> > +			continue;
> > +		list_for_each_entry (vma, &av->head, anon_vma_node) {
> > +			if (vma->vm_mm == tsk->mm)
> > +				add_to_kill(tsk, page, vma, to_kill, tkc);
> > +		}
> > +	}
> > +	page_unlock_anon_vma(av);
> > +	read_unlock(&tasklist_lock);
> > +}
> > +
> > +/*
> > + * Collect processes when the error hit a file mapped page.
> > + */
> > +static void collect_procs_file(struct page *page, struct list_head *to_kill,
> > +			      struct to_kill **tkc)
> > +{
> > +	struct vm_area_struct *vma;
> > +	struct task_struct *tsk;
> > +	struct prio_tree_iter iter;
> > +	struct address_space *mapping = page_mapping(page);
> > +
> > +	/*
> > +	 * A note on the locking order between the two locks.
> > +	 * We don't rely on this particular order.
> > +	 * If you have some other code that needs a different order
> > +	 * feel free to switch them around. Or add a reverse link
> > +	 * from mm_struct to task_struct, then this could be all
> > +	 * done without taking tasklist_lock and looping over all tasks.
> > +	 */
> > +
> > +	read_lock(&tasklist_lock);
> > +	spin_lock(&mapping->i_mmap_lock);
> 
> This still has my original complaint that it nests tasklist lock inside
> anon vma lock and outside inode mmap lock (and anon_vma nests inside i_mmap).
> I guess the property of our current rw locks means that does not matter,
> but it could if we had "fair" rw locks, or some tree (-rt tree maybe)
> changed rw lock to a plain exclusive lock.

Andi must forgot that - he did change the comment on locking order.
This incremental patch aligns the code with his comment in rmap.c.

---
HWPOISON: fix tasklist_lock/anon_vma locking order

To avoid possible deadlock. Proposed by Nick Piggin:

  You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
  lock. And anon_vma lock nests inside i_mmap_lock.

  This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
  type (maybe -rt kernels do it), then you could have a task holding
  anon_vma lock and waiting for tasklist_lock, and another holding tasklist
  lock and waiting for i_mmap_lock, and another holding i_mmap_lock and
  waiting for anon_vma lock.

CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -215,12 +215,14 @@ static void collect_procs_anon(struct pa
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
-	struct anon_vma *av = page_lock_anon_vma(page);
+	struct anon_vma *av;
 
+	read_lock(&tasklist_lock);
+
+	av = page_lock_anon_vma(page);
 	if (av == NULL)	/* Not actually mapped anymore */
-		return;
+		goto out;
 
-	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		if (!tsk->mm)
 			continue;
@@ -230,6 +232,7 @@ static void collect_procs_anon(struct pa
 		}
 	}
 	page_unlock_anon_vma(av);
+out:
 	read_unlock(&tasklist_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
