Received: by ro-out-1112.google.com with SMTP id p7so3288870roc
        for <linux-mm@kvack.org>; Thu, 22 Nov 2007 21:54:47 -0800 (PST)
Date: Fri, 23 Nov 2007 13:51:50 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch] mm/sparse.c: Improve the error handling for
	sparse_add_one_section()
Message-ID: <20071123055150.GA2488@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
References: <20071115135428.GE2489@hacking> <1195507022.27759.146.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1195507022.27759.146.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Improve the error handling for mm/sparse.c::sparse_add_one_section().
And I see no reason to check 'usemap' until holding the
'pgdat_resize_lock'. If someone knows, please let me know.

Note! This patch is _not_ tested yet, since it seems that I can't
configure sparse memory for i386 box. Sorry for this. ;(
I hope someone can help me to test it.

Cc: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
 mm/sparse.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c
+++ linux-2.6/mm/sparse.c
@@ -391,9 +391,17 @@ int sparse_add_one_section(struct zone *
 	 * no locking for this, because it does its own
 	 * plus, it does a kmalloc
 	 */
-	sparse_index_init(section_nr, pgdat->node_id);
+	ret = sparse_index_init(section_nr, pgdat->node_id);
+	if (ret < 0)
+		return ret;
 	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, nr_pages);
+	if (!memmap)
+		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
+	if (!usemap) {
+		__kfree_section_memmap(memmap, nr_pages);
+		return -ENOMEM;
+	}
 
 	pgdat_resize_lock(pgdat, &flags);
 
@@ -403,18 +411,13 @@ int sparse_add_one_section(struct zone *
 		goto out;
 	}
 
-	if (!usemap) {
-		ret = -ENOMEM;
-		goto out;
-	}
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 
 	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
 
 out:
 	pgdat_resize_unlock(pgdat, &flags);
-	if (ret <= 0)
-		__kfree_section_memmap(memmap, nr_pages);
+
 	return ret;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
