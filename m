Date: Mon, 24 Jan 2005 16:54:12 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Make slab use alloc_pages directly
Message-ID: <20050124165412.GL31455@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org, manfred@colorfullife.com
Cc: linux-kernel@vger.kernel.org, dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

__get_free_pages() calls alloc_pages, finds the page_address() and
throws away the struct page *.  Slab then calls virt_to_page to get it
back again.  Much more efficient for slab to call alloc_pages itself,
as well as making the NUMA and non-NUMA cases more similarr to each other.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: linux-2.6/mm/slab.c
===================================================================
RCS file: /var/cvs/linux-2.6/mm/slab.c,v
retrieving revision 1.29
diff -u -p -r1.29 slab.c
--- linux-2.6/mm/slab.c	12 Jan 2005 20:18:07 -0000	1.29
+++ linux-2.6/mm/slab.c	24 Jan 2005 16:47:02 -0000
@@ -894,16 +894,13 @@ static void *kmem_getpages(kmem_cache_t 
 
 	flags |= cachep->gfpflags;
 	if (likely(nodeid == -1)) {
-		addr = (void*)__get_free_pages(flags, cachep->gfporder);
-		if (!addr)
-			return NULL;
-		page = virt_to_page(addr);
+		page = alloc_pages(flags, cachep->gfporder);
 	} else {
 		page = alloc_pages_node(nodeid, flags, cachep->gfporder);
-		if (!page)
-			return NULL;
-		addr = page_address(page);
 	}
+	if (!page)
+		return NULL;
+	addr = page_address(page);
 
 	i = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
