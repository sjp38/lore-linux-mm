Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307A56B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 07:35:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b18-v6so1393301pgv.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 04:35:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e1-v6si1109160pld.69.2018.04.27.04.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Apr 2018 04:35:05 -0700 (PDT)
Date: Fri, 27 Apr 2018 04:34:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180427113426.GA8161@bombadil.infradead.org>
References: <20180424164751.GA18923@jordon-HP-15-Notebook-PC>
 <20180426195831.GA27127@linux.intel.com>
 <CAFqt6zZti0oY7C-pU0LhsHtctqeWBkikH6Pb0wfBZSigHNMUwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZti0oY7C-pU0LhsHtctqeWBkikH6Pb0wfBZSigHNMUwA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, Apr 27, 2018 at 10:54:53AM +0530, Souptick Joarder wrote:
> > I noticed that we have the following status translation now in 4 places in 2
> > files:
> >
> >         if (err == -ENOMEM)
> >                 return VM_FAULT_OOM;
> >         if (err < 0 && err != -EBUSY)
> >                 return VM_FAULT_SIGBUS;
> >         return VM_FAULT_NOPAGE;
> >
> >
> > This happens in vmf_insert_mixed_mkwrite(), vmf_insert_page(),
> > vmf_insert_mixed() and vmf_insert_pfn().
> >
> > I think it'd be a good idea to consolidate this translation into an inline
> > helper, in the spirit of dax_fault_return().  This will ensure that if/when we
> > start changing this status translation, we won't accidentally miss some of the
> > places which would make them get out of sync.  No need to fold this into this
> > patch - it should be a separate change.
> 
> Sure, I will send this as a separate patch.

No, this will entirely go away when vm_insert_foo() is removed.  Here's what
it'll look like instead:

@@ -1703,23 +1703,23 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
  * old drivers should use this, and they needed to mark their
  * pages reserved for the old functions anyway.
  */
-static int insert_page(struct vm_area_struct *vma, unsigned long addr,
+static vm_fault_t insert_page(struct vm_area_struct *vma, unsigned long addr,
                        struct page *page, pgprot_t prot)
 {
        struct mm_struct *mm = vma->vm_mm;
-       int retval;
+       vm_fault_t ret;
        pte_t *pte;
        spinlock_t *ptl;
 
-       retval = -EINVAL;
+       ret = VM_FAULT_SIGBUS;
        if (PageAnon(page))
                goto out;
-       retval = -ENOMEM;
+       ret = VM_FAULT_OOM;
        flush_dcache_page(page);
        pte = get_locked_pte(mm, addr, &ptl);
        if (!pte)
                goto out;
-       retval = -EBUSY;
+       ret = 0;
        if (!pte_none(*pte))
                goto out_unlock;
 
@@ -1729,17 +1729,14 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
        page_add_file_rmap(page, false);
        set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
-       retval = 0;
-       pte_unmap_unlock(pte, ptl);
-       return retval;
 out_unlock:
        pte_unmap_unlock(pte, ptl);
 out:
-       return retval;
+       return ret;
 }
 
 /**
- * vm_insert_page - insert single page into user vma
+ * vmf_insert_page - insert single page into user vma
  * @vma: user vma to map to
  * @addr: target user address of this page
  * @page: source kernel page
@@ -1765,13 +1762,13 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
  * Caller must set VM_MIXEDMAP on vma if it wants to call this
  * function from other places, for example from page-fault handler.
  */
-int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_page(struct vm_area_struct *vma, unsigned long addr,
                        struct page *page)
 {
        if (addr < vma->vm_start || addr >= vma->vm_end)
-               return -EFAULT;
+               return VM_FAULT_SIGBUS;
        if (!page_count(page))
-               return -EINVAL;
+               return VM_FAULT_SIGBUS;
        if (!(vma->vm_flags & VM_MIXEDMAP)) {
                BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
                BUG_ON(vma->vm_flags & VM_PFNMAP);
@@ -1779,21 +1776,21 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
        }
        return insert_page(vma, addr, page, vma->vm_page_prot);
 }
-EXPORT_SYMBOL(vm_insert_page);
+EXPORT_SYMBOL(vmf_insert_page);
 
-static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
                        pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
        struct mm_struct *mm = vma->vm_mm;
-       int retval;
+       vm_fault_t ret;
        pte_t *pte, entry;
        spinlock_t *ptl;
 
-       retval = -ENOMEM;
+       ret = VM_FAULT_OOM;
        pte = get_locked_pte(mm, addr, &ptl);
        if (!pte)
                goto out;
-       retval = -EBUSY;
+       ret = VM_FAULT_SIGBUS;
        if (!pte_none(*pte)) {
                if (mkwrite) {
                        /*
@@ -1826,20 +1823,20 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
        set_pte_at(mm, addr, pte, entry);
        update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
-       retval = 0;
+       ret = 0;
 out_unlock:
        pte_unmap_unlock(pte, ptl);
 out:
-       return retval;
+       return ret;
 }
 
 /**
- * vm_insert_pfn - insert single pfn into user vma
+ * vmf_insert_pfn - insert single pfn into user vma
  * @vma: user vma to map to
  * @addr: target user address of this page
  * @pfn: source kernel pfn
  *
- * Similar to vm_insert_page, this allows drivers to insert individual pages
+ * Similar to vmf_insert_page(), this allows drivers to insert individual pages
  * they've allocated into a user vma. Same comments apply.
  *
  * This function should only be called from a vm_ops->fault handler, and
@@ -1850,21 +1847,21 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  */
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
                        unsigned long pfn)
 {
-       return vm_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
+       return vmf_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
 }
-EXPORT_SYMBOL(vm_insert_pfn);
+EXPORT_SYMBOL(vmf_insert_pfn);

... etc ...

But first, we have to finish removing all the calls to vm_insert_foo().
