Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.12.10/8.12.10) with ESMTP id jBGL7QBN177378
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 21:07:26 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBGL7Qgi190956
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 22:07:26 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id jBGL7QMA030815
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 22:07:26 +0100
Date: Fri, 16 Dec 2005 22:07:28 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [rfc][patch 2/6] Page host virtual assist: make mlocked pages stable.
Message-ID: <20051216210728.GC11062@skybase.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[rfc][patch 2/6] Page host virtual assist: make mlocked pages stable.

Add code to get mlock() working with page host virtual assist. The
problem is that mlocked pages may not be removed from page cache.
That means they need to be stable. page_hva_make_volatile needs a
way to check if a page has been locked. To avoid traversing vma
lists - which would hurt performance a lot - a field is added in
the struct address space. This bit is set in mlock_fixup if a vma
gets mlocked. The bit never gets removed - once a file had an
mlocked vma all future pages added to it will stay stable. To
complete the picture make_pages_present has to check for the
host page state besides making the pages present in the linux
page table. This is done by a call to get_user_pages with a pages
parameter. After get_user_pages is back the pages are stable.
The references to the pages can be returned immediatly, the pages
will stay in stable because the mlocked bit is not set for the
mapping.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

---

 include/linux/fs.h       |    1 +
 include/linux/page_hva.h |    2 ++
 mm/memory.c              |   25 +++++++++++++++++++++++++
 mm/mlock.c               |    2 ++
 mm/page_hva.c            |    5 ++++-
 5 files changed, 34 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/include/linux/fs.h linux-2.6-patched/include/linux/fs.h
--- linux-2.6/include/linux/fs.h	2005-12-16 20:40:34.000000000 +0100
+++ linux-2.6-patched/include/linux/fs.h	2005-12-16 20:40:50.000000000 +0100
@@ -386,6 +386,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+	unsigned int		mlocked;	/* set if VM_LOCKED vmas present */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -urpN linux-2.6/include/linux/page_hva.h linux-2.6-patched/include/linux/page_hva.h
--- linux-2.6/include/linux/page_hva.h	2005-12-16 20:40:50.000000000 +0100
+++ linux-2.6-patched/include/linux/page_hva.h	2005-12-16 20:40:50.000000000 +0100
@@ -31,6 +31,8 @@ static inline void page_hva_make_volatil
 
 #else
 
+#define page_hva_enabled()			(0)
+
 #define page_hva_set_unused(_page)		do { } while (0)
 #define page_hva_set_stable(_page)		do { } while (0)
 #define page_hva_set_volatile(_page)		do { } while (0)
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2005-12-16 20:40:50.000000000 +0100
+++ linux-2.6-patched/mm/memory.c	2005-12-16 20:40:50.000000000 +0100
@@ -2402,6 +2402,31 @@ int make_pages_present(unsigned long add
 	if (end > vma->vm_end)
 		BUG();
 	len = (end+PAGE_SIZE-1)/PAGE_SIZE-addr/PAGE_SIZE;
+
+	if (page_hva_enabled() && (vma->vm_flags & VM_LOCKED)) {
+		int rlen = len;
+		ret = 0;
+		while (rlen > 0) {
+			struct page *page_refs[32];
+			int chunk, cret, i;
+
+			chunk = rlen < 32 ? rlen : 32;
+			cret = get_user_pages(current, current->mm, addr,
+					      chunk, write, 0,
+					      page_refs, NULL);
+			if (cret > 0) {
+				for (i = 0; i < cret; i++)
+					page_cache_release(page_refs[i]);
+				ret += cret;
+			}
+			if (cret < chunk)
+				return ret ? : cret;
+			addr += 32*PAGE_SIZE;
+			rlen -= 32;
+		}
+		return ret == len ? 0 : -1;
+	}
+
 	ret = get_user_pages(current, current->mm, addr,
 			len, write, 0, NULL, NULL);
 	if (ret < 0)
diff -urpN linux-2.6/mm/mlock.c linux-2.6-patched/mm/mlock.c
--- linux-2.6/mm/mlock.c	2005-10-28 02:02:08.000000000 +0200
+++ linux-2.6-patched/mm/mlock.c	2005-12-16 20:40:50.000000000 +0100
@@ -59,6 +59,8 @@ success:
 	 */
 	pages = (end - start) >> PAGE_SHIFT;
 	if (newflags & VM_LOCKED) {
+		if (vma->vm_file && vma->vm_file->f_mapping)
+			vma->vm_file->f_mapping->mlocked = 1;
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
diff -urpN linux-2.6/mm/page_hva.c linux-2.6-patched/mm/page_hva.c
--- linux-2.6/mm/page_hva.c	2005-12-16 20:40:50.000000000 +0100
+++ linux-2.6-patched/mm/page_hva.c	2005-12-16 20:40:50.000000000 +0100
@@ -23,6 +23,8 @@
  */
 static inline int __page_hva_discardable(struct page *page,unsigned int offset)
 {
+	struct address_space *mapping;
+
 	/*
 	 * There are several conditions that prevent a page from becoming
 	 * volatile. The first check is for the page bits, if the page
@@ -40,7 +42,8 @@ static inline int __page_hva_discardable
 	 * If the page has been truncated there is no point in makeing
 	 * it volatile. It will be freed soon.
 	 */
-	if (!page_mapping(page))
+	mapping = page_mapping(page);
+	if (!mapping || mapping->mlocked)
 		return 0;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
