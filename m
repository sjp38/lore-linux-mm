Date: Mon, 28 Jul 2008 14:36:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/3] xfs: remove vmap cache
Message-ID: <20080728123621.GB13926@wotan.suse.de>
References: <20080728123438.GA13926@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080728123438.GA13926@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

XFS's vmap batching simply defers a number (up to 64) of vunmaps, and keeps
track of them in a list. To purge the batch, it just goes through the list and
calls vunamp on each one. This is pretty poor: a global TLB flush is still
performed on each vunmap, with the most expensive parts of the operation
being the broadcast IPIs and locking involved in the SMP callouts, and the
locking involved in the vmap management -- none of these are avoided by just
batching up the calls. I'm actually surprised it ever made much difference
at all.

Rip all this logic out of XFS completely. I improve vmap performance
and scalability directly in the previous and subsequent patch.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---

Index: linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_buf.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
@@ -166,75 +166,6 @@ test_page_region(
 }
 
 /*
- *	Mapping of multi-page buffers into contiguous virtual space
- */
-
-typedef struct a_list {
-	void		*vm_addr;
-	struct a_list	*next;
-} a_list_t;
-
-static a_list_t		*as_free_head;
-static int		as_list_len;
-static DEFINE_SPINLOCK(as_lock);
-
-/*
- *	Try to batch vunmaps because they are costly.
- */
-STATIC void
-free_address(
-	void		*addr)
-{
-	a_list_t	*aentry;
-
-#ifdef CONFIG_XEN
-	/*
-	 * Xen needs to be able to make sure it can get an exclusive
-	 * RO mapping of pages it wants to turn into a pagetable.  If
-	 * a newly allocated page is also still being vmap()ed by xfs,
-	 * it will cause pagetable construction to fail.  This is a
-	 * quick workaround to always eagerly unmap pages so that Xen
-	 * is happy.
-	 */
-	vunmap(addr);
-	return;
-#endif
-
-	aentry = kmalloc(sizeof(a_list_t), GFP_NOWAIT);
-	if (likely(aentry)) {
-		spin_lock(&as_lock);
-		aentry->next = as_free_head;
-		aentry->vm_addr = addr;
-		as_free_head = aentry;
-		as_list_len++;
-		spin_unlock(&as_lock);
-	} else {
-		vunmap(addr);
-	}
-}
-
-STATIC void
-purge_addresses(void)
-{
-	a_list_t	*aentry, *old;
-
-	if (as_free_head == NULL)
-		return;
-
-	spin_lock(&as_lock);
-	aentry = as_free_head;
-	as_free_head = NULL;
-	as_list_len = 0;
-	spin_unlock(&as_lock);
-
-	while ((old = aentry) != NULL) {
-		vunmap(aentry->vm_addr);
-		aentry = aentry->next;
-		kfree(old);
-	}
-}
-
-/*
  *	Internal xfs_buf_t object manipulation
  */
 
@@ -334,7 +265,7 @@ xfs_buf_free(
 		uint		i;
 
 		if ((bp->b_flags & XBF_MAPPED) && (bp->b_page_count > 1))
-			free_address(bp->b_addr - bp->b_offset);
+			vunmap(bp->b_addr - bp->b_offset);
 
 		for (i = 0; i < bp->b_page_count; i++) {
 			struct page	*page = bp->b_pages[i];
@@ -456,8 +387,6 @@ _xfs_buf_map_pages(
 		bp->b_addr = page_address(bp->b_pages[0]) + bp->b_offset;
 		bp->b_flags |= XBF_MAPPED;
 	} else if (flags & XBF_MAPPED) {
-		if (as_list_len > 64)
-			purge_addresses();
 		bp->b_addr = vmap(bp->b_pages, bp->b_page_count,
 					VM_MAP, PAGE_KERNEL);
 		if (unlikely(bp->b_addr == NULL))
@@ -1739,8 +1668,6 @@ xfsbufd(
 			count++;
 		}
 
-		if (as_list_len > 0)
-			purge_addresses();
 		if (count)
 			blk_run_address_space(target->bt_mapping);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
