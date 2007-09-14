Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8E93BWq012030
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 19:03:11 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E93Ag44735148
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 19:03:10 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E92sLU031835
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 19:02:54 +1000
Date: Fri, 14 Sep 2007 14:19:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: 2.6.23-rc4-mm1 memory controller BUG_ON()
Message-ID: <20070914084902.GA27180@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1189712083.17236.1626.camel@localhost> <46E99BDE.9000602@linux.vnet.ibm.com> <1189716849.17236.1712.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1189716849.17236.1712.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 13, 2007 at 01:54:09PM -0700, Dave Hansen wrote:
> On Fri, 2007-09-14 at 01:51 +0530, Balbir Singh wrote:
> > Dave Hansen wrote:
> > > Looks like somebody is holding a lock while trying to do a
> > > mem_container_charge(), and the mem_container_charge() call is doing
> > an
> > > allocation.  Naughty.
> > > 
> > > I'm digging into it a bit more, but thought I'd report it, first.
> > > 
> > 
> > Hi, Dave,
> > 
> > Thanks for reporting this. I sent out a patch to fix this problem
> > (suggested by Nick Piggin). The patch is available at
> > 
> > http://lkml.org/lkml/2007/9/12/113
> > 
> > Could you try the patch and check if the problem goes away? 
> 
> Balbir and I had a chat about this on IRC.  Those patches don't seem to
> fix it.  But, I'm getting Balbir hooked up with the kvm instance that I
> ran this in along with my .config.
>

Hi, Dave,

Here's a fix for the problem, it works nicely on the qemu setup that
you helped me with. I am also testing on another box. Could you please
verify if the patch helps?

Description of the patch
------------------------
 
Move mem_controller_cache_charge() above radix_tree_preload().
radix_tree_preload() disables preemption, even though the gfp_mask passed
contains __GFP_WAIT, we cannot really do __GFP_WAIT allocations, thus we hit
a BUG_ON() in kmem_cache_alloc().

This patch moves mem_controller_cache_charge() to above radix_tree_preload()
for cache charging.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/filemap.c    |   13 ++++++-------
 mm/swap_state.c |   13 +++++++------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff -puN mm/filemap.c~memory-controller-make-charging-gfpmask-aware-fixes mm/filemap.c
--- linux-2.6.23-rc4/mm/filemap.c~memory-controller-make-charging-gfpmask-aware-fixes	2007-09-14 13:20:44.000000000 +0530
+++ linux-2.6.23-rc4-balbir/mm/filemap.c	2007-09-14 13:23:50.000000000 +0530
@@ -441,14 +441,12 @@ int filemap_write_and_wait_range(struct 
 int add_to_page_cache(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
-	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	int error = mem_container_cache_charge(page, current->mm, gfp_mask);
+	if (error)
+		goto out;
 
+	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
-
-		error = mem_container_cache_charge(page, current->mm, gfp_mask);
-		if (error)
-			goto out;
-
 		write_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
@@ -463,7 +461,8 @@ int add_to_page_cache(struct page *page,
 
 		write_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
-	}
+	} else
+		mem_container_uncharge_page(page);
 out:
 	return error;
 }
diff -puN mm/swap_state.c~memory-controller-make-charging-gfpmask-aware-fixes mm/swap_state.c
--- linux-2.6.23-rc4/mm/swap_state.c~memory-controller-make-charging-gfpmask-aware-fixes	2007-09-14 13:20:44.000000000 +0530
+++ linux-2.6.23-rc4-balbir/mm/swap_state.c	2007-09-14 13:26:14.000000000 +0530
@@ -78,13 +78,13 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageSwapCache(page));
 	BUG_ON(PagePrivate(page));
-	error = radix_tree_preload(gfp_mask);
-	if (!error) {
 
-		error = mem_container_cache_charge(page, current->mm, gfp_mask);
-		if (error)
-			goto out;
+	error = mem_container_cache_charge(page, current->mm, gfp_mask);
+	if (error)
+		goto out;
 
+	error = radix_tree_preload(gfp_mask);
+	if (!error) {
 		write_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
@@ -99,7 +99,8 @@ static int __add_to_swap_cache(struct pa
 
 		write_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
-	}
+	} else
+		mem_container_uncharge_page(page);
 out:
 	return error;
 }
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
