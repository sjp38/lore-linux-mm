Date: Mon, 29 Mar 2004 20:01:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040329180109.GW3808@dualathlon.random>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain> <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu> <20040325225919.GL20019@dualathlon.random> <Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu> <20040326075343.GB12484@dualathlon.random> <Pine.LNX.4.58.0403261013480.672@ruby.engin.umich.edu> <20040326175842.GC9604@dualathlon.random> <Pine.GSO.4.58.0403271448120.28539@sapphire.engin.umich.edu> <20040329172248.GR3808@dualathlon.random> <Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2004 at 12:50:20PM -0500, Rajesh Venkatasubramanian wrote:
> 
> 
> >  #define VN_MAPPED(vp)	\
> > -	(!list_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap)) || \
> > -	(!list_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap_shared))))
> > +	(!prio_tree_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap)) || \
> > +	(!prio_tree_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap_shared))))
> 
> I think we will need the following too:
> 	(!list_empty(&(LINVFS_GET_IP(vp)->i_mmaping->i_mmap_nonlinear)
> 
> 
> >  	down(&mapping->i_shared_sem);
> > -	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
> > +	vma = __vma_prio_tree_first(&mapping->i_mmap_shared, &iter, 0, ULONG_MAX);
> > +	while (vma) {
> >  		if (!(vma->vm_flags & VM_DENYWRITE)) {
> >  			prohibited |= (1 << DM_EVENT_WRITE);
> >  			break;
> >  		}
> > +
> > +		vma = __vma_prio_tree_next(vma, &mapping->i_mmap_shared, &iter, 0, ULONG_MAX);
> >  	}
> 
> This part looks fine. But, I am not sure whether you have to handle
> nonlinear maps here.
> 
> 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared) {
> 		...
> 	}
> 

I agree we should handle the nonlinear maps. since nobody uses nonlinear
this isn't a big issue for the short term.

There's now also a screwup in the writeback -mm changes for swapsuspend,
it bugs out in radix tree tag, I believe it's because it doesn't
insert the page in the radix tree before doing writeback I/O on it. This
is my first attempt to cure it.

--- sles/mm/page_io.c.~1~	2004-03-29 19:05:50.014588464 +0200
+++ sles/mm/page_io.c	2004-03-29 19:46:14.282043792 +0200
@@ -151,8 +151,15 @@ int rw_swap_page_sync(int rw, swp_entry_
 	lock_page(page);
 
 	BUG_ON(page_mapping(page));
+	BUG_ON(PageSwapCache(page));
 	SetPageSwapCache(page);
 	page->private = entry.val;
+	ret = radix_tree_insert(&page_mapping(page)->page_tree, page->private, page);
+	if (unlikely(ret)) {
+		ClearPageSwapCache(page);
+		unlock_page(page);
+		return ret;
+	}
 
 	if (rw == READ) {
 		ret = swap_readpage(NULL, page);
@@ -161,7 +168,10 @@ int rw_swap_page_sync(int rw, swp_entry_
 		ret = swap_writepage(page, &swap_wbc);
 		wait_on_page_writeback(page);
 	}
+
+	radix_tree_delete(&page_mapping(page)->page_tree, page->private);
 	ClearPageSwapCache(page);
+
 	if (ret == 0 && (!PageUptodate(page) || PageError(page)))
 		ret = -EIO;
 	return ret;

then there's x86-64 bombing too:

--- sles/arch/x86_64/ia32/ia32_binfmt.c.~1~	2004-03-29 19:05:50.516512160 +0200
+++ sles/arch/x86_64/ia32/ia32_binfmt.c	2004-03-29 19:53:20.031320064 +0200
@@ -366,7 +366,7 @@ int setup_arg_pages(struct linux_binprm 
 		mpnt->vm_pgoff = mpnt->vm_start >> PAGE_SHIFT;
 		mpnt->vm_file = NULL;
 		mpol_set_vma_default(mpnt);
-		INIT_LIST_HEAD(&mpnt->shared);
+		INIT_VMA_SHARED(mpnt);
 		/* insert_vm_struct takes care of anon_vma_node */
 		mpnt->anon_vma = NULL;
 		mpnt->vm_private_data = (void *) 0;

the writeback part will require testing, so I'll postpone further
updates until I get confirmation that swapsuspend works again (this is
all low prio stuff anyways, the previous xfs list_empty miscompilation
was scary instead so I update it quickly, since people actually uses
MAP_SHARED/MAP_PRIVATE).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
