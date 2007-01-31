Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l0VLNOQB025011
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 21:23:24 GMT
Received: from wr-out-0506.google.com (wrai23.prod.google.com [10.54.60.23])
	by spaceape11.eur.corp.google.com with ESMTP id l0VLMpg1027649
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 21:23:20 GMT
Received: by wr-out-0506.google.com with SMTP id i23so451389wra
        for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:23:20 -0800 (PST)
Message-ID: <b040c32a0701311323v2208f6cfy633e290fb76eb764@mail.gmail.com>
Date: Wed, 31 Jan 2007 13:23:19 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] simplify shmem_aops.set_page_dirty method
In-Reply-To: <Pine.LNX.4.64.0701311915230.19297@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
	 <Pine.LNX.4.64.0701311648450.28314@blonde.wat.veritas.com>
	 <20070131111146.2b29d851.akpm@osdl.org>
	 <Pine.LNX.4.64.0701311915230.19297@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/07, Hugh Dickins <hugh@veritas.com> wrote:
> > > 2.  Please remind me what good __mark_inode_dirty will do for shmem:
> >
> > None that I can think of - tmpfs inodes don't get written back to swap (do
> > they?)
>
> That's right, tmpfs inodes are only in RAM, only the data can go to swap.
>
> > Will test_and_set_bit() avoid dirtying the cacheline?  I guess it _could_
> > do this, and perhaps this depends upon the architecture.  Perhaps
> >
> >       if (!PageDirty(page))
> >               SetPageDirty(page);
> >
> > would be better here.


Thank you for reviewing.  Here is a patch with comments incorporated:


shmem backed file does not have page writeback, nor it participates in
backing device's dirty or writeback accounting.  So using generic
__set_page_dirty_nobuffers() for its .set_page_dirty aops method is a bit
overkill.  It unnecessarily prolongs shm unmap latency.

For example, on a densely populated large shm segment (sevearl GBs), the
unmapping operation becomes painfully long. Because at unmap, kernel
transfers dirty bit in PTE into page struct and to the radix tree tag. The
operation of tagging the radix tree is particularly expensive because it
has to traverse the tree from the root to the leaf node on every dirty page.
What's bothering is that radix tree tag is used for page write back. However,
shmem is memory backed and there is no page write back for such file system.
And in the end, we spend all that time tagging radix tree and none of that
fancy tagging will be used.  So let's simplify it by introduce a new aops
__set_page_dirty_no_writeback and this will speed up shm unmap.


Signed-off-by: Ken Chen <kenchen@google.com>

---
Hugh, If you are OK with this, would you please sign off with your s-o-b?

diff -Nurp linux-2.6.20-rc6/include/linux/mm.h
linux-2.6.20-rc6.unmap/include/linux/mm.h
--- linux-2.6.20-rc6/include/linux/mm.h	2007-01-30 19:23:44.000000000 -0800
+++ linux-2.6.20-rc6.unmap/include/linux/mm.h	2007-01-31
11:22:23.000000000 -0800
@@ -785,6 +785,7 @@ extern int try_to_release_page(struct pa
 extern void do_invalidatepage(struct page *page, unsigned long offset);

 int __set_page_dirty_nobuffers(struct page *page);
+int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
 int FASTCALL(set_page_dirty(struct page *page));
diff -Nurp linux-2.6.20-rc6/mm/memory.c linux-2.6.20-rc6.unmap/mm/memory.c
--- linux-2.6.20-rc6/mm/memory.c	2007-01-30 19:23:45.000000000 -0800
+++ linux-2.6.20-rc6.unmap/mm/memory.c	2007-01-31 12:47:19.000000000 -0800
@@ -678,7 +678,7 @@ static unsigned long zap_pte_range(struc
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
-					mark_page_accessed(page);
+					SetPageReferenced(page);
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
diff -Nurp linux-2.6.20-rc6/mm/page-writeback.c
linux-2.6.20-rc6.unmap/mm/page-writeback.c
--- linux-2.6.20-rc6/mm/page-writeback.c	2007-01-30 19:23:45.000000000 -0800
+++ linux-2.6.20-rc6.unmap/mm/page-writeback.c	2007-01-31
12:36:46.000000000 -0800
@@ -742,6 +742,16 @@ int write_one_page(struct page *page, in
 EXPORT_SYMBOL(write_one_page);

 /*
+ * For address_spaces which do not use buffers nor write back.
+ */
+int __set_page_dirty_no_writeback(struct page *page)
+{
+	if (!PageDirty(page))
+		SetPageDirty(page);
+	return 0;
+}
+
+/*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
  *
diff -Nurp linux-2.6.20-rc6/mm/shmem.c linux-2.6.20-rc6.unmap/mm/shmem.c
--- linux-2.6.20-rc6/mm/shmem.c	2007-01-30 19:23:45.000000000 -0800
+++ linux-2.6.20-rc6.unmap/mm/shmem.c	2007-01-31 11:23:27.000000000 -0800
@@ -2316,7 +2316,7 @@ static void destroy_inodecache(void)

 static const struct address_space_operations shmem_aops = {
 	.writepage	= shmem_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
 	.prepare_write	= shmem_prepare_write,
 	.commit_write	= simple_commit_write,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
