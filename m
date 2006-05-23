Date: Tue, 23 May 2006 10:43:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060523174349.10156.22044.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [1/5] follow_page: do not put_page if FOLL_GET not specified.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Seems that one of the side effects of the dirty pages patch in
2.6.17-rc4-mm3 is that follow_pages does a page_put if FOLL_GET is
not set in the flags passed to it. This breaks sys_move_pages()
page status determination.

Only put_page if we did a get_page() before.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Index: linux-2.6.17-rc4-mm3/mm/memory.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/mm/memory.c	2006-05-22 18:03:32.280767264 -0700
+++ linux-2.6.17-rc4-mm3/mm/memory.c	2006-05-23 10:01:48.917295988 -0700
@@ -964,7 +964,7 @@ struct page *follow_page(struct vm_area_
 			set_page_dirty(page);
 		mark_page_accessed(page);
 	}
-	if (!(flags & FOLL_GET))
+	if (!(flags & FOLL_GET) && (flags & FOLL_TOUCH))
 		put_page(page);
 	goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
