Date: Sat, 25 Feb 2006 21:57:04 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is the parameterization you wanted. However, I am still not sure
that a check for a valid mapping here is sufficient if the caller has no
other means to guarantee that the mapping is not vanishing.

If the mapping is removed after the check for the mapping was done then
we still have a problem.

Or is there some way that RCU can preserve the existence of an anonymous 
vma?

Cannot imagine how that would work. If an rcu free was done on the 
anonymous vma then it may vanish anytime after page_lock_anon_vma does a 
rcu unlock. And then we are holding a lock that is located in free 
space...... 



page_lock_anon_vma: Add additional parameter to control mapped check

It is okay to obtain a anon vma lock for a page that is only mapped
via a swap pte to the page. This occurs frequently during page
migration. The check for a mapped page (requiring regular ptes pointing
to the page) gets in the way.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc4/mm/rmap.c
===================================================================
--- linux-2.6.16-rc4.orig/mm/rmap.c	2006-02-17 14:23:45.000000000 -0800
+++ linux-2.6.16-rc4/mm/rmap.c	2006-02-25 21:51:49.000000000 -0800
@@ -187,7 +187,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+static struct anon_vma *page_lock_anon_vma(struct page *page, int check_mapped)
 {
 	struct anon_vma *anon_vma = NULL;
 	unsigned long anon_mapping;
@@ -196,7 +196,15 @@ static struct anon_vma *page_lock_anon_v
 	anon_mapping = (unsigned long) page->mapping;
 	if (!(anon_mapping & PAGE_MAPPING_ANON))
 		goto out;
-	if (!page_mapped(page))
+	/*
+	 * Mysterious check that may have something to do with the vma
+	 * potentially vanishing if page was the last page in the mapping
+	 * and was just removed.
+	 *
+	 * Check is not necessary if we have another means of guaranteeing
+	 * that the vma is safe.
+	 */
+	if (check_mapped && !page_mapped(page))
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
@@ -222,7 +230,7 @@ void remove_from_swap(struct page *page)
 	if (!PageAnon(page) || !PageSwapCache(page))
 		return;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 0);
 	if (!anon_vma)
 		return;
 
@@ -359,7 +367,7 @@ static int page_referenced_anon(struct p
 	struct vm_area_struct *vma;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 1);
 	if (!anon_vma)
 		return referenced;
 
@@ -737,7 +745,7 @@ static int try_to_unmap_anon(struct page
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
