Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id A57306B0038
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 17:46:31 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id c11so8789250lbj.33
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 14:46:30 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.232])
        by mx.google.com with ESMTP id a6si39617636lbq.113.2014.08.21.14.46.29
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 14:46:30 -0700 (PDT)
Date: Fri, 22 Aug 2014 00:39:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: softdirty: write protect PTEs created for read
 faults after VM_SOFTDIRTY cleared
Message-ID: <20140821213942.GA15218@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <20140820234543.GA7987@node.dhcp.inet.fi>
 <20140821193737.GC16042@google.com>
 <20140821205115.GH14072@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140821205115.GH14072@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <damm@opensource.se>

On Fri, Aug 22, 2014 at 12:51:15AM +0400, Cyrill Gorcunov wrote:
> On Thu, Aug 21, 2014 at 03:37:37PM -0400, Peter Feiner wrote:
> >
> > Thanks Kirill, I prefer your approach. I'll send a v2.
> > 
> > I believe you're right about c9d0bf241451. It seems like passing the old & new
> > pgprot through pgprot_modify would handle the problem. Furthermore, as you
> > suggest, mprotect_fixup should use pgprot_modify when it turns write
> > notification on.  I think a patch like this is in order:

Looks good to me.

Would you mind to apply the same pgprot_modify() approach on the
clear_refs_write(), test and post the patch?

Feel free to use my singed-off-by (or suggested-by if you prefer) once
it's tested (see merge case below).
 
> > Not-signed-off-by: Peter Feiner <pfeiner@google.com>
> > 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index c1f2ea4..86f89a1 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1611,18 +1611,15 @@ munmap_back:
> >  	}
> >  
> >  	if (vma_wants_writenotify(vma)) {
> > -		pgprot_t pprot = vma->vm_page_prot;
> > -
> >  		/* Can vma->vm_page_prot have changed??
> >  		 *
> >  		 * Answer: Yes, drivers may have changed it in their
> >  		 *         f_op->mmap method.
> >  		 *
> > -		 * Ensures that vmas marked as uncached stay that way.
> > +		 * Ensures that vmas marked with special bits stay that way.
> >  		 */
> > -		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
> > -		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
> > -			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> > +		vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> > +		                        vm_get_page_prot(vm_flags & ~VM_SHARED);
> >  	}
> >  
> >  	vma_link(mm, vma, prev, rb_link, rb_parent);
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index c43d557..6826313 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -324,7 +324,8 @@ success:
> >  					  vm_get_page_prot(newflags));
> >  
> >  	if (vma_wants_writenotify(vma)) {
> > -		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
> > +		vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> > +		                       vm_get_page_prot(newflags & ~VM_SHARED));
> >  		dirty_accountable = 1;
> >  	}
> 
> Thanks a lot Peter and Kirill for catching it and providing the prelim. fixup. (Initial
> patch doesn't look that right for me because vm-softdirty should involve into
> account for newly created/expaned vmas only but not into some deep code such
> as fault handlings). Peter does the patch above helps? (out of testing machine
> at the moment so cant test myself).

One thing: there could be (I haven't checked) complications on
vma_merge(): since vm_flags are identical it assumes that it can reuse
vma->vm_page_prot of expanded vma. But VM_SOFTDIRTY is excluded from
vm_flags compatibility check. What should we do with vm_page_prot there?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
