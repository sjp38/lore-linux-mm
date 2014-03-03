Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id F40616B0038
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 15:47:27 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id md12so4240447pbc.9
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 12:47:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tm9si11814815pab.105.2014.03.03.12.47.26
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 12:47:26 -0800 (PST)
Date: Mon, 3 Mar 2014 12:47:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: do_shared_fault: fix potential NULL pointer
 dereference
Message-Id: <20140303124724.9c287478cd0c550bc222ca1f@linux-foundation.org>
In-Reply-To: <CAA_GA1dzMA+RS=TtM6ieJ7_DY5ruAbY9a4Ui9O7EYuvc-bSH_A@mail.gmail.com>
References: <1393507600-24752-1-git-send-email-bob.liu@oracle.com>
	<20140227154808.cbe04fa80cb47e2e091daa31@linux-foundation.org>
	<20140227235959.GA9424@node.dhcp.inet.fi>
	<20140228090745.GE27965@twins.programming.kicks-ass.net>
	<20140228135950.4a49ce89b5bff12c149b1f73@linux-foundation.org>
	<CAA_GA1dzMA+RS=TtM6ieJ7_DY5ruAbY9a4Ui9O7EYuvc-bSH_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>

On Sat, 1 Mar 2014 11:14:17 +0800 Bob Liu <lliubbo@gmail.com> wrote:

> >
> > --- a/mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
> > +++ a/mm/memory.c
> > @@ -3476,6 +3476,12 @@ set_pte:
> >
> >         if (set_page_dirty(fault_page))
> >                 dirtied = 1;
> > +       /*
> > +        * Take a local copy of the address_space - page.mapping may be zeroed
> > +        * by truncate after unlock_page().   The address_space itself remains
> > +        * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
> > +        * release semantics to prevent the compiler from undoing this copying.
> > +        */
> >         mapping = fault_page->mapping;
> >         unlock_page(fault_page);
> >         if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
> >
> > I don't actually know if that's true.  What *does* protect ->mapping
> > from reclaim, drop_caches, etc?
> >
> 
> I also puzzled what can protect ->mapping.

Yes, ->mapping is pinned by the reference from vma->vm_file. 
vma->vm_file (and the vma itself) are protected by mmap_sem (held for
rear or for write).

I'll stick this in there, see what happens..

--- a/mm/memory.c~a
+++ a/mm/memory.c
@@ -3422,6 +3422,8 @@ static int do_shared_fault(struct mm_str
 	struct vm_fault vmf;
 	int ret, tmp;
 
+	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
+
 	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
