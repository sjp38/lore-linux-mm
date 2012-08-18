Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 7ADCE6B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 20:03:14 -0400 (EDT)
Date: Fri, 17 Aug 2012 19:03:12 -0500
From: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Subject: Re: Repeated fork() causes SLAB to grow without bound
Message-ID: <20120818000312.GA4262@evergreen.ssec.wisc.edu>
Reply-To: Daniel Forrest <dan.forrest@ssec.wisc.edu>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502D42E5.7090403@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

On Thu, Aug 16, 2012 at 02:58:45PM -0400, Rik van Riel wrote:

> Oh dear.
> 
> Basically, what happens is that at fork time, a new
> "level" is created for the anon_vma hierarchy. This
> works great for normal forking daemons, since the
> parent process just keeps running, and forking off
> children.
> 
> Look at anon_vma_fork() in mm/rmap.c for the details.
> 
> Having each child become the new parent, and the
> previous parent exit, can result in an "infinite"
> stack of anon_vmas.
> 
> Now, the parent anon_vma we cannot get rid of,
> because that is where the anon_vma lock lives.
> 
> However, in your case you have many more anon_vma
> levels than you have processes!
> 
> I wonder if it may be possible to fix your bug
> by adding a refcount to the struct anon_vma,
> one count for each VMA that is directly attached
> to the anon_vma (ie. vma->anon_vma == anon_vma),
> and one for each page that points to the anon_vma.
> 
> If the reference count on an anon_vma reaches 0,
> we can skip that anon_vma in anon_vma_clone, and
> the child process should not get that anon_vma.
> 
> A scheme like that may be enough to avoid the trouble
> you are running into.
> 
> Does this sound realistic?

Based on your comments, I came up with the following patch.  It boots
and the anon_vma/anon_vma_chain SLAB usage is stable, but I don't know
if I've overlooked something.  I'm not a kernel hacker.


--- include/linux/rmap.h.ORIG	2011-08-05 04:59:21.000000000 +0000
+++ include/linux/rmap.h	2012-08-16 22:52:25.000000000 +0000
@@ -35,6 +35,7 @@ struct anon_vma {
 	 * anon_vma if they are the last user on release
 	 */
 	atomic_t refcount;
+	atomic_t pagecount;
 
 	/*
 	 * NOTE: the LSB of the head.next is set by
--- mm/rmap.c.ORIG	2011-08-05 04:59:21.000000000 +0000
+++ mm/rmap.c	2012-08-17 23:55:13.000000000 +0000
@@ -85,6 +85,7 @@ static inline struct anon_vma *anon_vma_
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
 	VM_BUG_ON(atomic_read(&anon_vma->refcount));
+	VM_BUG_ON(atomic_read(&anon_vma->pagecount));
 
 	/*
 	 * Synchronize against page_lock_anon_vma() such that
@@ -176,6 +177,7 @@ int anon_vma_prepare(struct vm_area_stru
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
+			atomic_inc(&anon_vma->pagecount);
 			avc->anon_vma = anon_vma;
 			avc->vma = vma;
 			list_add(&avc->same_vma, &vma->anon_vma_chain);
@@ -262,7 +264,10 @@ int anon_vma_clone(struct vm_area_struct
 		}
 		anon_vma = pavc->anon_vma;
 		root = lock_anon_vma_root(root, anon_vma);
-		anon_vma_chain_link(dst, avc, anon_vma);
+		if (!atomic_read(&anon_vma->pagecount))
+			anon_vma_chain_free(avc);
+		else
+			anon_vma_chain_link(dst, avc, anon_vma);
 	}
 	unlock_anon_vma_root(root);
 	return 0;
@@ -314,6 +319,7 @@ int anon_vma_fork(struct vm_area_struct
 	get_anon_vma(anon_vma->root);
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
 	vma->anon_vma = anon_vma;
+	atomic_set(&anon_vma->pagecount, 1);
 	anon_vma_lock(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
 	anon_vma_unlock(anon_vma);
@@ -341,6 +347,8 @@ void unlink_anon_vmas(struct vm_area_str
 
 		root = lock_anon_vma_root(root, anon_vma);
 		list_del(&avc->same_anon_vma);
+		if (vma->anon_vma == anon_vma)
+			atomic_dec(&anon_vma->pagecount);
 
 		/*
 		 * Leave empty anon_vmas on the list - we'll need
@@ -375,6 +383,7 @@ static void anon_vma_ctor(void *data)
 
 	mutex_init(&anon_vma->mutex);
 	atomic_set(&anon_vma->refcount, 0);
+	atomic_set(&anon_vma->pagecount, 0);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -996,6 +1005,7 @@ static void __page_set_anon_rmap(struct
 	if (!exclusive)
 		anon_vma = anon_vma->root;
 
+	atomic_inc(&anon_vma->pagecount);
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
 	page->index = linear_page_index(vma, address);
@@ -1142,6 +1152,11 @@ void page_remove_rmap(struct page *page)
 	if (unlikely(PageHuge(page)))
 		return;
 	if (PageAnon(page)) {
+		struct anon_vma *anon_vma;
+
+		anon_vma = page_anon_vma(page);
+		if (anon_vma)
+			atomic_dec(&anon_vma->pagecount);
 		mem_cgroup_uncharge_page(page);
 		if (!PageTransHuge(page))
 			__dec_zone_page_state(page, NR_ANON_PAGES);
@@ -1747,6 +1762,7 @@ static void __hugepage_set_anon_rmap(str
 	if (!exclusive)
 		anon_vma = anon_vma->root;
 
+	atomic_inc(&anon_vma->pagecount);
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
 	page->index = linear_page_index(vma, address);

-- 
Daniel K. Forrest		Space Science and
dan.forrest@ssec.wisc.edu	Engineering Center
(608) 890 - 0558		University of Wisconsin, Madison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
