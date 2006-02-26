Date: Sun, 26 Feb 2006 16:07:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Feb 2006, Christoph Lameter wrote:
> Here is the parameterization you wanted. However, I am still not sure
> that a check for a valid mapping here is sufficient if the caller has no
> other means to guarantee that the mapping is not vanishing.
> 
> If the mapping is removed after the check for the mapping was done then
> we still have a problem.
> 
> Or is there some way that RCU can preserve the existence of an anonymous 
> vma?
> 
> Cannot imagine how that would work. If an rcu free was done on the 
> anonymous vma then it may vanish anytime after page_lock_anon_vma does a 
> rcu unlock. And then we are holding a lock that is located in free 
> space...... 

Please see comments on SLAB_DESTROY_BY_RCU in mm/slab.c: that's why the
anon_vma cache is created with that flag, that's why page_lock_anon_vma
uses rcu_read_lock.  Your patch, with more appropriate comments and my
signoff added, below (but, in case there's any doubt, it's not suitable
for 2.6.16 - the change itself is simple, but it suddenly makes the
hitherto untried codepaths of remove_from_swap accessible).

Hugh



page_lock_anon_vma: Add additional parameter to control mapped check

It is okay for page migration's remove_from_swap to obtain anon_vma lock
for a page which is currently unmapped, because in its case an mmap_sem
is held, which protects the struct anon_vma from being freed.  The check
for a mapped page prevented remove_from_swap from working until now.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/rmap.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

--- 2.6.16-rc4-git9/mm/rmap.c	2006-02-18 12:28:18.000000000 +0000
+++ linux/mm/rmap.c	2006-02-26 15:27:22.000000000 +0000
@@ -186,8 +186,10 @@ void __init anon_vma_init(void)
 /*
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
+ * It is for this reason that the anon_vma cache is created above with
+ * the SLAB_DESTROY_BY_RCU flag: see comment on that flag in mm/slab.c.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+static struct anon_vma *page_lock_anon_vma(struct page *page, int check_mapped)
 {
 	struct anon_vma *anon_vma = NULL;
 	unsigned long anon_mapping;
@@ -196,7 +198,23 @@ static struct anon_vma *page_lock_anon_v
 	anon_mapping = (unsigned long) page->mapping;
 	if (!(anon_mapping & PAGE_MAPPING_ANON))
 		goto out;
-	if (!page_mapped(page))
+	/*
+	 * When called from page_referenced_anon or try_to_unmap_anon,
+	 * we have no hold on the struct anon_vma: it might already have
+	 * been freed, or be on its way to being freed.  The check below
+	 * on page_mapped ensures that it has not yet been freed, though
+	 * it might still be freed before taking the anon_vma->lock; but
+	 * because we are under rcu_read_lock, and the anon_vma cache is
+	 * marked SLAB_DESTROY_BY_RCU, anon_vma->lock remains safe for
+	 * locking here (and the rest of the structure no worse than
+	 * irrelevant), even if this anon_vma struct has been reused.
+	 *
+	 * But page migration's remove_from_swap needs to take this lock
+	 * when the page has been unmapped, and so must skip around that
+	 * page_mapped check.  In this case, the anon_vma is stabilized
+	 * by the down_read(&mm->mmap_sem) in do_migrate_pages.
+	 */
+	if (check_mapped && !page_mapped(page))
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
@@ -222,7 +240,7 @@ void remove_from_swap(struct page *page)
 	if (!PageAnon(page) || !PageSwapCache(page))
 		return;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 0);
 	if (!anon_vma)
 		return;
 
@@ -359,7 +377,7 @@ static int page_referenced_anon(struct p
 	struct vm_area_struct *vma;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 1);
 	if (!anon_vma)
 		return referenced;
 
@@ -737,7 +755,7 @@ static int try_to_unmap_anon(struct page
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 1);
 	if (!anon_vma)
 		return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
