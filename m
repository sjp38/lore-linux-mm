Date: Mon, 27 Feb 2006 10:31:16 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602271823260.9352@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602271028240.3185@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270934260.3185@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271823260.9352@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Hugh Dickins wrote:

> > How about this patch:
> 
> I'd prefer not myself, perhaps someone else likes it.
> And you haven't even based it on the check_mapped version you sent me,
> which I then returned to you with more helpful comments.

Well, I thought overall cleanness issue was better dealt with first before 
we go into that.

The check_mapped can be done in a different way since there is no need
for an rcu lock because we now have the requirement to hold 
mmap_sem for protection. If you do not like it then I am fine with your 
patch:




remove_from_swap: Fix locking

remove_from_swap currently attempt to use page_lock_anon_vma to obtain
an anon_vma lock. That is not working since the page may have been remapped
via swap ptes in order to move the page.

However, do_migrate_pages() obtain the mmap_sem lock and therefore there
is a guarantee that the anonymous vma will not vanish from under us. There
is therefore no need to use page_lock_anon_vma.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5/mm/rmap.c
===================================================================
--- linux-2.6.16-rc5.orig/mm/rmap.c	2006-02-27 10:10:25.000000000 -0800
+++ linux-2.6.16-rc5/mm/rmap.c	2006-02-27 10:29:20.000000000 -0800
@@ -232,25 +232,33 @@ static void page_unlock_anon_vma(struct 
  * through real pte's pointing to valid pages and then releasing
  * the page from the swap cache.
  *
- * Must hold page lock on page.
+ * Must hold page lock on page and mmap_sem of one vma that contains
+ * the page.
  */
 void remove_from_swap(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned long mapping;
 
-	if (!PageAnon(page) || !PageSwapCache(page))
+	if (!PageSwapCache(page))
 		return;
 
-	anon_vma = page_lock_anon_vma(page);
-	if (!anon_vma)
+	mapping = (unsigned long)page->mapping;
+
+	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
 		return;
 
+	/*
+	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 */
+	anon_vma = (struct anon_vma *) (page->mapping - PAGE_MAPPING_ANON);
+	spin_lock(&anon_vma->lock);
+
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_vma_swap(vma, page);
 
 	spin_unlock(&anon_vma->lock);
-
 	delete_from_swap_cache(page);
 }
 EXPORT_SYMBOL(remove_from_swap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
