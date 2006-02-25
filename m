Date: Fri, 24 Feb 2006 17:03:20 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: page_lock_anon_vma(): remove check for mapped page
Message-ID: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Any reason that this function is checking for a mapped page? There could
be references through a swap pte to the page. The looping in
remove_from_swap, page_referenced_anon and try_to_unmap anon would 
work even if the check for a mapped page would be removed.

I have sent the patch below today to Hugh Dickins but did not receive an 
answer. Probaby requires some discussion.



It is okay to obtain a anon vma lock for a page that is only mapped
via a swap pte to the page. This occurs frequently during page
migration. The check for a mapped page (requiring regular ptes pointing
to the page) gets in the way.

Without this patch anonymous pages will have swap ptes after migration
that then need to be converted into regular ptes via a page fault.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc4/mm/rmap.c
===================================================================
--- linux-2.6.16-rc4.orig/mm/rmap.c	2006-02-17 14:23:45.000000000 -0800
+++ linux-2.6.16-rc4/mm/rmap.c	2006-02-24 13:19:11.000000000 -0800
@@ -196,8 +196,6 @@ static struct anon_vma *page_lock_anon_v
 	anon_mapping = (unsigned long) page->mapping;
 	if (!(anon_mapping & PAGE_MAPPING_ANON))
 		goto out;
-	if (!page_mapped(page))
-		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
