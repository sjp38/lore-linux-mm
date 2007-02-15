Subject: Re: [patch] mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070215003810.GE29797@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de>
	 <1171485124.5099.43.camel@localhost> <20070215003810.GE29797@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 15 Feb 2007 18:29:29 -0500
Message-Id: <1171582169.5114.86.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-15 at 01:38 +0100, Nick Piggin wrote:
> On Wed, Feb 14, 2007 at 03:32:04PM -0500, Lee Schermerhorn wrote:
> > On Tue, 2007-02-13 at 07:09 +0100, Nick Piggin wrote:
> > > Hi,
> > > 
> > > Just tinkering around with this and got something working, so I'll see
> > > if anyone else wants to try it.
> > > 
> > > Not proposing for inclusion, but I'd be interested in comments or results.
> > > 
> > > Thanks,
> > > Nick
> > 
> > I've included a small patch below that allow me to build and boot with
> > these patches on an HP NUMA platform.  I'm still seeing an "unable to
> 
> Thanks Lee. Merged.

No worries...

I've attached another patch that closes one race and fixes a context
problem [irq/preemption state] in __unreplicate_page_range().  This
makes the locking even uglier :-(.

I get further with this patch.  Boot all the way up and can run fine
with page replication.  However, I still get a NULL pcd in
find_get_page_readonly() when attempting a highly parallel kernel build
[16cpu/4node numa platform].  I'm still trying to track that down.

Question about locking:  looks like the pcache_descriptor members are
protected by the tree_lock of the mapping, right?

Lee

======================

Additional fixes for Nick's page cache replication patch

1) recheck that page is replicated after down grading mapping tree lock.
   return results of check from __replicate_pcache().

2) in __unreplicate_pcache_range(), call __unreplicate_pcache() in appropriate
   context vis a vis irqs and preemption

3) report null pcd in find_get_page_readonly().  shouldn't happen?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/filemap.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-02-15 15:25:23.000000000 -0500
+++ Linux/mm/filemap.c	2007-02-15 17:42:27.000000000 -0500
@@ -669,7 +669,6 @@ static int __replicate_pcache(struct pag
 	struct pcache_desc *pcd;
 	int nid, page_node;
 	int writelock = 0;
-	int ret = 0;
 
 	if (unlikely(PageSwapCache(page)))
 		goto out;
@@ -691,7 +690,7 @@ again:
 		lock_page(page);
 		if (!page->mapping) {
 			unlock_page(page);
-			return 0;
+			goto read_lock_out;	/* reacquire read lock */
 		}
 		write_lock_irq(&mapping->tree_lock);
 		writelock = 1;
@@ -716,15 +715,19 @@ again:
 	BUG_ON(radix_tree_insert(&mapping->page_tree, offset, pcd));
 	radix_tree_tag_set(&mapping->page_tree, offset,
 					PAGECACHE_TAG_REPLICATED);
-	ret = 1;
 out:
 	if (writelock) {
 		write_unlock_irq(&mapping->tree_lock);
 		unlock_page(page);
+read_lock_out:
 		read_lock_irq(&mapping->tree_lock);
 	}
 
-	return ret;
+	/*
+	 * ensure page still replicated after demoting the tree lock
+	 */
+	return (radix_tree_tag_get(&mapping->page_tree, offset,
+					PAGECACHE_TAG_REPLICATED));
 }
 
 void __unreplicate_pcache(struct address_space *mapping, unsigned long offset)
@@ -813,6 +816,11 @@ retry:
 replicated:
 		nid = numa_node_id();
 		pcd = radix_tree_lookup(&mapping->page_tree, offset);
+		if (!pcd) {
+			printk(KERN_DEBUG "%s NULL pcd at tagged offset\n",
+				__FUNCTION__);
+			BUG();
+		}
 		if (!node_isset(nid, pcd->nodes_present)) {
 			struct page *repl_page;
 
@@ -991,9 +999,16 @@ again:
 			struct pcache_desc *pcd = (struct pcache_desc *)pages[i];
 			pages[i] = (struct page *)pcd->master->index;
 		}
-		read_unlock(&mapping->tree_lock);
+		read_unlock(&mapping->tree_lock);	/* irqs/preempt off */
 		for (i = 0; i < ret; i++) {
-			write_lock(&mapping->tree_lock);
+			/*
+			 * __unreplicate_pcache() expects tree write locked
+			 * with irq/preemption disabled.
+			 */
+			if (i)
+				write_lock_irq(&mapping->tree_lock);
+			else
+				write_lock(&mapping->tree_lock);
 			__unreplicate_pcache(mapping, (unsigned long)pages[i]);
 		}
 		read_lock_irq(&mapping->tree_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
