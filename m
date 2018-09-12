Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064358E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 22:29:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a23-v6so255017pfo.23
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 19:29:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j15-v6si20461420pfn.366.2018.09.11.19.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Sep 2018 19:29:26 -0700 (PDT)
Date: Tue, 11 Sep 2018 19:29:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v9 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180912022921.GA20056@bombadil.infradead.org>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180911211645.GA12159@bombadil.infradead.org>
 <b69d3f7d-e9ba-b95c-45cd-44489950751b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b69d3f7d-e9ba-b95c-45cd-44489950751b@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 11, 2018 at 04:35:03PM -0700, Yang Shi wrote:
> On 9/11/18 2:16 PM, Matthew Wilcox wrote:
> > On Wed, Sep 12, 2018 at 04:58:11AM +0800, Yang Shi wrote:
> > >   mm/mmap.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> > I really think you're going about this the wrong way by duplicating
> > vm_munmap().
> 
> If we don't duplicate vm_munmap() or do_munmap(), we need pass an extra
> parameter to them to tell when it is fine to downgrade write lock or if the
> lock has been acquired outside it (i.e. in mmap()/mremap()), right? But,
> vm_munmap() or do_munmap() is called not only by mmap-related, but also some
> other places, like arch-specific places, which don't need downgrade write
> lock or are not safe to do so.
> 
> Actually, I did this way in the v1 patches, but it got pushed back by tglx
> who suggested duplicate the code so that the change could be done in mm only
> without touching other files, i.e. arch-specific stuff. I didn't have strong
> argument to convince him.

With my patch, there is nothing to change in arch-specific code.
Here it is again ...

diff --git a/mm/mmap.c b/mm/mmap.c
index de699523c0b7..06dc31d1da8c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2798,11 +2798,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
-	      struct list_head *uf)
+static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
+	      struct list_head *uf, bool downgrade)
 {
 	unsigned long end;
-	struct vm_area_struct *vma, *prev, *last;
+	struct vm_area_struct *vma, *prev, *last, *tmp;
 
 	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
@@ -2816,7 +2816,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	if (!vma)
 		return 0;
 	prev = vma->vm_prev;
-	/* we have  start < vma->vm_end  */
+	/* we have start < vma->vm_end  */
 
 	/* if it doesn't overlap, we have nothing.. */
 	end = start + len;
@@ -2873,18 +2873,22 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
+	 * and check to see if there's any reason we might have to hold
+	 * the mmap_sem write-locked while unmapping regions.
 	 */
-	if (mm->locked_vm) {
-		struct vm_area_struct *tmp = vma;
-		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
-				mm->locked_vm -= vma_pages(tmp);
-				munlock_vma_pages_all(tmp);
-			}
-			tmp = tmp->vm_next;
+	for (tmp = vma; tmp && tmp->vm_start < end; tmp = tmp->vm_next) {
+		if (tmp->vm_flags & VM_LOCKED) {
+			mm->locked_vm -= vma_pages(tmp);
+			munlock_vma_pages_all(tmp);
 		}
+		if (tmp->vm_file &&
+				has_uprobes(tmp, tmp->vm_start, tmp->vm_end))
+			downgrade = false;
 	}
 
+	if (downgrade)
+		downgrade_write(&mm->mmap_sem);
+
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
@@ -2896,7 +2900,13 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
 
-	return 0;
+	return downgrade ? 1 : 0;
+}
+
+int do_unmap(struct mm_struct *mm, unsigned long start, size_t len,
+		struct list_head *uf)
+{
+	return __do_munmap(mm, start, len, uf, false);
 }
 
 int vm_munmap(unsigned long start, size_t len)
@@ -2905,11 +2915,12 @@ int vm_munmap(unsigned long start, size_t len)
 	struct mm_struct *mm = current->mm;
 	LIST_HEAD(uf);
 
-	if (down_write_killable(&mm->mmap_sem))
-		return -EINTR;
-
-	ret = do_munmap(mm, start, len, &uf);
-	up_write(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
+	ret = __do_munmap(mm, start, len, &uf, true);
+	if (ret == 1)
+		up_read(&mm->mmap_sem);
+	else
+		up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }

Anybody calling do_munmap() will not get the lock dropped.

> And, Michal prefers have VM_HUGETLB and VM_PFNMAP handled separately for
> safe and bisectable sake, which needs call the regular do_munmap().

That can be introduced and then taken out ... indeed, you can split this into
many patches, starting with this:

+		if (tmp->vm_file)
+			downgrade = false;

to only allow this optimisation for anonymous mappings at first.

> In addition to this, I just found mpx code may call do_munmap() recursively
> when I was looking into the mpx code.
> 
> We might be able to handle these by the extra parameter, but it sounds it
> make the code hard to understand and error prone.

Only if you make the extra parameter mandatory.
