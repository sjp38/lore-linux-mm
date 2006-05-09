Subject: [RFC][PATCH 3/3] optimize follow_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	 <1147116034.16600.2.camel@lappy>
	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 09 May 2006 22:44:22 +0200
Message-Id: <1147207462.27680.21.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Christoph Lameter suggested I pull set_page_dirty() out from under the 
pte lock.

I reviewed the current calls and found the one in follow_page() a candidate
for the same treatment.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---

 include/linux/mm.h |    1 +
 mm/memory.c        |   12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-05-08 18:53:34.000000000 +0200
+++ linux-2.6/include/linux/mm.h	2006-05-09 17:48:36.000000000 +0200
@@ -1015,6 +1015,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
+#define FOLL_DIRTY	0x10	/* the page was dirtied */
 
 #ifdef CONFIG_PROC_FS
 void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-09 09:17:12.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-05-09 17:52:02.000000000 +0200
@@ -962,16 +962,22 @@ struct page *follow_page(struct vm_area_
 	if (unlikely(!page))
 		goto unlock;
 
-	if (flags & FOLL_GET)
+	if (flags & (FOLL_GET | FOLL_TOUCH))
 		get_page(page);
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
-			set_page_dirty(page);
-		mark_page_accessed(page);
+			flags |= FOLL_DIRTY;
 	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
+	if (flags & FOLL_TOUCH) {
+		if (flags & FOLL_DIRTY)
+			set_page_dirty(page);
+		mark_page_accessed(page);
+	}
+	if (!(flags & FOLL_GET))
+		put_page(page);
 out:
 	return page;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
