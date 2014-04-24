Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3E5C6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 19:16:12 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so2456778pdj.27
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:16:12 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id rj9si1016442pbc.461.2014.04.24.16.16.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 16:16:11 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so2445957pdj.13
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:16:11 -0700 (PDT)
Date: Thu, 24 Apr 2014 16:14:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: get_user_pages(write,force) refuse to COW in shared
 areas
In-Reply-To: <20140424133055.GA13269@redhat.com>
Message-ID: <alpine.LSU.2.11.1404241518510.4454@eggly.anvils>
References: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils> <20140424133055.GA13269@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <m.chehab@samsung.com>, Omar Ramirez Luna <omar.ramirez@copitl.com>, Inki Dae <inki.dae@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org

On Thu, 24 Apr 2014, Oleg Nesterov wrote:

> Hi Hugh,
> 
> Sorry for late reply. First of all, to avoid the confusion, I think the
> patch is fine.
> 
> When I saw this patch I decided that uprobes should be updated accordingly,
> but I just realized that I do not understand what should I write in the
> changelog.

Thanks a lot for considering similar issues in uprobes, Oleg: I merely
checked that its uses of get_user_pages() would not be problematic,
and didn't look around to rediscover the worrying mm business that
goes on down there in kernel/events.

> 
> On 04/04, Hugh Dickins wrote:
> >
> > +		if (gup_flags & FOLL_WRITE) {
> > +			if (!(vm_flags & VM_WRITE)) {
> > +				if (!(gup_flags & FOLL_FORCE))
> > +					goto efault;
> > +				/*
> > +				 * We used to let the write,force case do COW
> > +				 * in a VM_MAYWRITE VM_SHARED !VM_WRITE vma, so
> > +				 * ptrace could set a breakpoint in a read-only
> > +				 * mapping of an executable, without corrupting
> > +				 * the file (yet only when that file had been
> > +				 * opened for writing!).  Anon pages in shared
> > +				 * mappings are surprising: now just reject it.
> > +				 */
> > +				if (!is_cow_mapping(vm_flags)) {
> > +					WARN_ON_ONCE(vm_flags & VM_MAYWRITE);
> > +					goto efault;
> > +				}
> 
> OK. But could you please clarify "Anon pages in shared mappings are surprising" ?
> I mean, does this only apply to "VM_MAYWRITE VM_SHARED !VM_WRITE vma" mentioned
> above or this is bad even if a !FMODE_WRITE file was mmaped as MAP_SHARED ?

Good question. I simply didn't consider that - and (as you have realized)
didn't need to consider it, because I was just stopping the problematic
behaviour in gup(), and didn't need to consider whether other behaviour
prohibited by gup() was actually unproblematic.

> 
> Yes, in this case this vma is not VM_SHARED and it is not VM_MAYWRITE, it is only
> VM_MAYSHARE. This is in fact private mapping except mprotect(PROT_WRITE) will not
> work.
> 
> But with or without this patch gup(FOLL_WRITE | FOLL_FORCE) won't work in this case,
                     "this" meaning my patch rather than yours below
> (although perhaps it could ?), is_cow_mapping() == F because of !VM_MAYWRITE.
> 
> However, currently uprobes assumes that a cowed anon page is fine in this case, and
> this differs from gup().
> 
> So, what do you think about the patch below? It is probably fine in any case,
> but is there any "strong" reason to follow the gup's behaviour and forbid the
> anon page in VM_MAYSHARE && !VM_MAYWRITE vma?

I don't think there is a "strong" reason to forbid it.

The strongest reason is simply that it's much safer if uprobes follows
the same conventions as mm, and get_user_pages() happens to have
forbidden that all along.

The philosophical reason to forbid it is that the user mmapped with
MAP_SHARED, and it's merely a kernel-internal detail that we flip off
VM_SHARED and treat these read-only shared mappings very much like
private mappings.  The user asked for MAP_SHARED, and we prefer to
respect that by not letting private COWs creep in.

We could treat those mappings even more like private mappings, and
allow the COWs; but better to be strict about it, so long as doing
so doesn't give you regressions.

> 
> Oleg.
> 
> --- x/kernel/events/uprobes.c
> +++ x/kernel/events/uprobes.c
> @@ -127,12 +127,13 @@ struct xol_area {
>   */
>  static bool valid_vma(struct vm_area_struct *vma, bool is_register)
>  {
> -	vm_flags_t flags = VM_HUGETLB | VM_MAYEXEC | VM_SHARED;
> +	vm_flags_t flags = VM_HUGETLB | VM_MAYEXEC;

I think a one-line patch changing VM_SHARED to VM_MAYSHARE would do it,
wouldn't it?  And save you from having to export is_cow_mapping()
from mm/memory.c.  (I used is_cow_mapping() because I had to make the
test more complex anyway, just to exclude the case which had been
oddly handled before.)

Hugh

>  
>  	if (is_register)
>  		flags |= VM_WRITE;
>  
> -	return vma->vm_file && (vma->vm_flags & flags) == VM_MAYEXEC;
> +	return 	vma->vm_file && is_cow_mapping(vma->vm_flags) &&
> +		(vma->vm_flags & flags) == VM_MAYEXEC;
>  }
>  
>  static unsigned long offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
